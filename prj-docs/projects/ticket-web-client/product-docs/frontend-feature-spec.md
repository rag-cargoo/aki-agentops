# Frontend Feature Spec (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 21:12:00`
> - **Updated At**: `2026-02-20 06:42:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Feature Breakdown
> - API Contract Integration
> - Realtime Integration Plan
> - Error/Recovery Strategy
> - Playwright Mapping
<!-- DOC_TOC_END -->

## Scope
- 대상 프로젝트: `workspace/apps/frontend/ticket-web-client`
- 목적: 메인 랜딩 + Queue 실 API 연동 + 개발 검증 패널을 함께 유지해 프론트 구현/검증 기준을 고정한다.

## Feature Breakdown
1. Layout/Navigate
- 상단 네비게이션 기본 항목(`Home`, `Highlights`, `Gallery`, `Queue`)과 앵커 이동 구조를 제공한다.
- Dev Lab 노출 시 `Auth`, `Realtime` 항목을 추가로 노출한다.
- Hero/Highlights/Gallery/Queue 4개를 기본 사용자 화면으로 제공한다.
- 개발 검증 패널(`Dev Lab`, `Contract/Auth/Realtime`)은 기본 화면에서 숨김 처리한다.

2. Highlights Grid
- K-POP 영상 썸네일 카드 그리드로 구성한다.
- 외부 링크(`YouTube 보기`) 동작을 제공한다.

3. Gallery Grid
- 포토 월 형태의 카드 레이아웃으로 시각 강조 영역을 구성한다.

4. Queue (서비스 섹션)
- `GET /api/concerts/search` 응답을 카드 목록으로 렌더링한다.
- KPI(`Catalog`, `Bookable Now`, `Opening Soon`)는 검색 응답에서 파생 계산한다.
- 오픈 임계 구간(`1시간 전`, `5분 전`)은 초 단위 카운트다운으로 노출한다.
- 오픈 경계 도달 시 자동 재조회하여 버튼 활성 상태를 최신화한다.
- `Access Token`/`Device Fingerprint` 입력값을 사용해 예약 API(v7) 호출 파라미터를 제어한다.
- `예매하기` 클릭 시 `options -> seats -> hold -> paying -> confirm` 체인을 수행한다.
- 카드 단위 예약 상태(`running/success/error`)와 로그 패널을 통해 실행 결과를 표시한다.
- API 실패 시 오류 패널과 수동 재시도 버튼을 노출한다.

5. Realtime Mode Lab (개발 전용)
- 요청 모드(`websocket`/`sse`) 선택 UI와 연결 상태를 표시한다.
- websocket 실패 시 sse fallback 상태를 시뮬레이션해 검증 가능하게 유지한다.
- 이벤트 로그를 패널 내에 남겨 Playwright와 수동 점검 모두에서 추적 가능하게 유지한다.

6. Auth Session Lab (개발 전용)
- 로그인/만료/재발급/로그아웃/보호 API 호출 시나리오를 단일 패널에서 재현한다.
- 상태(`authStatus`, `token 존재`, `refreshCount`, `last API result`)를 즉시 표시한다.
- 마지막 auth 에러 JSON과 토큰 만료 시간 파싱 결과를 노출해 계약 기반 검증을 지원한다.
- 이벤트 로그를 남겨 Playwright 콘솔/패널 증빙을 동기화한다.

## Dev Lab Exposure Rule
- 기본값: 숨김
- 노출 조건:
  - `?labs=1` query
  - 또는 `VITE_APP_DEV_LABS=1`
  - 또는 e2e probe 모드(`VITE_E2E_CONSOLE_LOG=1`)

## API Contract Integration
- Error Parser:
  - 입력: `{ status, errorCode, message }`
  - 출력: `NormalizedApiError`
  - 비정상 값은 `errorCode: UNKNOWN`로 정규화
- DateTime Parser:
  - `Instant(UTC)`와 `LocalDateTime` 혼재 입력 지원
  - 출력: `{ isoUtc, sourceType, valid }`
- Concert Listing Sale Window:
  - 입력: `GET /api/concerts`, `GET /api/concerts/search`의 `saleStatus`/`saleOpensInSeconds`/`reservationButtonVisible`/`reservationButtonEnabled`
  - 상태값:
    - `UNSCHEDULED`: 판매정책 미설정
    - `PREOPEN`: 오픈 1시간 이전
    - `OPEN_SOON_1H`: 오픈 1시간 이내
    - `OPEN_SOON_5M`: 오픈 5분 이내
    - `OPEN`: 즉시 예매 가능
    - `SOLD_OUT`: 잔여 좌석 0
  - 버튼 규칙:
    - 노출: `reservationButtonVisible=true`
    - 활성: `reservationButtonEnabled=true`
  - 카운트다운:
    - `saleOpensInSeconds`가 양수면 초 단위 타이머 UI를 렌더링한다.
  - 새로고침:
    - 기본 30초 폴링 + 경계(남은 시간 0초) 도달 시 즉시 재조회
- Reservation v7 Queue Action:
  - 선행 조회:
    - `GET /api/concerts/{concertId}/options` (가장 이른 회차 선택)
    - `GET /api/concerts/options/{optionId}/seats` (`AVAILABLE` 좌석 중 우선 좌석 선택)
  - 전이 체인:
    - `POST /api/reservations/v7/holds`
    - `POST /api/reservations/v7/{reservationId}/paying`
    - `POST /api/reservations/v7/{reservationId}/confirm`
  - 인증:
    - `Authorization: Bearer {accessToken}` 필수
  - 에러 처리:
    - auth/domain 에러는 카드 단위 상태 메시지 + 재시도 라벨로 반영

## Runtime Env Contract
- `VITE_API_BASE_URL`:
  - 기본값 `/api` (Vite dev proxy 경유)
  - 분리 도메인에서는 절대 URL 사용 가능
- `VITE_DEV_PROXY_TARGET`:
  - 로컬 개발 프록시 타깃(`http://127.0.0.1:8080` 기본)
- `VITE_APP_DEV_LABS`:
  - `1`일 때 Dev Lab 섹션 노출
- Queue Access Token:
  - `Access Token` 입력값은 `localStorage(ticket-web-client.queue.access-token)`에 저장하여 새로고침 후 재사용한다.

## Realtime Integration Plan
- 1차: WebSocket 우선 연결 어댑터
- 2차: WS 실패 시 SSE fallback
- 3차: auth 만료/네트워크 오류 시 재연결(backoff) 및 구독 복구

## Error/Recovery Strategy
- 비정상 API 응답 본문은 공통 에러 파서로 강제 정규화한다.
- 시간 파싱 실패 시 `valid: false`를 UI/로그로 명시해 무음 실패를 차단한다.
- 네트워크/채널 오류는 이벤트 로그로 남기고, UI에 재시도 가능 상태를 노출한다.

## Playwright Mapping
- `@smoke`: 페이지 부팅, 핵심 섹션 노출
- `@nav`: 앵커 이동/내비게이션 동작
- `@queue`: Queue 카드 예매 클릭 시 v7 hold/paying/confirm 체인 및 상태/로그 검증
- `@contract`: Contract Panel JSON 구조/값 검증 + 콘솔 로그 검증
- `@auth`: auth/session 상태 전이 + 보호 API 성공/실패 전환 검증
- `@realtime`: websocket 실패 -> sse fallback 상태 및 이벤트 로그 검증
