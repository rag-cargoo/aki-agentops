# Architecture (ticket-rush-deploy sidecar)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-03-01 06:47:14`
> - **Updated At**: `2026-03-01 06:47:14`
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
- 배포 아키텍처 원문은 `workspace/ticket-rush-deploy` 코드/스크립트를 기준으로 한다.

## Sidecar Boundary
- sidecar는 운영 체크리스트, 회의록, 세션 인계 기준만 유지한다.
- 실코드 변경은 `deploy/aws/**`에 반영하고, 본 문서에는 변경 근거 링크만 남긴다.
