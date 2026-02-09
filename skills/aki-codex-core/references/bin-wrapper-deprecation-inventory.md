# Bin Wrapper Deprecation Inventory

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 17:26:35`
> - **Updated At**: `2026-02-09 17:28:46`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 범위
> - 스냅샷 요약
> - 분류
> - 즉시 전환 완료 항목
> - 잔여 항목
<!-- DOC_TOC_END -->

## 범위
- 검색 패턴: `skills/bin/`
- 제외: `.git/`, `.codex/runtime/`, `.gemini/`
- 기준 브랜치: `feature/bin-wrapper-deprecation-inventory`

## 스냅샷 요약
- 총 참조 파일: `32`
- 최상위 분포:
  - `skills/`: 28
  - `workspace/`: 2
  - 기타(`AGENTS.md`, `mcp`): 2

## 분류
| 분류 | 파일 수 | 기준 | 처리 방향 |
| --- | --- | --- | --- |
| A. 내부 실행 경로(즉시 전환) | 0 | 훅/CI/정책 엔진이 직접 실행 | 전환 완료 유지 |
| B. 호환 엔트리 안내 문서 | 24 | 사용자 운영 명령/런북 | 호환 기간 유지 후 단계 전환 |
| C. 소스 스크립트 내부 안내 문구/샘플 | 8 | help/로그/샘플 YAML/JSON | 폐기 직전 일괄 전환 |

## 즉시 전환 완료 항목
1. `.githooks/pre-commit`
   - `skills/bin/codex_skills_reload/*` -> `skills/aki-codex-session-reload/scripts/codex_skills_reload/*`
   - `skills/bin/validate-precommit-chain.sh` -> `skills/aki-codex-precommit/scripts/validate-precommit-chain.sh`
2. `.github/workflows/codex-skills-reload.yml`
   - syntax/session-start 경로를 session-reload 소스로 전환
3. `skills/aki-codex-precommit/policies/workspace-governance.sh`
   - strict 모드 reload 검증 경로를 session-reload 소스로 전환

## 잔여 항목
1. 사용자 진입 문서/런북:
   - `AGENTS.md`
   - `skills/workspace-governance/references/guides/*.md`
   - `skills/aki-codex-*/SKILL.md`
   - `workspace/**/README.md`, `workspace/**/PROJECT_AGENT.md`
2. 소스 스크립트 내 호환 안내:
   - `skills/aki-codex-session-reload/scripts/codex_skills_reload/*.sh`
   - `skills/aki-codex-session-reload/scripts/runtime_orchestrator/*`
   - `skills/aki-codex-core/scripts/create-backup-point.sh`
3. 정책:
   - 폐기 직전까지는 `skills/bin` 호환 명령 문구를 유지하고,
   - 최종 단계에서 source-first 문구로 일괄 전환한다.
