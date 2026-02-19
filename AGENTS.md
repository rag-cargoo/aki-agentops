# AGENTS.md (Session Entry)

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
> - 1) Single Entry Rule
> - 2) Active Paths
> - 3) Safety Rules
> - 4) Skill Policy
> - 5) Skill Management Scope
> - 6) Reload Trigger (Critical)
> - 7) First Reply Contract
> - 8) GitHub MCP Init (Default)
> - 9) Issue Lifecycle Governance
> - 10) Branch Governance
> - 11) Playwright Evidence Policy
> - 12) Runtime Status Query Contract (Critical)
> - 13) Development Progress Query Contract (Critical)
> - 14) MCP Config Bootstrap Policy
<!-- DOC_TOC_END -->

## 1) Single Entry Rule
이 저장소는 세션 시작 시 `AGENTS.md`만 읽고 진입한다.

권장 트리거 문구:
1. `AGENTS.md만 읽고 시작해`
2. `AGENTS.md 확인해줘`
3. 세션 중 갱신: `스킬스 리로드해줘`

필수 시작 순서:
1. `git status --short`
2. `git branch --show-current`
3. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
4. `.codex/runtime/codex_session_start.md` 확인 후, 나열된 `SKILL.md` + Active Project의 `PROJECT_AGENT.md` + `task.md` 로드
5. GitHub MCP가 등록되어 있으면 기본 toolset 부팅 수행:
   - `mcp__github__list_available_toolsets`
   - `mcp__github__enable_toolset`: `context`, `repos`, `issues`, `projects`, `pull_requests`, `labels`
   - `mcp__github__list_available_toolsets` 재호출로 `currently_enabled=true` 재검증
