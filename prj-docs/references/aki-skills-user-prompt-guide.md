# Aki Skills User Prompt Guide (Public Mirror)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 17:28:03`
> - **Updated At**: `2026-02-19 21:12:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Purpose
> - Source
> - Quick Prompts
> - Long-Gap Recall
> - Runtime Status
> - Precommit
> - Notes
<!-- DOC_TOC_END -->

## Purpose
- 사용자 관점에서 Aki 스킬을 프롬프트로 호출할 때 기본 진입 문구를 빠르게 확인한다.

## Source
- Canonical Doc:
  - `skills/aki-codex-workflows/references/aki-skills-user-prompt-guide.md`
- 이 문서는 GitHub Pages 공개 탐색을 위한 미러다.

## Quick Prompts
- 상태 확인:
  - `상태정보 보여줘`
  - `런타임 경고만 보여줘`
- 문서 작업:
  - `문서 최신화해줘`
  - `사이드바 링크 깨짐 확인해줘`
- 운영 동기화:
  - `회의록 작성하고 task.md랑 GitHub 이슈까지 동기화해줘`
- 검증:
  - `프리커밋 quick 실행해줘`
  - `프리커밋 strict 실행해줘`
  - `프론트 Playwright 테스트 목록 보여주고 scope별로 실행해줘`

## Long-Gap Recall
- 복귀 시 바로 쓸 문구:
  - `프론트 작업 복귀용 체크리스트부터 보여줘`
  - `프론트 테스트 목록 먼저 보여주고 내가 scope 고르면 실행해줘`
- 빠른 카드:
  - [Frontend Long-Gap Recall Card](/prj-docs/references/frontend-long-gap-recall-card.md)

## Runtime Status
- `상태정보` 요청은 아래 경로로 처리된다.
  - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/show_runtime_status.sh`
- 기본 출력은 원문 상태표(`status`/`alerts`)다.

## Precommit
- quick:
  - `bash skills/aki-codex-precommit/scripts/validate-precommit-chain.sh --mode quick --all`
- strict:
  - `bash skills/aki-codex-precommit/scripts/validate-precommit-chain.sh --mode strict --all`

## Notes
- 상세 프롬프트/워크플로 설명은 canonical 문서를 따른다.
- 관련 문서:
  - [Skills Navigation Guide](/prj-docs/references/skills-navigation-guide.md)
