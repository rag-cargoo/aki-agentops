---
name: aki-codex-session-reload
description: |
  코덱스 세션 시작/리로드 체인 운영 스킬.
  `session_start.sh`, `skills_reload.sh`, `project_reload.sh`, `set_active_project.sh` 실행 순서와 점검 항목을 관리한다.
  세션 컨텍스트가 어긋나거나 Active Project/스냅샷 상태를 복구해야 할 때 사용한다.
---

# Aki Codex Session Reload

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 08:22:19`
> - **Updated At**: `2026-02-17 17:28:03`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 목표
> - 오케스트레이션 경계
> - 실행 대상
> - 소유권 경계
> - 표준 실행 순서
> - 환경 부트스트랩
> - 런타임 상태표
> - 점검 포인트
> - 실패 복구
> - 참고 문서
<!-- DOC_TOC_END -->

## 목표
- 세션 시작 시 필요한 컨텍스트 로딩을 자동 체인으로 일관되게 수행한다.
- Active Project/스냅샷 불일치 상태를 빠르게 복구한다.
- 세션 재시작 이후 이어받기 비용을 최소화한다.
- 세션 시작 보고에서 임시 산출물 정책(`.codex/tmp`)을 선안내해 작업 전 규칙 전파를 보장한다.
- 세션 시작 보고에 Git Branch Context를 포함해 작업 브랜치 혼선을 줄인다.

## 오케스트레이션 경계
- 이 스킬은 세션 리로드 도메인 실행 로직만 담당한다.
- 크로스 스킬 호출 순서/분기/종료판정은 `aki-codex-workflows` 문서를 권위 소스로 따른다.

## 실행 대상
- session reload 소스:
  - `skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
  - `skills/aki-codex-session-reload/scripts/codex_skills_reload/skills_reload.sh`
  - `skills/aki-codex-session-reload/scripts/codex_skills_reload/project_reload.sh`
  - `skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh`
  - `skills/aki-codex-session-reload/scripts/codex_skills_reload/init_project_docs.sh`
  - `skills/aki-codex-session-reload/scripts/codex_skills_reload/validate_env.sh`
  - `skills/aki-codex-session-reload/scripts/codex_skills_reload/bootstrap_env.sh`
  - `skills/aki-codex-session-reload/scripts/codex_skills_reload/runtime_flags.sh`
- runtime orchestrator 소스:
  - `skills/aki-codex-session-reload/scripts/run-skill-hooks.sh`
  - `skills/aki-codex-session-reload/scripts/runtime_orchestrator/engine.yaml`
- 기타 runtime 도구:
  - `skills/aki-codex-session-reload/scripts/sync-skill.sh`

## 소유권 경계
- `run-skill-hooks.sh` + `runtime_orchestrator/engine.yaml`의 소유 스킬은 `aki-codex-session-reload`로 고정한다.
- 위 자산은 "세션 부트스트랩/런타임 무결성 점검"을 위한 보조 실행기이며, 사용자 작업 오케스트레이션의 권위 소스가 아니다.
- 사용자 작업 오케스트레이션(When/Why/Order/Condition/Done)의 권위 소스는 `aki-codex-workflows` 문서를 사용한다.

## 표준 실행 순서
1. `git status --short`로 현재 워크트리 상태를 확인한다.
2. `git branch --show-current`로 현재 브랜치를 확인하고, 사용자 명시 요청이 없으면 `main`으로 정렬한다.
3. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`를 실행한다.
4. `.codex/runtime/codex_session_start.md`에서 Startup Checks를 확인한다.
5. `Loaded Skills`와 `Active Project`를 기준으로 필요한 문서를 로드한다.
6. 경고가 있으면 `validate_env.sh` 또는 `bootstrap_env.sh`로 환경을 복구한다.
7. `Runtime Status` 표(`.codex/runtime/current_status.txt`)를 확인한다.
8. 프로젝트 경고가 있으면 `set_active_project.sh` 또는 `init_project_docs.sh`로 복구한다.

## 환경 부트스트랩
1. 환경 점검:
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/validate_env.sh`
2. 자동 복구(재실행 안전):
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/bootstrap_env.sh`
3. 역할 분리:
   - `skills/`는 소스(정책/로직)
   - `.codex/runtime`은 런타임 스냅샷(재생성 대상)
   - `.codex/state`는 런타임 플래그 상태 저장소
   - `.githooks`는 훅 엔트리포인트(`core.hooksPath`)로 유지

## 런타임 상태표
1. 상태 동기화:
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/runtime_flags.sh sync`
2. 상태 조회:
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/runtime_flags.sh status`
3. 경고 전용 조회:
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/runtime_flags.sh alerts`
4. 상태 산출물:
   - `.codex/state/runtime_flags.yaml`
   - `.codex/runtime/current_status.txt`
