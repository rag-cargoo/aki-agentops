#  홍구 Workspace Repository Guide

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-09 00:18:34`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 저장소 구성 (Repository Map)
> - 현재 활성 프로젝트 (Current Active Project)
> - 빠른 시작 (Ticket Core Service)
> - 운영 원칙 (README Scope)
<!-- DOC_TOC_END -->

이 README는 루트 저장소 관점에서 **전체 워크스페이스 구조**를 안내합니다.
현재 구현이 진행된 서비스는 `workspace/apps/backend/ticket-core-service`이며, `skills/`와 `mcp/`는 운영/자동화 문서 영역으로 분리되어 있습니다.

---

## 저장소 구성 (Repository Map)

### 1. SKILLS (전역 규칙/자동화)
- [Workflow](/skills/workspace-governance/references/WORKFLOW.md)
- [Structure & Standards](/skills/workspace-governance/references/STRUCTURE.md)
- [Operations & Automation](/skills/workspace-governance/references/OPERATIONS.md)
- [GitHub Pages 배포 가이드](/skills/workspace-governance/references/guides/docsify-setup.md)

### 2. WORKSPACE (프로젝트 구현 영역)
- `workspace/apps/backend/ticket-core-service`
- [Project Agent Scope](/workspace/apps/backend/ticket-core-service/prj-docs/PROJECT_AGENT.md)
- [Current Tasks](/workspace/apps/backend/ticket-core-service/prj-docs/task.md)
- [Roadmap](/workspace/apps/backend/ticket-core-service/prj-docs/ROADMAP.md)
- [Architecture](/workspace/apps/backend/ticket-core-service/prj-docs/rules/architecture.md)
- [Reservation API](/workspace/apps/backend/ticket-core-service/prj-docs/api-specs/reservation-api.md)

### 3. MCP (런타임 운영 문서)
- [MCP Workspace Guide](/mcp/README.md)
- [MCP Manifest](/mcp/manifest/mcp-manifest.md)
- [MCP TODO](/mcp/TODO.md)
- [MCP Experience Log](/mcp/references/experience-log.md)

---

## 현재 활성 프로젝트 (Current Active Project)

> [!NOTE]
> - **프로젝트 경로**: `workspace/apps/backend/ticket-core-service`
> - **상태**: 동시성 제어 + 대기열 + SSE 실시간 순번 자동 푸시까지 구현 완료
> - **핵심 스택**: Java 17, Spring Boot 3.4.1, PostgreSQL, Redis, Kafka
> - **상세 구현/실험 기록**: 프로젝트 문서(`prj-docs/`)에서 관리

대표 문서:
- [Project Task Dashboard](/workspace/apps/backend/ticket-core-service/prj-docs/task.md)
- [Concurrency Strategy Knowledge](/workspace/apps/backend/ticket-core-service/prj-docs/knowledge/동시성-제어-전략.md)
- [API Test Guide](/workspace/apps/backend/ticket-core-service/prj-docs/api-test/README.md)

---

## 빠른 시작 (Ticket Core Service)

### 1. 인프라 실행
```bash
docker-compose up -d
```

### 2. 서버 실행
```bash
cd workspace/apps/backend/ticket-core-service
./gradlew bootRun --args='--spring.profiles.active=local'
```

### 3. API 스크립트 테스트
```bash
cd workspace/apps/backend/ticket-core-service
make test-suite
```

---

## 운영 원칙 (README Scope)

- 루트 `README.md`는 저장소 전체 관점의 안내 문서입니다.
- 프로젝트 상세 구현/검증/실험 내역은 각 프로젝트의 `prj-docs/`에서 관리합니다.
- 신규 프로젝트가 추가되면 본 문서의 `WORKSPACE` 섹션에 동일 포맷으로 경로와 대표 문서를 등록합니다.
