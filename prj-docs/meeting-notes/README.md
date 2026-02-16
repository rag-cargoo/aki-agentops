# Meeting Notes Index (AKI AgentOps)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 04:24:00`
> - **Updated At**: `2026-02-17 08:40:03`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Purpose
> - Naming Convention
> - Scope Boundary
> - Mandatory Runtime Gate
> - External Sync Contract
> - Current Notes
> - Template
<!-- DOC_TOC_END -->

## Purpose
- `AKI AgentOps` 저장소 루트 관점의 구조/거버넌스 이슈를 날짜별로 기록한다.
- 하위 프로젝트 구현 상세는 각 프로젝트 `prj-docs/` 문서에서 계속 관리한다.

## Naming Convention
- 파일명 규칙: `YYYY-MM-DD-topic.md`

## Scope Boundary
- 포함:
  - 루트 저장소 구조/분류/문서 탐색 체계
  - 공통 운영 규칙(이슈/브랜치/동기화 체계)
  - 다중 프로젝트 간 경계/역할 정렬
- 제외:
  - 특정 앱 기능 구현 상세/코드 레벨 변경 내역
  - 프로젝트 단위 API/테스트 결과 상세

## Mandatory Runtime Gate
- 모든 안건은 상태 전환(`TODO -> DOING`, `DOING -> DONE`)마다 아래 게이트를 필수 체크한다.
  - `session_start.sh` 성공 및 Active Project 로드 확인
  - GitHub MCP 기본 toolset(`context/repos/issues/projects/pull_requests/labels`) 활성 확인
  - `validate-precommit-chain.sh` 실행 가능 상태 확인
- 게이트 실패 시 해당 안건은 `BLOCKED`로 기록하고 원인/복구조치를 남긴다.

## External Sync Contract
- sidecar 문서에서 외부 공유가 필요한 결정은 대상 제품 레포 이슈/PR 링크를 반드시 남긴다.
- 문서 상단에 `source-of-truth`를 명시하고, sidecar 보관본은 운영 기록으로 사용한다.
- 회의 안건이 제품 동작/릴리즈에 영향을 주면 `Sync Action`(이슈 코멘트/PR 코멘트/README 반영)을 기록한다.

## Current Notes
- [2026-02-17 Repository Architecture Refactoring Agenda](./2026-02-17-repo-architecture-refactoring-agenda.md)
- [2026-02-17 Repo Rename and README Governance Planning](./2026-02-17-repo-rename-readme-governance-planning.md)

## Template
```md
# Meeting Notes: <title>

## Mandatory Runtime Gate
- Checked At: YYYY-MM-DD HH:MM:SS
- `session_start.sh`: PASS | FAIL
- `mcp_toolset(context/repos/issues/projects/pull_requests/labels)`: PASS | FAIL
- `validate-precommit-chain.sh`: PASS | FAIL
- Evidence:
  - command:
  - result:

## External Sync
- Source of Truth: <owner/repo + issue/pr/link>
- Sync Action: not-required | issue-comment | pr-comment | readme-update
- Last Synced At: YYYY-MM-DD HH:MM:SS

## 안건 1: <주제>
- Created At: YYYY-MM-DD HH:MM:SS
- Updated At: YYYY-MM-DD HH:MM:SS
- Status: TODO | DOING | DONE | BLOCKED
- 결정사항:
- 후속작업:
  - 담당:
  - 기한:
  - 상태: TODO | DOING | DONE | BLOCKED
```
