# AGENTS.md (Session Entry)

## 1) Single Entry Rule
이 저장소는 세션 시작 시 `AGENTS.md`만 읽고 진입한다.

필수 시작 순서:
1. `git status --short`
2. `./skills/bin/codex_skills_reload/session_start.sh`
3. `.codex/runtime/codex_session_start.md` 확인 후, 나열된 `SKILL.md` + Active Project의 `PROJECT_AGENT.md` + `task.md` 로드
4. 필요 시 `.codex/runtime/codex_skills_reload.md`, `.codex/runtime/codex_project_reload.md` 상세 확인
5. `sidebar-manifest.md` 확인

멀티 프로젝트에서 Active Project가 비어 있으면 먼저 실행:
`./skills/bin/codex_skills_reload/set_active_project.sh <project-root>`

## 2) Active Paths
- Workspace Root: `workspace`
- Governance Root: `skills/workspace-governance`
- Reload Runtime: `skills/bin/codex_skills_reload`
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
`./skills/bin/create-backup-point.sh pre-change`

## 4) Skill Policy
1. 요청이 스킬 범위와 일치하면 해당 `SKILL.md`를 먼저 로드
2. 문서 렌더링/Pages/무손실 점검은 `skills/github-pages-expert` 우선 사용
3. 워크플로우/구조/표준/운영 규칙은 `skills/workspace-governance` 기준 적용
4. 프로젝트 고유 규칙은 Active Project의 `prj-docs/PROJECT_AGENT.md`에만 적용

## 5) Reload Trigger (Critical)
아래 파일이 바뀌면 다음 작업 전에 반드시 다시 실행:
1. `./skills/bin/codex_skills_reload/session_start.sh`
2. `.codex/runtime/codex_skills_reload.md` + `.codex/runtime/codex_project_reload.md` + `.codex/runtime/codex_session_start.md` 재확인

대상 파일:
- `AGENTS.md`
- `skills/*/SKILL.md`
- `workspace/**/prj-docs/PROJECT_AGENT.md`

## 6) First Reply Contract
세션 첫 응답에서 아래 항목을 반드시 사용자에게 보고한다.

1. `Startup Checks` 결과 (`Skills Snapshot`, `Project Snapshot`, `Skills Bin Integrity`)
2. `Loaded Skills` 전체 목록
3. `Active Project` (`Project Root`, `Task Doc`, `Project Agent`)
4. `How It Works` 3줄 요약 (전역 규칙 vs 프로젝트 규칙 vs Active Project 개념)
5. 멀티 프로젝트 사용법 2줄 (`--list`, `set_active_project`)
6. 누락/경고 항목이 있으면 즉시 후속 액션 1줄 제시
