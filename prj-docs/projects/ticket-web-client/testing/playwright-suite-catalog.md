# Playwright Suite Catalog (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 21:12:00`
> - **Updated At**: `2026-02-20 10:18:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope List
> - Scenario Details
> - Console Verification Keys
> - Failure Triage
<!-- DOC_TOC_END -->

## Scope List
- `smoke`: 핵심 레이아웃 부팅/렌더링 확인
- `nav`: 상단 네비게이션 앵커 이동 확인
- `queue`: Queue 카드 `예매하기` v7 hold/paying/confirm 체인 검증
- `contract`: 에러/시간 파서 출력 및 콘솔 로그 확인(Dev Lab)
- `auth`: OAuth authorize-url/exchange + auth/session 상태 전이 + `/api/auth/me` 결과 확인(Dev Lab)
- `realtime`: websocket 실패 시 sse fallback 상태/로그 확인(Dev Lab)
- `all`: 전체 실행

## Scenario Details
1. `smoke`
- URL(`/`) 진입 후 메인 섹션(`home/highlights/gallery/queue`)이 모두 렌더링되는지 확인
- 주요 타이틀 및 카드 개수가 기준값 이상인지 확인

2. `nav`
- `Highlights`, `Gallery`, `Queue` 링크 클릭 시 URL hash가 기대값으로 바뀌는지 확인

3. `contract`
- `/labs` Contract Panel의 JSON 출력이 파서 계약을 만족하는지 확인
- 브라우저 console에 계약 검증 로그 키가 출력되는지 확인

4. `queue`
- Queue 카드 예매 버튼 클릭 시 `options -> seats -> holds -> paying -> confirm` 호출이 순서대로 실행되는지 확인
- 카드 상태 메시지가 `예매 확정 완료`로 전환되는지 확인
- Queue 로그 패널에 confirmed 로그가 기록되는지 확인
- My Reservations 패널에서 `확정 -> 취소 -> 환불` 상태 전이가 반영되는지 확인

5. `auth`
- `/labs`에서 Auth Session Lab이 노출되는지 확인
- authorize-url 요청/코드 교환으로 access/refresh 토큰이 발급되는지 확인
- 비인증/만료/재발급/로그아웃 흐름에서 상태 필드가 기대값으로 전환되는지 확인
- `/api/auth/me` 호출 성공 시 사용자 컨텍스트가 표시되는지 확인
- 보호 API 호출 시 에러 코드(`AUTH_ACCESS_TOKEN_REQUIRED`, `AUTH_TOKEN_EXPIRED`)와 성공 전환을 확인
- 브라우저 console에 auth 검증 로그 키가 출력되는지 확인

6. `realtime`
- `/labs?pushMode=websocket`에서 연결 시작 시 websocket 실패를 유도하고 sse fallback이 표시되는지 확인
- 상태 필드(`status`, `active transport`, `fallback used`)가 기대값으로 전환되는지 확인
- Queue 카드의 실시간 상태(`대기중 -> 입장 가능`)가 병합 반영되는지 확인
- My Reservations 상태가 `결제 진행 -> 확정`으로 실시간 병합 전환되는지 확인
- 이벤트 로그와 브라우저 console에 realtime 검증 로그 키가 출력되는지 확인
- transport interruption 발생 시 reconnect backoff가 스케줄되고 복구되는지 확인

## Console Verification Keys
- `[ticket-web-client][contract] normalized-api-error`
- `[ticket-web-client][contract] parsed-server-date-time`
- `[ticket-web-client][queue] reservation-confirmed`
- `[ticket-web-client][queue] reservation-error`
- `[ticket-web-client][auth] state`
- `[ticket-web-client][auth] api-error`
- `[ticket-web-client][auth] api-success`
- `[ticket-web-client][auth] sign-in-success`
- `[ticket-web-client][auth] refresh-success`
- `[ticket-web-client][auth] logout-success`
- `[ticket-web-client][realtime] transport-error`
- `[ticket-web-client][realtime] event`
- `[ticket-web-client][queue] realtime-merge`
- `[ticket-web-client][reservation] realtime-merge`
- `[reconnect-scheduled]`
- `[reconnect-recovered]`
- 증빙 파일:
  - `workspace/apps/frontend/ticket-web-client/test-results/<test-id>/browser-console.log`

## Execution Ledger
- 실행 누적 이력:
  - `prj-docs/projects/ticket-web-client/testing/playwright-execution-history.md`
- 누적 필드:
  - `Executed At`, `Scope`, `Result`, `Run ID`, `Summary`, `Log`

## Failure Triage
- selector 실패: UI 구조 변경 여부 확인 후 spec selector 갱신
- timeout 실패: dev server 기동 상태와 포트 충돌 확인
- contract 실패: `normalize-api-error.ts`, `parse-server-date-time.ts` 변경점 확인
