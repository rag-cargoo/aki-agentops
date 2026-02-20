# Frontend Feature Spec (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 21:12:00`
> - **Updated At**: `2026-02-20 16:52:00`
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
- 목적: 서비스 화면/관리자 화면/검증랩 화면을 라우트 단위로 분리해 운영 화면과 검증 화면을 분리한다.

## Feature Breakdown
1. Layout/Navigate
- 라우트 구조:
  - 서비스 사용자 페이지: `/`
  - 관리자 페이지: `/admin`
  - 개발 검증랩 페이지: `/labs`
- 상단 네비게이션은 서비스 섹션 링크(`Home`, `Highlights`, `Gallery`, `Queue`)와 페이지 링크(`Admin`, `Labs`)를 함께 제공한다.
- 상단 라우트 네비는 `Service`, `Admin`, `Labs`로 페이지 분류를 고정한다.
- 라우트별 섹션 네비를 별도로 제공한다.
  - `/`: `Home`, `Highlights`, `Gallery`, `Queue`
  - `/admin`: `Concerts`, `Seat & Price`, `Media`
  - `/labs`: `Contract`, `Auth`, `Realtime`
- Hero/Highlights/Gallery/Queue 4개는 서비스 사용자 페이지(`/`)에만 노출한다.
- 개발 검증 패널(`Contract/Auth/Realtime`)은 `/labs`에서만 노출한다.

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
- `My Reservations` 패널에서 내 예약 목록/상세상태를 확인하고 취소/환불 액션을 수행한다.
- Queue 섹션에서 실시간 연결 파라미터(`userId`, `concertId`)를 설정하고 connect/disconnect를 제어한다.
- 실시간 대기열 이벤트(`RANK_UPDATE`, `ACTIVE`)를 Queue 카드 상태와 버튼 활성 규칙에 병합 반영한다.
- 실시간 예약 이벤트(`RESERVATION_STATUS`)를 My Reservations 상태/액션 메시지에 병합 반영한다.
- websocket 모드에서 WS 구독 등록 API 호출 후 destination 기반 STOMP subscribe를 수행한다.
- transport 오류 시 지수 backoff 재연결 상태를 UI 메타(`attempt`, `next delay`, `reason`)로 노출한다.
- API 실패 시 오류 패널과 수동 재시도 버튼을 노출한다.

5. Realtime Mode Lab (개발 전용)
- 요청 모드(`websocket`/`sse`) 선택 UI와 연결 상태를 표시한다.
- websocket 실패 시 sse fallback 상태를 시뮬레이션해 검증 가능하게 유지한다.
- 이벤트 로그를 패널 내에 남기고, Queue/My Reservations 병합 결과를 서비스 섹션과 동기화해 추적한다.

6. Auth Session Lab (개발 전용)
- OAuth provider/state/code 입력으로 소셜 코드 교환 세션 발급을 검증한다.
- `Authorize URL` 요청과 `Exchange & Sign In` 호출을 분리해 OAuth 단계별 상태를 확인한다.
- `/api/auth/me` 조회 결과를 패널에 노출해 사용자 컨텍스트를 검증한다.
- 상태(`authStatus`, `access/refresh token 존재`, `refreshCount`, `last API result`)를 즉시 표시한다.
- 마지막 auth 에러 JSON과 access/refresh 토큰 만료 시간 파싱 결과를 노출해 계약 기반 검증을 지원한다.
- 이벤트 로그를 남겨 Playwright 콘솔/패널 증빙을 동기화한다.

## Dev Lab Exposure Rule
- 기본값: 숨김(`/labs` 진입 시에도 비노출)
- 노출 조건:
  - `/labs` 라우트 진입
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
- My Reservations v7 Action:
  - 목록:
    - `GET /api/reservations/v7/me`
  - 상세:
    - `GET /api/reservations/v7/{reservationId}`
  - 상태 전이:
    - `POST /api/reservations/v7/{reservationId}/cancel`
    - `POST /api/reservations/v7/{reservationId}/refund`
  - 버튼 규칙:
    - `CONFIRMED` 상태에서만 `취소` 활성
    - `CANCELLED` 상태에서만 `환불` 활성
