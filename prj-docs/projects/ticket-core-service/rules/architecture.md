# Architecture (ticket-core-service sidecar)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 05:18:32`
> - **Updated At**: `2026-02-17 17:28:03`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Source of Truth
> - Sidecar Boundary
<!-- DOC_TOC_END -->

## Source of Truth
- 서비스 구현 아키텍처 원문은 제품 레포 문서를 기준으로 한다.

## Sidecar Boundary
- AKI AgentOps sidecar는 구조 이관, 운영 체크리스트, 교차 레포 연계 규칙만 유지한다.
- 코드 설계 세부 변경은 제품 레포 이슈/PR 링크로 추적한다.
