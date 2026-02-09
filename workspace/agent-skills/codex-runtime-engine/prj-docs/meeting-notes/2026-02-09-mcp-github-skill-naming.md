# Meeting Notes: MCP GitHub Skill Naming

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 19:25:59`
> - **Updated At**: `2026-02-09 19:29:03`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: MCP GitHub 스킬 네이밍 방향
> - 안건 2: 스킬 분해 수준과 references 구성
> - 안건 3: 용어 통일 및 실행 시점
<!-- DOC_TOC_END -->

## 안건 1: MCP GitHub 스킬 네이밍 방향
- Created At: 2026-02-09 19:25:59
- Updated At: 2026-02-09 19:25:59
- Status: DONE
- 결정사항:
  - GitHub MCP 관련 운영은 `aki-mcp-github` 중심으로 명칭을 정렬한다.
  - 기존 기능명이 모호한 경우, 우선 허브 명칭을 명확히 하고 세부 흐름은 문서로 분리한다.
  - 목적은 "이름만 보고 역할을 즉시 이해"할 수 있게 하는 것이다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: TODO
  - 이슈: https://github.com/rag-cargoo/2602/issues/17

## 안건 2: 스킬 분해 수준과 references 구성
- Created At: 2026-02-09 19:25:59
- Updated At: 2026-02-09 19:25:59
- Status: DONE
- 결정사항:
  - 당장은 스킬을 4개로 분해하지 않고 단일 스킬 `aki-mcp-github`로 운영한다.
  - 초기 설정/회의록 연동/이슈-PR 흐름은 `references` 문서로 분류해 관리한다.
  - 필요 시(규모 증가, 트리거 충돌, 변경 주기 분리) 후속 분해를 검토한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: TODO
  - 이슈: https://github.com/rag-cargoo/2602/issues/17

## 안건 3: 용어 통일 및 실행 시점
- Created At: 2026-02-09 19:25:59
- Updated At: 2026-02-09 19:25:59
- Status: DONE
- 결정사항:
  - `bootstrap`, `setup`, `install` 혼용 대신 `init` 용어로 통일한다.
  - `init` 범위는 최초 1회 준비(설치/설정/인증/검증)를 포괄한다.
  - 실제 리네이밍/구조 반영 작업은 이번 회의 후속으로 별도 진행한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: TODO
  - 이슈: https://github.com/rag-cargoo/2602/issues/17
  - 비고: 이번 요청 범위는 회의록 작성까지이며, 실행 작업은 보류한다.
