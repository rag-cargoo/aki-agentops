#  홍구 Workspace Repository Guide

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-15 18:23:00`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - GitHub Pages Home
> - 상위 영역 맵 (Top-Level Domains)
> - 프로젝트 분류 (Workspace Classification)
> - 권장 디렉터리 스케치 (Infra)
> - 프로젝트 진입 링크
> - 운영 문서 바로가기
> - 유지 원칙 (README Scope)
<!-- DOC_TOC_END -->

---

## GitHub Pages Home

- URL: `https://rag-cargoo.github.io/2602/`
- Open: [https://rag-cargoo.github.io/2602/](https://rag-cargoo.github.io/2602/)
- Main Test URL (U1): `http://localhost:8080/ux/u1/index.html`
- Legacy Redirect URL (U1): `http://localhost:8080/u1/index.html`

이 링크는 현재 워크스페이스 문서 허브(Docsify) 메인 페이지입니다.
README, SKILLS, WORKSPACE 문서를 한 곳에서 탐색할 때 사용합니다.
U1 테스트 URL은 로컬 백엔드 실행 상태에서 확인할 수 있습니다.

---

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
    - UI/UX 테스트 페이지 (U1, Local): [http://localhost:8080/ux/u1/index.html](http://localhost:8080/ux/u1/index.html)

### 2. Agent Skills
- Codex Runtime Engine (`진행중`)
  - 프로젝트 README: [Codex Runtime Engine README](/workspace/agent-skills/codex-runtime-engine/README.md)

### 3. Infra
- IaC
  - Terraform (`예정`)
  - Ansible (`예정`)
- Container Runtime
  - Docker (`예정`)
- Container Orchestration
  - Kubernetes
    - kind (`예정`)
    - aws-eks (`예정`)
- App Release
  - Helm (`예정`)
  - Deployment Specs (`예정`)

---

## 권장 디렉터리 스케치 (Infra)

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
      base/
      overlays/
        kind/
        aws-eks/
    release/
      helm/
```

---

## 프로젝트 진입 링크

> [!TIP]
> 각 프로젝트의 소개/실행 방법은 프로젝트 루트 README에서 관리합니다.

- [Ticket Core Service README](/workspace/apps/backend/ticket-core-service/README.md)

---

## 운영 문서 바로가기

### SKILLS
- [Workflow](/skills/aki-codex-core/references/WORKFLOW.md)
- [Structure & Standards](/skills/aki-codex-core/references/STRUCTURE.md)
- [Operations & Automation](/skills/aki-codex-core/references/OPERATIONS.md)
- [Aki Skills User Prompt Guide](/skills/aki-codex-workflows/references/aki-skills-user-prompt-guide.md)
- [GitHub Pages 배포 가이드](/skills/aki-github-pages-expert/references/docsify-setup.md)

### MCP
- [MCP Workspace Guide](/mcp/README.md)
- [MCP Manifest](/mcp/manifest/mcp-manifest.md)
- [MCP TODO](/mcp/TODO.md)
- [MCP Experience Log](/mcp/references/experience-log.md)

---

## 유지 원칙 (README Scope)

- 루트 `README.md`는 저장소 전체 분류/진입점만 다룹니다.
- 프로젝트 상세 구현/실험 내역은 각 프로젝트의 `prj-docs/`에서 관리합니다.
- 신규 프로젝트가 생기면 `Apps|Agent Skills|Infra` 분류 아래에 상태(`진행중/예정`)와 대표 문서 링크를 등록합니다.
