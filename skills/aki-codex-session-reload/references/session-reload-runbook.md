# Session Reload Runbook

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 08:22:19`
> - **Updated At**: `2026-02-11 06:45:00`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 표준 실행
> - 환경 검증
> - 런타임 상태표
> - 멀티 프로젝트
> - 실패 복구
<!-- DOC_TOC_END -->

> [!NOTE]
> 세션 컨텍스트 불일치/스냅샷 경고 발생 시 재현 가능한 복구 절차.

## 표준 실행
1. `git status --short`
2. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
3. `cat .codex/runtime/codex_session_start.md`
4. `Startup Checks` 3개가 `OK`인지 확인
5. `GitHub MCP Init`의 `init_mode`/`execution_status`를 확인하고 필요 시 `aki-mcp-github` init flow를 실행

## 환경 검증
1. 환경 점검:
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/validate_env.sh`
2. WARN 복구:
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/bootstrap_env.sh`
3. 목적:
   - `.codex/runtime` 재생성
   - `.codex/state` 재생성
   - `core.hooksPath=.githooks` 정렬
   - 훅/핵심 스크립트 실행권한 복구

## 런타임 상태표
1. 동기화(파일 갱신):
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/runtime_flags.sh sync`
2. 조회(고정폭 표):
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/runtime_flags.sh status`
3. 경고 전용 조회:
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/runtime_flags.sh alerts`
4. 산출물:
   - `.codex/state/runtime_flags.yaml`
   - `.codex/runtime/current_status.txt`
5. 출력 타이밍(권장):
   - 세션 시작 1회
   - 옵션 변경 직후(예: precommit mode 전환)
   - 사용자 명시 요청 시(`상태 보여줘`)
6. 표 구성:
   - `[User Controls]`: 이용자 제어 항목(예: precommit mode, active project)
   - `[Agent Checks]`: 에이전트 자동 점검 항목(예: hooks/env/handoff 존재 여부)
7. Pages/품질 가드 해석:
   - `pages_skill`, `pages_docsify_validator`, `pages_release_flow`가 모두 정상인지 확인
   - `docsify_precommit_guard`, `owner_skill_lint_guard`, `skill_naming_guard`가 `ENABLED`인지 확인
8. GitHub 토큰 소스 해석:
   - `github_token_source`가 `inline_plaintext`면 config 파일 평문 토큰 경고 상태다.
   - 권장값은 `${ENV_VAR}` 형태의 외부 참조(`env_ref`)다.
9. Skill Inventory 해석:
   - `skills_total`과 각 count가 기대치와 맞는지 확인
   - `skill:<name>` 목록에서 누락 스킬이 없는지 확인
10. MCP Inventory 해석:
   - `mcp_servers_total`은 구성된 MCP 수, `mcp_servers_running`은 로컬 프로세스/컨테이너 기반 가동 수다.
   - `mcp:<server>` 행에서 runtime/status를 확인한다.
   - `runtime=url` + `status=CONFIGURED`는 원격 MCP(endpoint 기반) 구성 완료 상태다. "미사용" 의미가 아니다.
   - `mcp:playwright` detail의 `cdp:...:down`이면 MCP 프로세스가 살아 있어도 브라우저 CDP endpoint가 죽은 상태다.
   - Docker 항목 detail에 `probe=RESTRICTED`가 보이면 Docker daemon 조회 제한 상태이며, 프로세스 기반으로 `RUNNING` 판정한 결과다.
11. Workflow Health 해석:
   - `workflow_total`, `workflow_ready_count`로 워크플로우 준비 범위를 확인한다.
   - `workflow_marks_count`, `workflow_marks_file`로 최신 실행 마크 저장소 적용 여부를 확인한다.
   - `workflow:<name>`은 `READY/NOT_READY`와 마지막 상태(`PASS/FAIL/UNVERIFIED/NOT_RUN`)를 함께 본다.
   - `workflow:<name>:detail`에서 누락 의존성/최근 실행 근거를 확인한다.
12. Alerts 해석:
   - 상태표 상단 `Alerts`에서 문제 항목만 먼저 확인한다.
   - `runtime all_clear`면 즉시 조치가 필요한 항목이 없다는 의미다.
13. Session Snapshot 요약:
   - `.codex/runtime/codex_session_start.md`의 `Runtime Status` 아래 `Workflow Summary` 1줄로 핵심 상태를 빠르게 확인한다.

## 멀티 프로젝트
1. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh --list`
2. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh <project-root>`
3. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`

## 실패 복구
1. `bash -n skills/aki-codex-session-reload/scripts/codex_skills_reload/*.sh`
2. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
3. 환경 훼손/누락 시:
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/bootstrap_env.sh`
4. baseline 누락 시:
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/init_project_docs.sh <project-root>`

## 공존 원칙
1. 기본 세션 체인은 `session_start.sh`를 유지한다.
   - 실행 엔트리: `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
   - 소스 스크립트: `skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
2. `run-skill-hooks.sh`는 점진 도입용 보조 실행기다.
   - 실행 엔트리: `./skills/aki-codex-session-reload/scripts/run-skill-hooks.sh`
   - 소스 스크립트: `skills/aki-codex-session-reload/scripts/run-skill-hooks.sh`
   - 엔진 정의: `skills/aki-codex-session-reload/scripts/runtime_orchestrator/engine.yaml`
   - 소유권: `aki-codex-session-reload` (세션 부트스트랩/런타임 무결성 점검 범위)
3. 사용자 작업 오케스트레이션 권위 소스는 `aki-codex-workflows`를 사용한다.
   - `run-skill-hooks.sh`/`engine.yaml`는 `When/Why/Order/Condition/Done` 권위 소스가 아니다.
4. pre-commit 체인은 기존 `precommit_mode.sh`/`validate-precommit-chain.sh` 경로를 그대로 쓴다.
5. skill runtime 동기화 스크립트:
   - 실행 엔트리: `./skills/aki-codex-session-reload/scripts/sync-skill.sh`
   - 소스 스크립트: `skills/aki-codex-session-reload/scripts/sync-skill.sh`
