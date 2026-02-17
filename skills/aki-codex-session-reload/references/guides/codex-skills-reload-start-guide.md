# Codex Skills Reload Start Guide

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-17 17:28:03`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 0. 먼저 이것만
> - 1. 이 가이드가 다루는 범위
> - 2. 세션 시작 체크리스트
> - 3. 멀티 프로젝트일 때
> - 4. 신규 프로젝트 시작할 때
> - 5. 실패 시 가장 빠른 복구
<!-- DOC_TOC_END -->

> 목적: 처음 보는 사람이 "무엇을 먼저 해야 하는지"만 빠르게 따라할 수 있도록 만든 시작 가이드.

---

## 0. 먼저 이것만

세션 시작 시:
1. `AGENTS.md만 읽고 시작해`
2. 또는 `AGENTS.md 확인해줘`

세션 중 스킬 수정/추가 후:
1. `스킬스 리로드해줘`

수동 실행(터미널):
```bash
./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh
```

---

## 1. 이 가이드가 다루는 범위

이 문서:
1. 시작 절차(첫 실행)
2. 세션 중 재실행 시점
3. 필수 확인 포인트

상세 운영/원리는 아래 문서에서 본다.
1. `skills/aki-codex-session-reload/references/guides/codex-skills-reload-operations-manual.md`
2. `skills/aki-codex-session-reload/references/guides/codex-skills-reload-automation-rationale-and-changes.md`

---

## 2. 세션 시작 체크리스트

1. 실행
```bash
./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh
```
2. 상태 파일 확인
```bash
cat .codex/runtime/codex_session_start.md
```
3. 아래 3개가 `OK`인지 확인
- `Skills Snapshot`
- `Project Snapshot`
- `Skills Runtime Integrity`

---

## 3. 멀티 프로젝트일 때

1. 프로젝트 목록 확인
```bash
./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh --list
```
2. 활성 프로젝트 지정
```bash
./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh <project-root>
```
3. 재실행
```bash
./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh
```

---

## 4. 신규 프로젝트 시작할 때

1. 문서 골격 자동 생성
```bash
./skills/aki-codex-session-reload/scripts/codex_skills_reload/init_project_docs.sh workspace/<category>/<service>
```
2. 활성 프로젝트 지정 + 세션 리로드
```bash
./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh workspace/<category>/<service>
./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh
```

---

## 5. 실패 시 가장 빠른 복구

1. 문법 점검
```bash
bash -n skills/aki-codex-session-reload/scripts/codex_skills_reload/*.sh
```
2. 세션 상태 재생성
```bash
./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh
```
3. 훅 경로 확인
```bash
git config --get core.hooksPath
```
기대값: `.githooks`
