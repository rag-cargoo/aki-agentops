# Task Dashboard (ticket-core-service sidecar)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 05:11:38`
> - **Updated At**: `2026-02-17 21:07:43`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Current Items
<!-- DOC_TOC_END -->

## Scope
- 이 문서는 `ticket-core-service` 운영 sidecar 태스크를 관리한다.
- 구현 상세 태스크는 제품 레포 이슈/PR에서 관리한다.

## Current Items
- TCS-SC-001 외부 레포 분리 전환 운영 확인
  - Status: DONE
  - Description: code_root, docs_root, repo_remote가 `project-map.yaml`과 일치하는지 점검
  - Evidence:
    - `project-map.yaml`에 `workspace/apps/backend/ticket-core-service` + `prj-docs/projects/ticket-core-service` + `https://github.com/rag-cargoo/ticket-core-service`
    - `session_start.sh` 출력에서 Active Project `Docs Root: prj-docs/projects/ticket-core-service` 확인
    - PR `#65` merged (`2026-02-16`) 및 연계 이슈 `#66` closed

- TCS-SC-002 sidecar 분리 이후 제품 레포 문서 SoT 중복 정리
  - Status: DOING
  - Description:
    - sidecar 분리는 완료됐지만 제품 레포(`ticket-core-service`) 내부 `prj-docs`가 남아 운영 문서 SoT가 중복된 상태를 정리
    - 제품 레포 문서 유지 정책(전부 제거 vs 최소 유지)을 확정하고 경로 참조를 일관화
  - Evidence:
    - 회의록: `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-17-sidecar-sot-dedup-followup.md`
    - AKI AgentOps 이슈 재오픈: `https://github.com/rag-cargoo/aki-agentops/issues/66`
    - 제품 레포 이슈 생성: `https://github.com/rag-cargoo/ticket-core-service/issues/1`
