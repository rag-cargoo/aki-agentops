# Server Build Test Sidecar Docs

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-04-28 00:06:47`
> - **Updated At**: `2026-04-28 00:06:47`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Source of Truth
> - Sidecar Docs
> - Assignment Scope
> - Lab Baseline
<!-- DOC_TOC_END -->

## Source of Truth
- Local Root: `workspace/infra/airgap/kubernetes/airgap-k8s`
- Repository: `rag-cargoo/airgap-k8s`

## Sidecar Docs
- Project AGENTS: `workspace/infra/airgap/kubernetes/airgap-k8s/AGENTS.md`
- Submission Manual Overview: `workspace/infra/airgap/kubernetes/airgap-k8s/manual/00-제출-매뉴얼-개요/README.md`
- Submission Manual Directory: `workspace/infra/airgap/kubernetes/airgap-k8s/manual/`
- Current Manual Chapters: `workspace/infra/airgap/kubernetes/airgap-k8s/manual/01-인터넷-불가능-네트워크-환경-및-리눅스-기본-구성/` ... `workspace/infra/airgap/kubernetes/airgap-k8s/manual/06-제출/`
- Manual/Task Governance: `./rules/manual-task-governance.md`
- Root Makefile: `workspace/infra/airgap/kubernetes/airgap-k8s/Makefile`
- Terraform Code: `workspace/infra/airgap/kubernetes/airgap-k8s/ops/01-airgap-linux-environment/aws-terraform-simulation/`
- [Task Dashboard](./task.md)
- [Task Files Index](./tasks/README.md)
- [Meeting Notes Index](./meeting-notes/README.md)
- [Project Agent](./PROJECT_AGENT.md)
- [Architecture Rule](./rules/architecture.md)
- [AWS Air-Gap Simulation Baseline](./rules/aws-airgap-simulation-baseline.md)

## Assignment Scope
- 과제 원문은 `workspace/infra/airgap/kubernetes/airgap-k8s/ASSIGNMENT.md`를 기준으로 사용한다.
- `주제`는 제출 매뉴얼 개요에 포함하고, 실제 구축 장은 ClickUp `내용` 작업 순서에 맞춘다.
- sidecar는 진행 체크, 규칙, 회의 기록만 관리한다.
- 이전 `airgap-k8s` 초안 결과물은 제거했고, 이 경로에서 최소 구조로 다시 시작한다.

## Lab Baseline
- AWS는 하드웨어 대체 실습 환경으로만 사용한다.
- 실제 설치/배포 절차는 `온프레미스 폐쇄망과 동일한 오프라인 기준`으로 유지한다.
- Terraform은 네트워크와 서버 골격 재현용으로 사용하고, 서비스 설치 절차는 별도 매뉴얼로 관리한다.
