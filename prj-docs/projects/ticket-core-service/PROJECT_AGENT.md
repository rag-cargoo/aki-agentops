# PROJECT_AGENT (ticket-core-service sidecar)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 05:18:32`
> - **Updated At**: `2026-02-23 07:30:00`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Rules
<!-- DOC_TOC_END -->

## Scope
- 이 문서는 `ticket-core-service`의 sidecar 운영 규칙을 정의한다.
- 제품 코드 변경 규칙은 제품 레포 정책을 우선한다.

## Rules
- 코드 변경/테스트/릴리즈는 `rag-cargoo/ticket-core-service` 레포에서 수행한다.
- 본 sidecar에는 운영 회의록/태스크/연결 규칙만 기록한다.
- 제품 레포에 공유가 필요한 결정은 이슈 또는 PR 코멘트로 동기화한다.
- 아키텍처 스킬 위임:
  - `Delegated(non-aki)`: `clean-ddd-hexagonal` (`.agents/skills/clean-ddd-hexagonal/SKILL.md`)
  - 우선순위: `AGENTS.md` -> `aki-*` -> `PROJECT_AGENT.md` 위임 규칙 -> 외부 스킬 본문
- DDD 경계 기본 수칙(코드/리뷰/테스트 공통):
  - `domain` 계층은 `api.dto`를 import하지 않는다.
  - `api.controller`는 `*Repository`를 직접 참조하지 않고 서비스/유스케이스를 경유한다.
  - 경계 규칙은 아키텍처 테스트(ArchUnit)로 CI에서 강제한다.
