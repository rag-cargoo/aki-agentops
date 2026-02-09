# Bin Script Ownership Map

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 16:20:00`
> - **Updated At**: `2026-02-09 16:20:00`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 목적
> - 매핑
> - 운영 원칙
<!-- DOC_TOC_END -->

## 목적
- `skills/bin` 스크립트의 소유 스킬을 명확히 한다.
- 구현은 스킬별 `scripts/`에 두고, `skills/bin`은 호환 엔트리로 유지한다.

## 매핑
| 호환 엔트리 (`skills/bin`) | 소스 스크립트 | 소유 스킬 |
| --- | --- | --- |
| `check-skill-naming.sh` | `skills/aki-codex-core/scripts/check-skill-naming.sh` | `aki-codex-core` |
| `precommit_mode.sh` | `skills/aki-codex-precommit/scripts/precommit_mode.sh` | `aki-codex-precommit` |
| `validate-precommit-chain.sh` | `skills/aki-codex-precommit/scripts/validate-precommit-chain.sh` | `aki-codex-precommit` |
| `run-skill-hooks.sh` | `skills/aki-codex-session-reload/scripts/run-skill-hooks.sh` | `aki-codex-session-reload` |
| `runtime_orchestrator/` | `skills/aki-codex-session-reload/scripts/runtime_orchestrator/` | `aki-codex-session-reload` |

## 운영 원칙
1. 기능 수정은 소스 스크립트에서만 수행한다.
2. `skills/bin` 엔트리는 최소 위임 로직만 유지한다.
3. 엔트리 변경 시 호출 호환성(`./skills/bin/<script>`)을 먼저 검증한다.
