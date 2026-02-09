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
> - **Updated At**: `2026-02-09 08:22:19`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 목표
> - 실행 대상
> - 표준 실행 순서
> - 점검 포인트
> - 실패 복구
> - 참고 문서
<!-- DOC_TOC_END -->

## 목표
- 세션 시작 시 필요한 컨텍스트 로딩을 자동 체인으로 일관되게 수행한다.
- Active Project/스냅샷 불일치 상태를 빠르게 복구한다.
- 세션 재시작 이후 이어받기 비용을 최소화한다.

## 실행 대상
- `skills/bin/codex_skills_reload/session_start.sh`
- `skills/bin/codex_skills_reload/skills_reload.sh`
- `skills/bin/codex_skills_reload/project_reload.sh`
- `skills/bin/codex_skills_reload/set_active_project.sh`
- `skills/bin/codex_skills_reload/init_project_docs.sh`

## 표준 실행 순서
1. `git status --short`로 현재 워크트리 상태를 확인한다.
2. `./skills/bin/codex_skills_reload/session_start.sh`를 실행한다.
3. `.codex/runtime/codex_session_start.md`에서 Startup Checks를 확인한다.
4. `Loaded Skills`와 `Active Project`를 기준으로 필요한 문서를 로드한다.
5. 경고가 있으면 `set_active_project.sh` 또는 `init_project_docs.sh`로 복구한다.

## 점검 포인트
- `Skills Snapshot`: `OK`
- `Project Snapshot`: `OK`
- `Skills Bin Integrity`: `OK`
- `GitHub MCP Bootstrap` 섹션의 기본 toolset 확인

## 실패 복구
1. 문법 점검:
   - `bash -n skills/bin/codex_skills_reload/*.sh`
2. 스냅샷 재생성:
   - `./skills/bin/codex_skills_reload/session_start.sh`
3. Active Project 재지정:
   - `./skills/bin/codex_skills_reload/set_active_project.sh <project-root>`

## 공존 원칙
- 기본 세션 진입점은 계속 `./skills/bin/codex_skills_reload/session_start.sh`를 사용한다.
- runtime orchestrator(`./skills/bin/run-skill-hooks.sh`)는 보조 자동화 레이어이며 즉시 대체가 아니다.
- pre-commit 체인(`precommit_mode.sh`, `validate-precommit-chain.sh`)은 기존 정책대로 독립 운영한다.

## 참고 문서
- 세션 리로드 요약: `references/session-reload-runbook.md`
