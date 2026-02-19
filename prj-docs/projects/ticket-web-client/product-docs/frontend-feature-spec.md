# Frontend Feature Spec (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 21:12:00`
> - **Updated At**: `2026-02-20 03:05:00`
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
- 목적: 초기 랜딩/탐색 UI와 API 계약 파서 기반을 고정하고, 이후 기능 확장을 위한 검증 기준을 제공한다.

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
- 라이브 티켓 대기열/오픈 일정/회원 전환 지표를 사용자 관점으로 노출한다.
- 백엔드 API(`티켓 목록`, `대기열 상태`, `세션`) 연동 대상 섹션으로 유지한다.

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
- `@contract`: Contract Panel JSON 구조/값 검증 + 콘솔 로그 검증
- `@auth`: auth/session 상태 전이 + 보호 API 성공/실패 전환 검증
- `@realtime`: websocket 실패 -> sse fallback 상태 및 이벤트 로그 검증
