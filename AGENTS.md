# AGENTS.md (Session Entry)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-10 03:59:33`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 1) Single Entry Rule
> - 2) Active Paths
> - 3) Safety Rules
> - 4) Skill Policy
> - 5) Skill Management Scope
> - 6) Reload Trigger (Critical)
> - 7) First Reply Contract
> - 8) GitHub MCP Init (Default)
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
- Governance Root: `skills/aki-codex-core`
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
3. 구조/표준/전역 원칙은 `skills/aki-codex-core` 기준 적용
4. 실행 순서/분기/완료판정은 `skills/aki-codex-workflows` 기준 적용
5. 프로젝트 고유 규칙은 Active Project의 `prj-docs/PROJECT_AGENT.md`에만 적용

## 5) Skill Management Scope
1. 전역 관리 대상 스킬은 `skills/aki-*` prefix로 고정한다.
2. 비-`aki` 스킬(예: `java-spring-boot`)은 프로젝트 선택형으로 취급한다.
3. 비-`aki` 스킬의 사용/검증/운영 규칙은 Active Project의 `PROJECT_AGENT.md` + `task.md`에서 위임 관리한다.
4. 세션 시작 보고에서는 `Managed(aki-*)`와 `Delegated(non-aki)`를 구분해 표시한다.

## 6) Reload Trigger (Critical)
아래 파일이 바뀌면 다음 작업 전에 반드시 다시 실행:
1. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
2. `.codex/runtime/codex_skills_reload.md` + `.codex/runtime/codex_project_reload.md` + `.codex/runtime/codex_session_start.md` 재확인

대상 파일:
- `AGENTS.md`
- `skills/*/SKILL.md`
- `workspace/**/prj-docs/PROJECT_AGENT.md`

## 7) First Reply Contract
세션 첫 응답에서 아래 항목을 반드시 사용자에게 보고한다.

1. `Startup Checks` 결과 (`Skills Snapshot`, `Project Snapshot`, `Skills Runtime Integrity`)
2. `Loaded Skills` 전체 목록
3. `Skill Management Scope` (`Managed(aki-*)` / `Delegated(non-aki)`)
4. `Active Project` (`Project Root`, `Task Doc`, `Project Agent`)
5. `How It Works` 3줄 요약 (전역 규칙 vs 프로젝트 규칙 vs Active Project 개념)
6. 멀티 프로젝트 사용법 2줄 (`--list`, `set_active_project`)
7. 누락/경고 항목이 있으면 즉시 후속 액션 1줄 제시
8. GitHub MCP init 결과 (`enabled toolsets`, `미활성/실패 항목`)

## 8) GitHub MCP Init (Default)
GitHub MCP가 등록되어 있으면 세션 시작 때 기본 6개 toolset init을 수행한다.

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
3. GitHub 작업(이슈/보드/리포 변경)은 init 결과 보고 후 진행한다.
