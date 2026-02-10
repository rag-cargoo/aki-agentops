# Bin Wrapper Deprecation Inventory

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 17:26:35`
> - **Updated At**: `2026-02-09 17:53:22`
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
| B. 사용자 운영 문서/런북 | 24 | 운영 명령/가이드 | source 경로 전환 완료 |
| C. 소스 스크립트 내부 안내 문구/샘플 | 8 | help/로그/샘플 YAML/JSON | source 경로 전환 완료 |

## 즉시 전환 완료 항목
1. `.githooks/pre-commit`
   - `skills/bin/codex_skills_reload/*` -> `skills/aki-codex-session-reload/scripts/codex_skills_reload/*`
   - `skills/bin/validate-precommit-chain.sh` -> `skills/aki-codex-precommit/scripts/validate-precommit-chain.sh`
2. `.github/workflows/codex-skills-reload.yml`
   - syntax/session-start 경로를 session-reload 소스로 전환
3. `skills/aki-codex-precommit/policies/core-workspace.sh`
   - strict 모드 reload 검증 경로를 session-reload 소스로 전환

## 최종 상태
1. `skills/bin` 래퍼/링크 제거 완료.
2. 운영 경로(훅/CI/스크립트/런북)는 source 경로로 전환 완료.
3. `skills/bin` 문자열 잔존은 회의록/히스토리/폐기 추적 문서로 한정.
