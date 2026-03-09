# Codex Skills Reload Runtime

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-19 15:55:00`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scripts
> - Notes
<!-- DOC_TOC_END -->

`skills/aki-codex-session-reload/scripts/codex_skills_reload/`는 리로드 로직의 실제 구현 디렉토리다.

## Scripts
1. `session_start.sh` - 단일 진입 리로드 및 상태 보고 문서 생성
2. `skills_reload.sh` - 스킬 목록 스냅샷 생성
3. `project_reload.sh` - 활성 프로젝트 스냅샷 생성
4. `set_active_project.sh` - 활성 프로젝트 지정/조회
5. `init_project_docs.sh` - 신규 프로젝트 기준선 문서(`README.md`, `PROJECT_AGENT.md`, `task.md`, `meeting-notes/README.md`)와 `prj-docs/rules/` 디렉토리 생성
6. `validate_env.sh` - `.codex/runtime`/`.githooks`/실행권한 상태 점검
7. `bootstrap_env.sh` - 환경 자동 복구(idempotent) + 세션 스냅샷 재생성
8. `runtime_flags.sh` - 런타임 플래그 파일/고정폭 상태표 생성(`.codex/state/runtime_flags.yaml`, `.codex/runtime/current_status.txt`)
9. `show_runtime_status.sh` - 런타임 상태표/경고를 원문 출력(옵션: `--alerts-only`, `--with-progress`)
10. `show_dev_progress.sh` - Active Project `task.md` 기반 개발 진행 체크리스트 출력
11. `sync_mcp_config.sh` - `~/.codex/config.toml` MCP 엔트리 템플릿 점검/반영(`guide`/`apply`)

## Notes
1. 기본 진입점은 `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`다.
2. 멀티 프로젝트 전환은 `./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh`를 사용한다.
3. 신규 프로젝트 문서 생성은 `./skills/aki-codex-session-reload/scripts/codex_skills_reload/init_project_docs.sh <project-root>`를 사용한다.
4. 세션 스냅샷(`.codex/runtime/codex_session_start.md`)에는 GitHub MCP bootstrap 리마인더가 포함되며, 기본 toolset은 `context,repos,issues,projects,pull_requests,labels`다.
5. 기본 toolset 목록은 `GITHUB_MCP_DEFAULT_TOOLSETS` 환경 변수로 오버라이드할 수 있다.
6. 새 PC/세션 초기화는 `./skills/aki-codex-session-reload/scripts/codex_skills_reload/bootstrap_env.sh`를 권장한다.
7. 현재 런타임 상태표 조회는 `./skills/aki-codex-session-reload/scripts/codex_skills_reload/runtime_flags.sh status`를 사용한다.
8. 개발 진행 체크 포함 조회는 `./skills/aki-codex-session-reload/scripts/codex_skills_reload/show_runtime_status.sh --with-progress`를 사용한다.
9. MCP config만 선반영하려면 `./skills/aki-codex-session-reload/scripts/codex_skills_reload/sync_mcp_config.sh --mode apply`를 사용한다.
