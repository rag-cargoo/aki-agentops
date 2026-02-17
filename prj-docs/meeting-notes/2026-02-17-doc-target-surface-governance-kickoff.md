# Meeting Notes: Document Target/Surface Governance Kickoff

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 09:37:07`
> - **Updated At**: `2026-02-17 11:22:41`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Mandatory Runtime Gate
> - External Sync
> - 안건 1: 문제정의(문서 대상 혼재)
> - 안건 2: 메타 스키마(Target/Surface) 확정
> - 안건 3: 적용 전략(인벤토리/노출 정책)
<!-- DOC_TOC_END -->

## Mandatory Runtime Gate
- Checked At: 2026-02-17 09:37:07
- `session_start.sh`: PASS
- `mcp_toolset(context/repos/issues/projects/pull_requests/labels)`: PASS
- `validate-precommit-chain.sh`: PASS
- Evidence:
  - command:
    - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
    - `mcp__github__list_available_toolsets`
    - `bash skills/aki-codex-precommit/scripts/validate-precommit-chain.sh --mode quick --all`
  - result:
    - Active Project `workspace/apps/backend/ticket-core-service (OK)`
    - GitHub MCP 기본 6개 toolset enabled 확인
    - precommit quick chain 통과

## External Sync
- Source of Truth: `rag-cargoo/aki-agentops` issue `#79`
- Sync Action: issue-comment + task-update + readme-update
- Last Synced At: 2026-02-17 11:22:41

## 안건 1: 문제정의(문서 대상 혼재)
- Created At: 2026-02-17 09:37:07
- Updated At: 2026-02-17 09:37:07
- Status: DONE
- 결정사항:
  - 현재 문서 메타는 `Created At/Updated At`만 관리되어, 문서가 `AGENT/HUMAN/BOTH` 중 누구를 대상으로 하는지 구조적으로 드러나지 않는다.
  - GitHub Pages 사이드바가 단일 목록이라 사용자 중심 탐색과 운영/에이전트 문서가 섞여 있다.
- 후속작업:
  - 담당: User + Codex
  - 기한: 2026-02-17
  - 상태: DONE
  - 메모: 메타 스키마 및 노출 정책 정의를 즉시 진행한다.

## 안건 2: 메타 스키마(Target/Surface) 확정
- Created At: 2026-02-17 09:37:07
- Updated At: 2026-02-17 09:37:07
- Status: DONE
- 결정사항:
  - 문서 메타에 `Target`과 `Surface`를 추가한다.
  - `Target` enum:
    - `HUMAN`
    - `AGENT`
    - `BOTH`
    - `FUTURE:<group>`
  - `Surface` enum:
    - `PUBLIC_NAV` (사용자 기본 사이드바 노출)
    - `AGENT_NAV` (에이전트 전용 내비게이션 노출)
    - `HIDDEN` (내비게이션 비노출)
  - `Surface`는 "메뉴 노출 정책"이며, 저장소/Pages가 public이면 `HIDDEN`이어도 URL 직접 접근 가능함을 명시한다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-02-17
  - 상태: DONE
  - 메모: 정책 문서 `prj-docs/references/document-target-surface-governance.md`에 스키마를 기록한다.

## 안건 3: 적용 전략(인벤토리/노출 정책)
- Created At: 2026-02-17 09:37:07
- Updated At: 2026-02-17 11:22:41
- Status: DOING
- 결정사항:
  - 1차: 정책/스키마 정의 + 루트 task/이슈 등록.
  - 2차: 전 문서 인벤토리 분류(`Target/Surface`)와 분류 근거 리포트 생성.
  - 3차: 사이드바 노출을 `PUBLIC_NAV` 중심으로 재구성하고 `AGENT_NAV` 분리 전략 적용.
  - 4차: pre-commit lint 게이트 도입(`Target/Surface` 누락/허용값 위반/노출 충돌 검사).
- 후속작업:
  - 담당: User + Codex
  - 기한: 2026-02-20
  - 상태: DOING
  - 메모: `TSK-2602-018`(인벤토리+메뉴 분리)은 완료했고, 잔여는 `TSK-2602-019`(lint 게이트 도입)이다.
