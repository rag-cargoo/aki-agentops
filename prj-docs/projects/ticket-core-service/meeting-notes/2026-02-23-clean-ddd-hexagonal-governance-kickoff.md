# Meeting Notes: Clean DDD/Hexagonal Governance Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 07:30:00`
> - **Updated At**: `2026-02-23 07:35:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 스킬 적용/우선순위
> - 안건 3: 진행 순서 고정
> - 안건 4: 1차 구현 범위
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - 현재 코드베이스는 DDD-lite 상태이며 경계 위반(`domain -> api`, `controller -> repository`)이 일부 존재한다.
  - 대공사 성격의 구조 정리는 거버넌스 선행(회의록/태스크/이슈) 없이 진행하지 않는다.

## 안건 2: 스킬 적용/우선순위
- Status: DONE
- 결정:
  - `clean-ddd-hexagonal` 스킬을 설치하고 이번 아키텍처 정리의 delegated 규칙으로 사용한다.
  - 규칙 우선순위는 아래로 고정한다.
    - `AGENTS.md` -> `aki-*` -> `PROJECT_AGENT.md` 위임 규칙 -> 외부 스킬 본문

## 안건 3: 진행 순서 고정
- Status: DONE
- 순서:
  - `회의록 -> task -> 제품 이슈 -> 코드 변경` 순서를 강제한다.
  - 구조 변경은 완료 후 회귀 테스트와 문서 동기화를 동반한다.

## 안건 4: 1차 구현 범위
- Status: DOING
- 범위:
  - `domain` 엔티티의 `api` 의존 제거
  - `api.controller`의 `*Repository` 직접 참조 제거
  - 아키텍처 테스트(ArchUnit) 도입으로 경계 규칙 CI 강제
- 비범위(Phase 2):
  - `domain service` 전반의 API DTO 의존 제거
  - application/use-case 계층 전면 도입

## 안건 5: 트래킹
- Status: DOING
- Product Tracking:
  - `rag-cargoo/ticket-core-service#33` (open, cross-repo shorthand)
  - `rag-cargoo/ticket-core-service PR #34` (open, cross-repo shorthand)
- Sidecar Tracking:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`를 기준으로 진행 상태를 관리한다.

## 증빙
- Skill Install:
  - `.agents/skills/clean-ddd-hexagonal/SKILL.md`
  - `skills-lock.json`
- Governance:
  - `prj-docs/projects/ticket-core-service/PROJECT_AGENT.md`
  - `prj-docs/projects/ticket-core-service/task.md`
