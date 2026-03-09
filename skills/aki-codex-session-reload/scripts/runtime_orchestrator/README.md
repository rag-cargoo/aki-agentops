# Runtime Orchestrator (Draft)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 15:52:00`
> - **Updated At**: `2026-02-17 17:28:03`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Purpose
> - Coexistence Policy
> - Run
> - Engine Shape
> - JSON Report Shape
<!-- DOC_TOC_END -->

## Purpose
- Manage session/runtime checks with a declarative hook list in `engine.yaml`.
- Execute hooks with `./skills/aki-codex-session-reload/scripts/run-skill-hooks.sh`.
- Persist standardized execution results to `.codex/runtime/skill-hooks-report.json`.

## Coexistence Policy
- This orchestrator does not replace `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`.
- This orchestrator does not replace existing pre-commit chain scripts.
- Ownership of this runtime hook runner remains in `aki-codex-session-reload`.
- User-facing workflow orchestration authority remains in `skills/aki-codex-workflows/*`.
- Use it as an opt-in runtime check layer while keeping current workflows intact.

## Run
- Default engine: `./skills/aki-codex-session-reload/scripts/run-skill-hooks.sh`
- Source script: `bash skills/aki-codex-session-reload/scripts/run-skill-hooks.sh`
- Custom engine: `./skills/aki-codex-session-reload/scripts/run-skill-hooks.sh --engine skills/aki-codex-session-reload/scripts/runtime_orchestrator/engine.yaml`

## Engine Shape
```yaml
version: 1
report:
  output: .codex/runtime/skill-hooks-report.json
hooks:
  - id: session_start
    run: ./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh
    on_fail: fail_fast
```

- `on_fail` supports `fail_fast` or `continue`.
- `version` currently supports only `1`.

## JSON Report Shape
- Sample: `skills/aki-codex-session-reload/scripts/runtime_orchestrator/skill-hooks-report.sample.json`
- Key fields:
  - `engine_path`: engine config path
  - `generated_at`: UTC timestamp
  - `summary`: total/passed/failed/skipped/duration_ms
  - `hooks[]`: id/run/on_fail/status/exit_code/timestamps/duration_ms
