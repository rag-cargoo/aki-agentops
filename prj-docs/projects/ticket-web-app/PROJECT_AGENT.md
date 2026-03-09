# PROJECT_AGENT (ticket-web-app sidecar)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-24 08:27:00`
> - **Updated At**: `2026-02-24 08:27:00`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Rules
> - Frontend Contract
<!-- DOC_TOC_END -->

## Scope
- 이 문서는 `ticket-web-app`의 sidecar 운영 규칙을 정의한다.
- 제품 코드 변경 규칙은 제품 레포 정책을 우선한다.

## Rules
- 코드 변경/테스트/릴리즈는 `rag-cargoo/ticket-web-app` 레포에서 수행한다.
- 본 sidecar에는 운영 회의록/태스크/연결 규칙만 기록한다.
- 제품 레포에 공유가 필요한 결정은 이슈 또는 PR 코멘트로 동기화한다.
- 전역 프론트 규칙은 `skills/aki-frontend-delivery-governance/SKILL.md`를 따른다.

## Frontend Contract
- Sprint-1 최우선 범위는 `SC019` 이관 항목 4종이다.
  - OAuth 세션 기반 인증 단일화(수동 토큰 입력 제거)
  - 예약/취소/환불 API를 백엔드 단건 v7 계약으로 정렬
  - non-mock 실백엔드 smoke 검증 추가
  - 예약 실시간 구독 seat snapshot 갱신 전략 보강
