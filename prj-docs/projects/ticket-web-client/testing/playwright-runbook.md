# Playwright Runbook (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 21:12:00`
> - **Updated At**: `2026-02-20 02:20:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Preflight
> - Test List (List First)
> - Scope Execution
> - Full Execution
> - Evidence and Logs
> - MCP Demonstration
<!-- DOC_TOC_END -->

## Preflight
```bash
cd workspace/apps/frontend/ticket-web-client
npm install
npx playwright install chromium
```

## Test List (List First)
- 로컬 프로젝트 스크립트:
```bash
cd workspace/apps/frontend/ticket-web-client
npm run e2e:list
```
- 글로벌 래퍼 스크립트:
```bash
cd /home/aki/aki-agentops
./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh \
  --project-root workspace/apps/frontend/ticket-web-client \
  --list
```

## Scope Execution
```bash
cd /home/aki/aki-agentops
./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh \
  --project-root workspace/apps/frontend/ticket-web-client \
  --scope smoke

./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh \
  --project-root workspace/apps/frontend/ticket-web-client \
  --scope nav

./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh \
  --project-root workspace/apps/frontend/ticket-web-client \
  --scope contract

./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh \
  --project-root workspace/apps/frontend/ticket-web-client \
  --scope auth

./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh \
  --project-root workspace/apps/frontend/ticket-web-client \
  --scope realtime
```

## Full Execution
```bash
cd /home/aki/aki-agentops
./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh \
  --project-root workspace/apps/frontend/ticket-web-client \
  --scope all
```

## Evidence and Logs
- 실행 로그:
  - `.codex/tmp/frontend-playwright/ticket-web-client/<run-id>/run.log`
- 실행 요약:
  - `.codex/tmp/frontend-playwright/ticket-web-client/<run-id>/summary.txt`
- 브라우저 콘솔 로그:
  - `workspace/apps/frontend/ticket-web-client/test-results/<test-id>/browser-console.log`
- 최신 링크:
  - `.codex/tmp/frontend-playwright/ticket-web-client/latest`
- HTML 리포트(프로젝트 로컬):
  - `workspace/apps/frontend/ticket-web-client/playwright-report/index.html`

## MCP Demonstration
- Codex 사용자는 아래 순서로 증빙을 보여준다.
1. `--list`로 범위를 먼저 제시한다.
2. 사용자 선택 scope를 실행한다.
3. `snapshot`/`console` 로그를 텍스트로 우선 보고한다.
4. 사용자가 요청하면 screenshot을 추가한다.

## CI Split
- `workspace/apps/frontend/ticket-web-client/.github/workflows/e2e-smoke.yml`
  - PR/Push(main)에서 `e2e:smoke` 실행
- `workspace/apps/frontend/ticket-web-client/.github/workflows/e2e-nightly.yml`
  - schedule/manual에서 nightly(`all` 기본, `auth`/`realtime` 선택 가능) 실행
