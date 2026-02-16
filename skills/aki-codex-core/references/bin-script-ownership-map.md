# Bin Script Ownership Map

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 16:20:00`
> - **Updated At**: `2026-02-17 06:22:42`
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
- `skills/bin` 폐기 이후 소스 스크립트의 소유 스킬을 명확히 한다.
- 실행 엔트리는 각 스킬의 `scripts/` 경로만 사용한다.

## 매핑
| 소스 스크립트 | 소유 스킬 |
| --- | --- |
| `skills/aki-codex-core/scripts/check-skill-naming.sh` | `aki-codex-core` |
| `skills/aki-codex-core/scripts/create-backup-point.sh` | `aki-codex-core` |
| `skills/aki-codex-core/scripts/safe-git.sh` | `aki-codex-core` |
| `skills/aki-codex-core/scripts/safe-gh.sh` | `aki-codex-core` |
| `skills/aki-codex-precommit/scripts/precommit_mode.sh` | `aki-codex-precommit` |
| `skills/aki-codex-precommit/scripts/validate-precommit-chain.sh` | `aki-codex-precommit` |
| `skills/aki-codex-precommit/scripts/check-doc-remote-sync.sh` | `aki-codex-precommit` |
| `skills/aki-codex-session-reload/scripts/codex_skills_reload/` | `aki-codex-session-reload` |
| `skills/aki-codex-session-reload/scripts/run-skill-hooks.sh` | `aki-codex-session-reload` |
| `skills/aki-codex-session-reload/scripts/runtime_orchestrator/` | `aki-codex-session-reload` |
| `skills/aki-codex-session-reload/scripts/sync-skill.sh` | `aki-codex-session-reload` |
| `skills/aki-codex-precommit/scripts/run-project-api-script-tests.sh` | `aki-codex-precommit` |

## 운영 원칙
1. 기능 수정은 소스 스크립트에서만 수행한다.
2. `skills/bin` 경로는 폐기되었으며 새 엔트리를 추가하지 않는다.
3. 엔트리 변경 시 source 경로 호출 검증(`./skills/aki-*/scripts/...`)을 먼저 수행한다.