6. 필요 시 `.codex/runtime/codex_skills_reload.md`, `.codex/runtime/codex_project_reload.md` 상세 확인
7. `github-pages/sidebar-manifest.md` 확인
8. 신규 환경/새 PC에서 MCP 서버 누락 경고가 있으면:
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/sync_mcp_config.sh --mode apply`

멀티 프로젝트에서 Active Project가 비어 있으면 먼저 실행:
`./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh <project-root>`

## 2) Active Paths
- Workspace Root: `workspace`
- Governance Root: `skills/aki-codex-core`
- Project Skills Root (npx skills): `.agents/skills`
- Reload Runtime: `skills/aki-codex-session-reload/scripts/codex_skills_reload`
- MCP Config Sync: `skills/aki-codex-session-reload/scripts/codex_skills_reload/sync_mcp_config.sh`
- MCP Config Template: `skills/aki-codex-session-reload/references/templates/mcp-config-template.toml`
- Skills Snapshot: `.codex/runtime/codex_skills_reload.md`
- Project Snapshot: `.codex/runtime/codex_project_reload.md`
- Session Snapshot: `.codex/runtime/codex_session_start.md`
- Sidebar Index: `github-pages/sidebar-manifest.md`

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
6. `aki-*` 스킬 문서/메타 스키마는 `skills/aki-codex-core/references/skill-schema-policy.md` 기준 적용
7. OAuth/SSO/세션만료 재인증처럼 사용자 로그인/동의가 필요한 흐름은 `skills/aki-mcp-playwright`를 우선 로드하고, 브라우저 오픈 전 callback target(예: `localhost:8080`) 헬스체크를 먼저 수행한다.
8. 세션 스킬 로딩은 `skills/*/SKILL.md`와 `.agents/skills/*/SKILL.md`를 병행한다.
9. Figma MCP(remote/desktop) 연결 점검/운영은 `skills/aki-mcp-figma`를 우선 로드한다.
10. `~/.codex/config.toml` 공통 MCP 엔트리 동기화는 `skills/aki-codex-session-reload`의 `sync_mcp_config.sh`를 권위 소스로 사용한다.

## 5) Skill Management Scope
1. 전역 관리 대상 스킬은 `skills/aki-*` prefix로 고정한다.
2. 비-`aki` 스킬(예: `java-spring-boot`)은 프로젝트 선택형으로 취급한다.
3. 비-`aki` 스킬의 사용/검증/운영 규칙은 Active Project의 `PROJECT_AGENT.md` + `task.md`에서 위임 관리한다.
4. 세션 시작 보고에서는 `Managed(aki-*)`와 `Delegated(non-aki)`를 구분해 표시한다.
5. `.agents/skills/*`로 설치된 프로젝트 스킬은 기본적으로 `Delegated(non-aki)`로 집계한다.

## 6) Reload Trigger (Critical)
아래 파일이 바뀌면 다음 작업 전에 반드시 다시 실행:
1. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
2. `.codex/runtime/codex_skills_reload.md` + `.codex/runtime/codex_project_reload.md` + `.codex/runtime/codex_session_start.md` 재확인

대상 파일:
- `AGENTS.md`
- `skills/*/SKILL.md`
- `skills/aki-codex-session-reload/references/templates/mcp-config-template.toml`
- `.agents/skills/*/SKILL.md`
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
8. GitHub MCP init 상태 (`init_mode`, `execution_status`, `enabled/failed/unsupported` 결과 또는 미실행 사유)
9. `Git Branch Context` (`Current Branch`, `HEAD`, `Default Branch`, `Branch Guard`)

## 8) GitHub MCP Init (Default)
GitHub MCP가 등록되어 있으면 세션 시작 보고에서 기본 6개 toolset init 가이드를 제공한다.

기본 대상:
1. `context`
2. `repos`
3. `issues`
4. `projects`
5. `pull_requests`
6. `labels`

운영 규칙:
1. `session_start.sh`는 `guide_only` 모드로 동작하며 toolset enable을 직접 실행하지 않는다.
2. 실제 enable은 `skills/aki-mcp-github/SKILL.md` init flow 단계에서 수행하고 결과(`enabled/failed/unsupported`)를 보고한다.
3. 이미 enable된 toolset은 재실행해도 무방하다(idempotent).
4. 일부 toolset이 실패해도 전체 세션은 중단하지 않고 실패 항목만 보고 후 계속 진행한다.
5. GitHub 작업(이슈/보드/리포 변경)은 init 결과 보고 후 진행한다.

## 9) Issue Lifecycle Governance
1. 같은 범위/목적의 후속작업은 기존 이슈 갱신 또는 재오픈을 기본으로 한다.
2. 새 이슈 생성은 범위가 달라진 경우에만 허용한다.
3. 기존 이슈 본문은 보존하고, 변경사항/진행상황은 코멘트로 누적한다.
4. 새 이슈를 만들면 "왜 재오픈이 아닌지" 근거를 이슈/PR에 명시한다.
5. 로컬 자동화는 `skills/aki-mcp-github/scripts/issue-upsert.sh`를 우선 사용한다.
6. PR은 템플릿을 사용하고 `pr-issue-governance` 체크 통과를 필수로 한다.

## 10) Branch Governance
1. 기본 작업 브랜치는 `main`이다. 사용자 명시 요청이 없으면 `main`에서 작업한다.
2. 세션 시작 보고에 `Current Branch`/`HEAD`/`Default Branch`를 반드시 포함한다.
3. 사용자 요청으로 다른 브랜치를 사용할 때는 전환 직후 현재 브랜치를 먼저 보고한 뒤 작업한다.
4. 브랜치 전환 기본 순서: `git checkout <branch>` -> `git pull --ff-only origin <branch>`.
5. 브랜치 지시가 모호하면 작업 시작 전 사용자 확인을 우선한다.

## 11) Playwright Evidence Policy
1. Playwright 기본 검증은 텍스트 증빙(`snapshot`, `console/network logs`)을 우선한다.
2. 스크린샷(`take_screenshot`, `*.png`) 생성은 사용자가 명시적으로 요청한 경우에만 수행한다.
3. 스크린샷이 필요한 경우에도 저장 경로는 `.codex/tmp/<tool>/<run-id>/`를 우선 사용한다.
4. 사용자 요청이 없으면 루트/프로젝트 경로에 PNG를 생성하지 않는다.
5. OAuth/SSO 인증처럼 사용자 클릭이 필요한 경우, Playwright로 인증 페이지를 먼저 열어 사용자에게 로그인/동의를 요청한다(Human-in-the-loop).
6. OAuth callback redirect가 로컬 백엔드(`localhost`/`127.0.0.1`)를 향하면, 인증 페이지 오픈 전에 백엔드 포트/헬스(`2xx`)를 확인한다. 미기동이면 인증 플로우를 시작하지 않는다.
7. OAuth/SSO HITL 시작 시 아래 문구를 반드시 사용자에게 먼저 보낸다.
   - `OAuth 세션이 만료되어 자동 진행이 불가합니다. 지금 로그인 페이지를 열겠습니다. 브라우저에서 직접 로그인/동의해주세요.`
   - `완료되면 '로그인 완료'라고 답해주세요.`
8. 사용자의 `로그인 완료` 응답 전에는 execute 단계(토큰 교환/후속 API 호출)로 진행하지 않는다.

## 12) Runtime Status Query Contract (Critical)
아래 트리거는 "런타임 상태표 요청"으로 고정 처리한다.

트리거:
1. `상태정보`
2. `상태정보 보여줘`
3. `상태 보여줘`
4. `런타임 상태 보여줘`
5. `런타임 경고만 보여줘`

강제 실행 순서:
1. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/show_runtime_status.sh`
2. 경고만 요청이면:
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/show_runtime_status.sh --alerts-only`

출력 규칙:
1. 기본은 명령 출력 원문 그대로 제시한다(가공/요약 금지).
2. 사용자가 명시적으로 "요약"을 요청한 경우에만 요약한다.
3. 상태정보 요청에서 아래 항목은 대체 출력으로 사용하지 않는다:
   - `git status`
   - open issue/pr 목록
   - task TODO/DOING 목록

## 13) Development Progress Query Contract (Critical)
아래 트리거는 "개발 진행 체크표 요청"으로 고정 처리한다.

트리거:
1. `진행상태`
2. `진행상태 보여줘`
3. `개발 진행상태 보여줘`
4. `체크리스트 보여줘`
5. `할일 체크 보여줘`

강제 실행 순서:
1. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/show_dev_progress.sh`
2. 상태정보 + 진행상태 동시 요청이면:
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/show_runtime_status.sh --with-progress`

출력 규칙:
1. 기본은 명령 출력 원문 그대로 제시한다(요약 금지).
2. 진행표는 체크표(`[ ]/[~]/[x]/[!]`)와 Summary를 포함해야 한다.
3. Active Project의 `task.md`를 우선 소스로 사용한다.

## 14) MCP Config Bootstrap Policy
1. 공통 MCP config 동기화는 `./skills/aki-codex-session-reload/scripts/codex_skills_reload/sync_mcp_config.sh`가 담당한다.
2. `guide` 모드는 점검만 수행하고, `apply` 모드는 누락 MCP 섹션을 idempotent 반영한다.
3. 서버별 운영 책임은 분리한다:
   - GitHub: `skills/aki-mcp-github`
   - Playwright: `skills/aki-mcp-playwright`
   - Figma: `skills/aki-mcp-figma`
4. 비밀값은 템플릿/레포에 저장하지 않고 환경변수 참조로만 관리한다.