- Realtime State Merge:
  - SSE 구독 URL:
    - `GET /api/v1/waiting-queue/subscribe?userId={userId}&concertId={concertId}`
  - WebSocket fallback 정책:
    - websocket 모드에서 transport 오류 시 sse로 fallback
  - Queue 병합:
    - `RANK_UPDATE`/`ACTIVE` 이벤트를 `queueRealtimeState`로 저장하고 카드 상태/버튼 활성에 반영
  - Reservation 병합:
    - `RESERVATION_STATUS(SUCCESS|FAIL)`를 각각 `CONFIRMED`/`EXPIRED`로 정규화해 카드 상태에 반영
  - WebSocket registration API:
    - `POST /api/push/websocket/waiting-queue/subscriptions`
    - `POST /api/push/websocket/reservations/subscriptions`
    - disconnect/unmount/reconnect 시 아래 해제 API를 호출한다.
      - `DELETE /api/push/websocket/waiting-queue/subscriptions`
      - `DELETE /api/push/websocket/reservations/subscriptions`
- Auth Session Integration:
  - 인가 URL:
    - `GET /api/auth/social/{provider}/authorize-url?state=...`
  - 코드 교환:
    - `POST /api/auth/social/{provider}/exchange` (`{code, state}`)
  - 세션 갱신:
    - `POST /api/auth/token/refresh` (`{refreshToken}`)
  - 현재 사용자 조회:
    - `GET /api/auth/me` (`Authorization: Bearer {accessToken}`)
  - 로그아웃:
    - `POST /api/auth/logout` (`Authorization + refreshToken`)
  - 세션 저장:
    - `localStorage(ticket-web-client.auth.session)`에 access/refresh 및 만료 시각 저장
  - Queue 연동:
    - 로그인/갱신 성공 시 Queue Access Token 입력에 자동 반영

## Runtime Env Contract
- `VITE_API_BASE_URL`:
  - 기본값 `/api` (Vite dev proxy 경유)
  - 분리 도메인에서는 절대 URL 사용 가능
- `VITE_DEV_PROXY_TARGET`:
  - 로컬 개발 프록시 타깃(`http://127.0.0.1:8080` 기본)
- `VITE_APP_DEV_LABS`:
  - `1`일 때 Dev Lab 섹션 노출
- `VITE_APP_REALTIME_MOCK`:
  - `1`이면 mock transport 강제, `0`이면 실 transport 사용
- `VITE_APP_REALTIME_RECONNECT`:
  - `1`이면 reconnect backoff 활성
- `VITE_APP_REALTIME_RECONNECT_MAX_ATTEMPTS`:
  - 최대 재시도 횟수(기본 5)
- `VITE_APP_REALTIME_RECONNECT_BASE_DELAY_MS`:
  - 재시도 기본 지연(기본 1000ms)
- `VITE_APP_REALTIME_RECONNECT_MAX_DELAY_MS`:
  - 재시도 최대 지연(기본 15000ms)
- Queue Access Token:
  - `Access Token` 입력값은 `localStorage(ticket-web-client.queue.access-token)`에 저장하여 새로고침 후 재사용한다.
- Auth Session:
  - `localStorage(ticket-web-client.auth.session)`에 세션 정보를 저장하고, 진입 시 복구한다.

## Realtime Integration Plan
- Baseline(완료):
  - WebSocket 우선 연결 + transport 실패 시 SSE fallback
  - Queue/My Reservations 상태 병합 실시간 반영
- SC014(완료):
  - WS registration API + STOMP destination subscribe 연동
  - transport interruption 시 reconnect backoff 복구
- Next:
  - auth 세션 만료/재발급과 reconnect 정책을 결합한 통합 시나리오 자동화
  - 실백엔드 통합 스모크 런북 고정

## Error/Recovery Strategy
- 비정상 API 응답 본문은 공통 에러 파서로 강제 정규화한다.
- 시간 파싱 실패 시 `valid: false`를 UI/로그로 명시해 무음 실패를 차단한다.
- 네트워크/채널 오류는 이벤트 로그로 남기고, UI에 재시도 가능 상태를 노출한다.

## Playwright Mapping
- `@smoke`: 페이지 부팅, 핵심 섹션 노출
- `@nav`: 앵커 이동/내비게이션 동작
- `@queue`: Queue 카드 예매 클릭 시 v7 hold/paying/confirm 체인 및 상태/로그 검증
- `@contract`: `/labs`의 Contract Panel JSON 구조/값 검증 + 콘솔 로그 검증
- `@auth`: `/labs`의 OAuth authorize-url/exchange + refresh/logout + `/api/auth/me` 컨텍스트 검증
- `@realtime`: websocket 실패 -> sse fallback + Queue/My Reservations 실시간 상태 병합 검증
- `@realtime`: transport interruption 발생 시 reconnect backoff 복구 검증
