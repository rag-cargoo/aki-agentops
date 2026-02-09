# Session Reload Runbook

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 08:22:19`
> -02-09 17:53:22`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 표준 실행
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

## 멀티 프로젝트
1. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh --list`
2. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh <project-root>`
3. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`

## 실패 복구
1. `bash -n skills/aki-codex-session-reload/scripts/codex_skills_reload/*.sh`
2. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
3. baseline 누락 시:
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/init_project_docs.sh <project-root>`

## 공존 원칙
1. 기본 세션 체인은 `session_start.sh`를 유지한다.
   - 실행 엔트리: `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
   - 소스 스크립트: `skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
2. `run-skill-hooks.sh`는 점진 도입용 보조 실행기다.
   - 실행 엔트리: `./skills/aki-codex-session-reload/scripts/run-skill-hooks.sh`
   - 소스 스크립트: `skills/aki-codex-session-reload/scripts/run-skill-hooks.sh`
   - 엔진 정의: `skills/aki-codex-session-reload/scripts/runtime_orchestrator/engine.yaml`
3. pre-commit 체인은 기존 `precommit_mode.sh`/`validate-precommit-chain.sh` 경로를 그대로 쓴다.
4. skill runtime 동기화 스크립트:
   - 실행 엔트리: `./skills/aki-codex-session-reload/scripts/sync-skill.sh`
   - 소스 스크립트: `skills/aki-codex-session-reload/scripts/sync-skill.sh`
