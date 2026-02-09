# Codex Runtime Engine README

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 04:27:20`
> - **Updated At**: `2026-02-09 04:59:53`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Overview
> - Scope
> - Run
> - Docs
<!-- DOC_TOC_END -->

## Overview
- Status: `In Progress`
- Purpose: `workspace/**` 프로젝트를 자동 탐색하고, 세션 시작/리로드 체인을 YAML 기반으로 실행하는 런타임 엔진을 구축한다.
- Primary Goal: 수동 문서/경로 스캔을 줄이고, 에이전트가 런타임 결과만 읽어 작업을 이어갈 수 있게 만든다.

## Scope
- 프로젝트 탐색 기준: `workspace/**/prj-docs/task.md`
- 기준선 검증: `README.md`, `prj-docs/PROJECT_AGENT.md`, `prj-docs/task.md`, `prj-docs/meeting-notes/README.md`, `prj-docs/rules/`
- 체이닝 대상: session start, skill init hooks, runtime report

## Run
```bash
./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh
./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh workspace/agent-skills/codex-runtime-engine
```

## Docs
- [Project Agent (Rules)](/workspace/agent-skills/codex-runtime-engine/prj-docs/PROJECT_AGENT.md)
- [Task Dashboard](/workspace/agent-skills/codex-runtime-engine/prj-docs/task.md)
- [Meeting Notes Index](/workspace/agent-skills/codex-runtime-engine/prj-docs/meeting-notes/README.md)
