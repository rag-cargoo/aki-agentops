#  홍구 Workspace Repository Guide

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-09 00:46:36`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 상위 영역 맵 (Top-Level Domains)
> - 프로젝트 분류 (Workspace Classification)
> - 권장 디렉터리 스케치 (Infra/Manifests)
> - 프로젝트 진입 링크
> - 운영 문서 바로가기
> - 유지 원칙 (README Scope)
<!-- DOC_TOC_END -->

이 README는 루트 저장소 관점에서 **전체 워크스페이스 구조**를 안내합니다.
현재 구현이 진행된 서비스는 `workspace/apps/backend/ticket-core-service`이며, `skills/`와 `mcp/`는 운영/자동화 문서 영역으로 분리되어 있습니다.

---

## 상위 영역 맵 (Top-Level Domains)

- `skills/`: 전역 규칙, 자동화, 운영 가이드
- `workspace/`: 실제 제품/서비스 프로젝트 구현 영역
- `mcp/`: MCP 런타임 운영 문서 및 매니페스트

---

## 프로젝트 분류 (Workspace Classification)

> [!NOTE]
> 아래 분류는 "현재 + 향후 확장" 기준의 표준 트리입니다.

### 1. Apps
- Backend
  - Ticket Core Service (`진행중`)
    - 프로젝트 README: [Ticket Core Service README](/workspace/apps/backend/ticket-core-service/README.md)

### 2. Infra
- IaC
  - Terraform (`예정`)
  - Ansible (`예정`)
- Container Runtime
  - Docker (`예정`)
- Container Orchestration
  - Kubernetes
    - kind (`예정`)
    - aws-eks (`예정`)
    - Manifests
      - base (`예정`)
      - overlays/kind (`예정`)
      - overlays/aws-eks (`예정`)
- App Release
  - Manifests (`예정`)

---

## 권장 디렉터리 스케치 (Infra/Manifests)

```text
workspace/
  infra/
    iac/
      terraform/
      ansible/
    container/
      docker/
    kubernetes/
      kind/
      aws-eks/
  manifests/
    kubernetes/
      base/
      overlays/
        kind/
        aws-eks/
    apps/
```

---

## 프로젝트 진입 링크

> [!TIP]
> 각 프로젝트의 소개/실행 방법은 프로젝트 루트 README에서 관리합니다.

- [Ticket Core Service README](/workspace/apps/backend/ticket-core-service/README.md)

---

## 운영 문서 바로가기

### SKILLS
- [Workflow](/skills/workspace-governance/references/WORKFLOW.md)
- [Structure & Standards](/skills/workspace-governance/references/STRUCTURE.md)
- [Operations & Automation](/skills/workspace-governance/references/OPERATIONS.md)
- [GitHub Pages 배포 가이드](/skills/workspace-governance/references/guides/docsify-setup.md)

### MCP
- [MCP Workspace Guide](/mcp/README.md)
- [MCP Manifest](/mcp/manifest/mcp-manifest.md)
- [MCP TODO](/mcp/TODO.md)
- [MCP Experience Log](/mcp/references/experience-log.md)

---

## 유지 원칙 (README Scope)

- 루트 `README.md`는 저장소 전체 분류/진입점만 다룹니다.
- 프로젝트 상세 구현/실험 내역은 각 프로젝트의 `prj-docs/`에서 관리합니다.
- 신규 프로젝트가 생기면 `Apps|Infra` 분류 아래에 상태(`진행중/예정`)와 대표 문서 링크를 등록합니다.
- `workspace/manifests`는 Infra 배포 산출물 저장 루트로 관리합니다.
