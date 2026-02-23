# Project Sidecar Index (AKI AgentOps)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 05:11:38`
> - **Updated At**: `2026-02-24 08:27:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Purpose
> - Project Map
> - Registration Criteria
> - Projects
> - Operations Reference
<!-- DOC_TOC_END -->

## Purpose
- 외부/독립 Git 레포의 운영 문서를 AKI AgentOps sidecar 경로로 관리한다.
- 코드 저장소와 운영 문서 저장소를 분리해 오염을 방지한다.

## Project Map
- [project-map.yaml](./project-map.yaml)

## Registration Criteria
1. `workspace/**` 경로에 있다고 해서 자동으로 프로젝트로 분류하지 않는다.
2. 기본 기준은 `project-map.yaml` 등록(`project_id/code_root/docs_root/repo_remote/default_branch`)이다.
3. 등록된 프로젝트는 `docs_root` 아래 `README.md`, `task.md`, `PROJECT_AGENT.md`, `meeting-notes/README.md`를 유지한다.
4. 외부 제품 레포가 있는 경우 sidecar 문서와 함께 `Repository (GitHub)` 링크를 병기한다.

## Projects
- [ticket-core-service](./ticket-core-service/README.md)
- [ticket-web-client](./ticket-web-client/README.md)
- [ticket-web-app](./ticket-web-app/README.md)

## Operations Reference
- [Sidecar Operations Runbook](/prj-docs/references/sidecar-operations-runbook.md)
