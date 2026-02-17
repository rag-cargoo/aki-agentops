# Meeting Notes: MCP-Only GitHub Sync Workflow

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 07:13:21`
> - **Updated At**: `2026-02-17 17:28:03`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: GitHub MCP 기본 프로필 확장
> - 안건 2: 회의록 기반 이슈/PR 동기화 운영
> - 안건 3: 즉시 실행 항목
<!-- DOC_TOC_END -->

## 안건 1: GitHub MCP 기본 프로필 확장
- Created At: 2026-02-09 07:13:21
- Updated At: 2026-02-09 07:13:21
- Status: DONE
- 결정사항:
  - 세션 시작 기본 toolset을 `context,repos,issues,projects,pull_requests,labels`로 확정한다.
  - 회의록 기반 운영에서 필요한 PR/라벨 기능을 기본 부팅 대상에 포함한다.
- 후속작업:
  - 담당: Agent
  - 기한: 2026-02-09
  - 상태: DONE

## 안건 2: 회의록 기반 이슈/PR 동기화 운영
- Created At: 2026-02-09 07:13:21
- Updated At: 2026-02-09 07:13:21
- Status: DONE
- 결정사항:
  - (현행 기준) `aki-mcp-github` 스킬의 `meeting-notes-sync` flow를 MCP-only 방식으로 운영한다.
  - local fallback 없이 GitHub MCP로 이슈/프로젝트/PR/라벨까지 동기화한다.
  - 회의록 원문에는 생성된 Issue/PR 링크를 역기록한다.
- 후속작업:
  - 담당: Agent
  - 기한: 2026-02-09
  - 상태: DONE

## 안건 3: 즉시 실행 항목
- Created At: 2026-02-09 07:13:21
- Updated At: 2026-02-09 07:13:21
- Status: DOING
- 결정사항:
  - 다음 실제 회의록 1건에 대해 `aki-mcp-github`의 `meeting-notes-sync` flow를 실행해 이슈/PR 동기화를 실증한다.
  - 실행 결과(생성/갱신 이슈, PR, 프로젝트 반영, 실패 항목)를 회의록에 기록한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DOING
