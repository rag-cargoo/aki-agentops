# AKI AgentOps Workspace Repository Guide

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-17 17:14:21`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Project Overview
> - Primary Use Cases
> - Quick Start
> - Repository Boundaries
> - GitHub Pages Home
> - Navigation Modes
> - 상위 영역 맵 (Top-Level Domains)
> - 프로젝트 분류 (Workspace Classification)
> - 권장 디렉터리 스케치 (Infra)
> - 프로젝트 진입 링크
> - 운영 문서 바로가기
> - 레거시 표기 마이그레이션 노트
> - 유지 원칙 (README Scope)
<!-- DOC_TOC_END -->

---

## Project Overview

이 저장소는 `AKI AgentOps` 운영 허브입니다.
멀티 프로젝트 워크스페이스에서 세션 규칙, 스킬 자동화, 문서 거버넌스, 사이드카 문서 체계를 관리합니다.

> [!NOTE]
> - Previous Repository Slug: `2602`
> - Current Repository Slug: `aki-agentops` (renamed on 2026-02-17)

## Primary Use Cases

- 세션 시작 표준화: `AGENTS.md` 기반 로드/검증 자동화
- 프로젝트 경계 관리: 제품 코드 레포와 운영/거버넌스 레포 분리
- 문서 동기화 운영: 회의록/태스크/이슈/PR 연계와 strict-remote 검증
- 내비게이션 허브 제공: Docsify 기반 루트 탐색 엔트리 운영

## Quick Start

```bash
git status --short
git branch --show-current
./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh
bash skills/aki-codex-precommit/scripts/validate-precommit-chain.sh --mode quick --all
```

멀티 프로젝트에서 Active Project가 비어 있으면 아래를 먼저 실행합니다.

```bash
./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh <project-root>
```

## Repository Boundaries

- 이 저장소(`AKI AgentOps`)가 관리하는 것:
  - `skills/`, `mcp/`, 루트 거버넌스 문서, sidecar docs 매핑
- 외부 제품 레포가 관리하는 것:
  - 실제 앱 코드, 제품 단위 빌드/테스트/배포 파이프라인
- sidecar 문서(`prj-docs/projects/<project-id>/`)는 운영 기록이며, 제품 소스코드 저장소와 분리 유지합니다.

---

## GitHub Pages Home

- URL: [https://rag-cargoo.github.io/aki-agentops/](https://rag-cargoo.github.io/aki-agentops/)
- Main Test URL (U1, Local): [http://localhost:8080/ux/u1/index.html](http://localhost:8080/ux/u1/index.html)

URL은 현재 워크스페이스 문서 허브(Docsify) 메인 페이지입니다.
README, SKILLS, WORKSPACE 문서를 한 곳에서 탐색할 때 사용합니다.
U1 테스트 URL은 로컬 백엔드 실행 상태에서 확인할 수 있습니다.

## Navigation Modes

- Public Navigation (기본): [https://rag-cargoo.github.io/aki-agentops/](https://rag-cargoo.github.io/aki-agentops/)
- Agent Navigation: [https://rag-cargoo.github.io/aki-agentops/?surface=agent#/AGENTS.md](https://rag-cargoo.github.io/aki-agentops/?surface=agent#/AGENTS.md)
- 참고: `surface`는 메뉴 노출 정책이며 접근제어가 아닙니다.

---

이 README는 `AKI AgentOps` 루트 저장소 관점에서 **전체 워크스페이스 구조**를 안내합니다.
실제 제품 코드는 각 독립 레포에서 관리하며, `skills/`와 `mcp/`는 운영/자동화 문서 영역으로 분리되어 있습니다.

---

## 상위 영역 맵 (Top-Level Domains)

- `skills/`: 전역 규칙, 자동화, 운영 가이드
- `workspace/`: 실제 제품/서비스 프로젝트 구현 영역
- `mcp/`: MCP 런타임 운영 문서 및 매니페스트
- `prj-docs/`: AKI AgentOps 루트 레벨 회의록/거버넌스 문서

---

## 프로젝트 분류 (Workspace Classification)

> [!NOTE]
> 아래 분류는 "현재 + 향후 확장" 기준의 표준 트리입니다.

### 1. Apps
- Backend
  - Ticket Core Service (`진행중`)
    - 프로젝트 저장소: [rag-cargoo/ticket-core-service](https://github.com/rag-cargoo/ticket-core-service)
    - Sidecar Docs (AKI AgentOps): [Ticket Core Service Sidecar Docs](/prj-docs/projects/ticket-core-service/README.md)
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
> 각 프로젝트의 소개/실행 방법은 제품 레포 또는 sidecar 문서에서 관리합니다.

- [Ticket Core Service Repository](https://github.com/rag-cargoo/ticket-core-service)
- [Ticket Core Service Sidecar Docs](/prj-docs/projects/ticket-core-service/README.md)

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

### AKI AgentOps Repository
- [AKI AgentOps Meeting Notes Index](/prj-docs/meeting-notes/README.md)
- [AKI AgentOps Task Dashboard](/prj-docs/task.md)
- [Project Sidecar Index](/prj-docs/projects/README.md)
- [Repository Architecture Gap Map](/prj-docs/references/repo-architecture-gap-map.md)
- [Sidecar Operations Runbook](/prj-docs/references/sidecar-operations-runbook.md)
- [Document Target/Surface Governance](/prj-docs/references/document-target-surface-governance.md)
- [Document Target/Surface Inventory (2026-02-17)](/prj-docs/references/document-target-surface-inventory-2026-02-17.md)

## 레거시 표기 마이그레이션 노트

- [Repository Rename Migration Note](/prj-docs/references/repository-rename-migration-note.md)
- [Legacy Label Cleanup Report (2026-02-17)](/prj-docs/references/legacy-label-cleanup-report-2026-02-17.md)

---

## 유지 원칙 (README Scope)

- 루트 `README.md`는 저장소 전체 분류/진입점만 다룹니다.
- 프로젝트 상세 구현/실험 내역은 각 제품 레포 또는 sidecar `prj-docs/projects/<project-id>/`에서 관리합니다.
- 루트 `prj-docs/`는 AKI AgentOps 공통 구조/거버넌스 논의와 회의록만 관리합니다.
- 신규 프로젝트가 생기면 `Apps|Agent Skills|Infra` 분류 아래에 상태(`진행중/예정`)와 대표 문서 링크를 등록합니다.