5. 소유 원칙:
   - 상태 파일 생성/갱신/표 출력은 `aki-codex-session-reload`가 소유한다.
   - 출력 타이밍(언제 보여줄지)은 `aki-codex-workflows` 규칙을 따른다.
6. 표시 구분:
   - `User Controls`와 `Agent Checks`를 분리해 사용자 제어값과 자동 점검값을 구분한다.
7. Agent Checks 기본 항목:
   - GitHub MCP 구성 상태
   - GitHub 토큰 소스 상태(`github_token_source`)
   - 환경/훅 무결성 상태
   - MCP 인벤토리(`mcp_servers_total`, `mcp:<server>` runtime/status)
   - CDP endpoint health(`mcp:playwright` detail의 `cdp:...:up|down`)
   - Pages 운영 가드(`pages_skill`, `pages_docsify_validator`, `pages_release_flow`)
   - pre-commit 품질 가드(`docsify_precommit_guard`, `owner_skill_lint_guard`, `skill_naming_guard`)
8. Skill Inventory:
   - `skills_total`, `skills_managed_count`, `skills_delegated_count`를 출력한다.
   - `skill:<name>` 행으로 모든 로컬 스킬 존재 상태를 표시한다.
9. Workflow Health:
   - 주요 워크플로우별 준비 상태(`READY/NOT_READY`)와 마지막 상태(`PASS/FAIL/UNVERIFIED/NOT_RUN`)를 출력한다.
   - `workflow_marks_count`/`workflow_marks_file`로 실행 결과 마크 저장소 연동 상태를 확인한다.
   - `workflow:*:detail` 행에서 누락 의존성/실행 근거를 확인한다.
10. Alerts 요약:
   - 상태표 상단 `Alerts` 섹션에 문제 항목(`WARN`/`MISSING`/`MISMATCH`/`IDLE`)만 요약 표시한다.
   - `all_clear`면 경고 없음으로 간주한다.
11. Session Snapshot 요약:
   - `session_start.sh`는 `Runtime Status` 아래 `Workflow Summary` 1줄을 자동 삽입해 핵심 판정을 빠르게 제공한다.
12. Branch Context:
   - `session_start.sh`는 `Git Branch Context` 섹션에 `Current Branch`/`HEAD`/`Default Branch`/`Branch Guard`를 출력한다.

## 점검 포인트
- `Skills Snapshot`: `OK`
- `Project Snapshot`: `OK`
- `Skills Runtime Integrity`: `OK`
- `Runtime Flags`: `OK`
- `GitHub MCP Init` 섹션의 `init_mode`/`execution_status`/기본 toolset 확인
- `Git Branch Context` 섹션의 `Current Branch`/`Branch Guard` 확인

## 실패 복구
1. 문법 점검:
   - `bash -n skills/aki-codex-session-reload/scripts/codex_skills_reload/*.sh`
2. 스냅샷 재생성:
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
3. 환경 복구:
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/bootstrap_env.sh`
4. Active Project 재지정:
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh <project-root>`

## 공존 원칙
- 기본 세션 진입점은 source-first로 `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`를 사용한다.
- runtime orchestrator(`./skills/aki-codex-session-reload/scripts/run-skill-hooks.sh`)는 보조 자동화 레이어이며 즉시 대체가 아니다.
- pre-commit 체인(`precommit_mode.sh`, `validate-precommit-chain.sh`)은 기존 정책대로 독립 운영한다.

## 참고 문서
- 세션 리로드 요약: `references/session-reload-runbook.md`
