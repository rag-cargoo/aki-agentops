# Meeting Notes: GitHub Pages Structure Governance Planning

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 17:58:10`
> - **Updated At**: `2026-02-17 18:00:15`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Mandatory Runtime Gate
> - External Sync
> - 안건 1: 문제정의(루트 Pages 아티팩트 혼재)
> - 안건 2: 경계 규칙(명명 vs 배포 제약) 확정
> - 안건 3: 실행 관리(회의록/태스크/이슈 동기화)
<!-- DOC_TOC_END -->

## Mandatory Runtime Gate
- Checked At: 2026-02-17 17:58:10
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
    - GitHub MCP 기본 6개 toolset `currently_enabled=true` 확인
    - precommit quick chain 통과

## External Sync
- Source of Truth: `https://github.com/rag-cargoo/aki-agentops/issues/79`
- Sync Action: issue-comment + task-update
- Last Synced At: 2026-02-17 18:00:15

## 안건 1: 문제정의(루트 Pages 아티팩트 혼재)
- Created At: 2026-02-17 17:58:10
- Updated At: 2026-02-17 17:58:10
- Status: DONE
- 결정사항:
  - 루트에 `index.html`, `HOME.md`, `sidebar-manifest.md`, `sidebar-agent-manifest.md`가 공존해 저장소 top-level 가독성을 떨어뜨린다.
  - 파일 역할이 Pages 런타임 전용인지 일반 운영 문서인지 경계가 명확하지 않아 유지보수 비용이 증가한다.
- 후속작업:
  - 담당: User + Codex
  - 기한: 2026-02-18
  - 상태: DONE
  - 메모: `TSK-2602-020`으로 구조 정리 트랙을 신규 등록한다.

## 안건 2: 경계 규칙(명명 vs 배포 제약) 확정
- Created At: 2026-02-17 17:58:10
- Updated At: 2026-02-17 17:58:10
- Status: DONE
- 결정사항:
  - 문서/디렉터리 명명은 `github-pages/`가 목적상 더 명확하므로 해당 명명을 채택한다.
  - 단, 현재 Pages 설정이 `main:/`(legacy)이므로 `.nojekyll`은 배포 루트 유지가 필요하다.
  - 이동 전략은 Pages 소스 제약과 스크립트 의존성(`core-workspace`, lint, validator)을 함께 고려해 결정한다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-02-18
  - 상태: DOING
  - 메모: 호환 레이어 포함 이행안(루트 최소화 + 경로 참조 전환)을 작성하고 검증한다.

## 안건 3: 실행 관리(회의록/태스크/이슈 동기화)
- Created At: 2026-02-17 17:58:10
- Updated At: 2026-02-17 17:58:10
- Status: DOING
- 결정사항:
  - 신규 범위는 기존 umbrella 이슈 `#79`에 누적 관리한다(동일 거버넌스 범위).
  - 실행 단위는 `task.md`의 `TSK-2602-020`으로 추적하고, 구현 PR은 해당 이슈와 링크한다.
  - 상태 전환은 `회의록 -> task -> issue comment` 순서로 기록한다.
  - 기준 PR: `https://github.com/rag-cargoo/aki-agentops/pull/90`
- 후속작업:
  - 담당: User + Codex
  - 기한: 2026-02-18
  - 상태: DOING
  - 메모: 이행 시작 시 issue `#79`에 결정사항과 작업 브랜치를 코멘트로 동기화한다.
