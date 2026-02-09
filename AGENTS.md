# AGENTS.md (Session Entry)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> -02-09 17:53:22`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 1) Single Entry Rule
> - 2) Active Paths
> - 3) Safety Rules
> - 4) Skill Policy
> - 5) Reload Trigger (Critical)
> - 6) First Reply Contract
> - 7) GitHub MCP Bootstrap (Default)
<!-- DOC_TOC_END -->

## 1) Single Entry Rule
이 저장소는 세션 시작 시 `AGENTS.md`만 읽고 진입한다.

권장 트리거 문구:
1. `AGENTS.md만 읽고 시작해`
2. `AGENTS.md 확인해줘`
3. 세션 중 갱신: `스킬스 리로드해줘`

필수 시작 순서:
1. `git status --short`
2. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
3. `.codex/runtime/codex_session_start.md` 확인 후, 나열된 `SKILL.md` + Active Project의 `PROJECT_AGENT.md` + `task.md` 로드
4. GitHub MCP가 등록되어 있으면 기본 toolset 부팅 수행:
   - `mcp__github__list_available_toolsets`
   - `mcp__github__enable_toolset`: `context`, `repos`, `issues`, `projects`, `pull_requests`, `labels`
   - `mcp__github__list_available_toolsets` 재호출로 `currently_enabled=true` 재검증
5. 필요 시 `.codex/runtime/codex_skills_reload.md`, `.codex/runtime/codex_project_reload.md` 상세 확인
6. `sidebar-manifest.md` 확인

멀티 프로젝트에서 Active Project가 비어 있으면 먼저 실행:
`./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh <project-root>`

## 2) Active Paths
- Workspace Root: `workspace`
- Governance Root: `skills/workspace-governance`
- Reload Runtime: `skills/aki-codex-session-reload/scripts/codex_skills_reload`
- Skills Snapshot: `.codex/runtime/codex_skills_reload.md`
- Project Snapshot: `.codex/runtime/codex_project_reload.md`
- Session Snapshot: `.codex/runtime/codex_session_start.md`
- Sidebar Index: `sidebar-manifest.md`

## 3) Safety Rules
1. 기존 문서의 상세 내용은 요약/삭제하지 않고 구조화만 수행
2. 사용자 명시 요청 없이는 파괴적 Git 명령 실행 금지
3. 단일 파일은 부분 수정 우선, 전체 덮어쓰기 지양
4. 문서 스타일 변경 시 본문 내용 diff가 생기지 않게 유지
5. 대규모 작업 전 백업 포인트 생성:
`./skills/aki-codex-core/scripts/create-backup-point.sh pre-change`

## 4) Skill Policy
1. 요청이 스킬 범위와 일치하면 해당 `SKILL.md`를 먼저 로드
2. 문서 렌더링/Pages/무손실 점검은 `skills/aki-github-pages-expert` 우선 사용
3. 워크플로우/구조/표준/운영 규칙은 `skills/workspace-governance` 기준 적용
4. 프로젝트 고유 규칙은 Active Project의 `prj-docs/PROJECT_AGENT.md`에만 적용

## 5) Reload Trigger (Critical)
아래 파일이 바뀌면 다음 작업 전에 반드시 다시 실행:
1. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
2. `.codex/runtime/codex_skills_reload.md` + `.codex/runtime/codex_project_reload.md` + `.codex/runtime/codex_session_start.md` 재확인

대상 파일:
- `AGENTS.md`
- `skills/*/SKILL.md`
- `workspace/**/prj-docs/PROJECT_AGENT.md`

## 6) First Reply Contract
세션 첫 응답에서 아래 항목을 반드시 사용자에게 보고한다.

1. `Startup Checks` 결과 (`Skills Snapshot`, `Project Snapshot`, `Skills Runtime Integrity`)
2. `Loaded Skills` 전체 목록
3. `Active Project` (`Project Root`, `Task Doc`, `Project Agent`)
4. `How It Works` 3줄 요약 (전역 규칙 vs 프로젝트 규칙 vs Active Project 개념)
5. 멀티 프로젝트 사용법 2줄 (`--list`, `set_active_project`)
6. 누락/경고 항목이 있으면 즉시 후속 액션 1줄 제시
7. GitHub MCP bootstrap 결과 (`enabled toolsets`, `미활성/실패 항목`)

## 7) GitHub MCP Bootstrap (Default)
GitHub MCP가 등록되어 있으면 세션 시작 때 기본 6개 toolset을 항상 부팅한다.

기본 대상:
1. `context`
2. `repos`
3. `issues`
4. `projects`
5. `pull_requests`
6. `labels`

운영 규칙:
1. 이미 enable된 toolset은 재실행해도 무방하다(idempotent).
2. 일부 toolset이 실패해도 전체 세션은 중단하지 않고 실패 항목만 보고 후 계속 진행한다.
3. GitHub 작업(이슈/보드/리포 변경)은 bootstrap 결과 보고 후 진행한다.
