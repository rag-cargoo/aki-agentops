# Playwright Suite Catalog (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 21:12:00`
> - **Updated At**: `2026-02-19 22:15:00`
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
- `contract`: 에러/시간 파서 출력 및 콘솔 로그 확인
- `realtime`: websocket 실패 시 sse fallback 상태/로그 확인
- `all`: 전체 실행

## Scenario Details
1. `smoke`
- URL 진입 후 메인 섹션(`home/highlights/gallery/queue`)이 모두 렌더링되는지 확인
- 주요 타이틀 및 카드 개수가 기준값 이상인지 확인

2. `nav`
- `Highlights`, `Gallery`, `Queue` 링크 클릭 시 URL hash가 기대값으로 바뀌는지 확인

3. `contract`
- Contract Panel의 JSON 출력이 파서 계약을 만족하는지 확인
- 브라우저 console에 계약 검증 로그 키가 출력되는지 확인

4. `realtime`
- `pushMode=websocket`에서 연결 시작 시 websocket 실패를 유도하고 sse fallback이 표시되는지 확인
- 상태 필드(`status`, `active transport`, `fallback used`)가 기대값으로 전환되는지 확인
- 이벤트 로그와 브라우저 console에 realtime 검증 로그 키가 출력되는지 확인

## Console Verification Keys
- `[ticket-web-client][contract] normalized-api-error`
- `[ticket-web-client][contract] parsed-server-date-time`
- `[ticket-web-client][realtime] transport-error`
- `[ticket-web-client][realtime] event`
- 증빙 파일:
  - `workspace/apps/frontend/ticket-web-client/test-results/<test-id>/browser-console.log`

## Failure Triage
- selector 실패: UI 구조 변경 여부 확인 후 spec selector 갱신
- timeout 실패: dev server 기동 상태와 포트 충돌 확인
- contract 실패: `normalize-api-error.ts`, `parse-server-date-time.ts` 변경점 확인
