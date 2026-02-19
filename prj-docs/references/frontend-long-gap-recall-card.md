# Frontend Long-Gap Recall Card

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 21:26:00`
> - **Updated At**: `2026-02-19 21:26:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Purpose
> - Prompt Shortcuts
> - Command Shortcuts
> - Evidence Paths
<!-- DOC_TOC_END -->

## Purpose
- 오랜 시간 뒤 복귀해도 프론트 작업 흐름(문서/테스트/시연)을 즉시 재개하기 위한 1페이지 카드.

## Prompt Shortcuts
- `프론트 Playwright 테스트 목록 보여주고 scope별로 실행해줘`
- `프론트 sidecar 문서 기준으로 기능 상세/TODO/회의록 동기화해줘`
- `프론트 전체 e2e 돌리고 로그 경로까지 보고해줘`

## Command Shortcuts
- scope 목록:
```bash
./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh \
  --project-root workspace/apps/frontend/<service> \
  --list
```
- scope 실행:
```bash
./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh \
  --project-root workspace/apps/frontend/<service> \
  --scope smoke
```
- 전체 실행:
```bash
./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh \
  --project-root workspace/apps/frontend/<service> \
  --scope all
```

## Evidence Paths
- 실행 로그: `.codex/tmp/frontend-playwright/<service>/<run-id>/run.log`
- 실행 요약: `.codex/tmp/frontend-playwright/<service>/<run-id>/summary.txt`
- 브라우저 콘솔: `workspace/apps/frontend/<service>/test-results/<test-id>/browser-console.log`
- HTML 리포트: `workspace/apps/frontend/<service>/playwright-report/index.html`
