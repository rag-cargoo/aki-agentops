# PROJECT_AGENT (ticket-web-client sidecar)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 20:36:00`
> - **Updated At**: `2026-02-19 22:15:00`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Rules
> - Playwright Operation Contract
<!-- DOC_TOC_END -->

## Scope
- 이 문서는 `ticket-web-client`의 sidecar 운영 규칙을 정의한다.
- 제품 코드 변경 규칙은 제품 레포 정책을 우선한다.

## Rules
- 코드 변경/테스트/릴리즈는 `rag-cargoo/ticket-web-client` 레포에서 수행한다.
- 본 sidecar에는 운영 회의록/태스크/연결 규칙만 기록한다.
- 제품 레포에 공유가 필요한 결정은 이슈 또는 PR 코멘트로 동기화한다.
- 전역 프론트 규칙은 `skills/aki-frontend-delivery-governance/SKILL.md`를 따른다.

## Playwright Operation Contract
- 테스트 실행 전 범위 목록(`smoke/nav/contract/realtime/all`)을 먼저 제시한다.
- 사용자가 선택한 파트만 실행한다.
- 실행 로그/요약 경로를 결과 보고에 포함한다.
