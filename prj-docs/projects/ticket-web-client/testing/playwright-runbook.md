# Playwright Runbook (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 21:12:00`
> - **Updated At**: `2026-02-20 18:26:40`
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
> - Execution History
> - Evidence and Logs
> - MCP Demonstration
<!-- DOC_TOC_END -->

## Preflight
```bash
cd workspace/apps/frontend/ticket-web-client
npm install
npx playwright install chromium
```

## Service-first UI Rule
- 기본 사용자 화면은 `Home/Highlights/Gallery/Queue`만 노출한다.
- 상단 라우트 네비는 `Service/Admin/Labs`로 페이지 분류를 제공한다.
- 각 라우트는 별도 섹션 네비를 제공한다.
  - `/`: `Home/Highlights/Gallery/Queue`
  - `/admin`: `Concerts/Seat & Price/Media`
  - `/labs`: `Contract/Auth/Realtime`
- Dev Lab(`Contract/Auth/Realtime`)은 `/labs` 라우트에서만 노출한다.
- `/labs` 진입 시에도 아래 조건이 없으면 비노출된다.
  - `?labs=1`
  - `VITE_APP_DEV_LABS=1`
  - e2e probe(`VITE_E2E_CONSOLE_LOG=1`)

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
  --scope queue

./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh \
  --project-root workspace/apps/frontend/ticket-web-client \
  --scope contract

./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh \
  --project-root workspace/apps/frontend/ticket-web-client \
  --scope auth

./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh \
  --project-root workspace/apps/frontend/ticket-web-client \
  --scope realtime

./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh \
  --project-root workspace/apps/frontend/ticket-web-client \
  --scope admin
```

- `queue` scope는 예매 체인 + My Reservations(`v7/me`, cancel/refund)까지 포함해 검증한다.
- `realtime` scope는 websocket->sse fallback + Queue/My Reservations 상태 병합까지 포함해 검증한다.
- `realtime` scope에는 transport interruption 이후 reconnect backoff 복구 케이스가 포함된다.
- `admin` scope는 관리자 CRUD(공연/옵션/정책/썸네일) 어댑터 흐름을 검증한다.

## Auth Scope Note
- `auth` scope는 OAuth provider 실제 로그인 없이도 회귀 가능하도록 Playwright route mocking을 사용한다.
- 실 provider 검증이 필요할 때는 backend `run-auth-social-real-provider-e2e.sh` 체인과 함께 HITL로 분리 실행한다.

## Full Execution
```bash
cd /home/aki/aki-agentops
./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh \
  --project-root workspace/apps/frontend/ticket-web-client \
  --scope all
```

## Execution History
- 전역 래퍼 실행 시 아래 파일에 실행 이력이 자동 누적된다.
  - `prj-docs/projects/ticket-web-client/testing/playwright-execution-history.md`
- 실행 단위 기록 필드:
  - `Executed At`, `Scope`, `Result`, `Run ID`, `Summary`, `Log`
- 커스텀 경로를 강제하려면:
```bash
./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh \
  --project-root workspace/apps/frontend/ticket-web-client \
  --scope smoke \
  --history-file prj-docs/projects/ticket-web-client/testing/playwright-execution-history.md
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

## Realtime Runtime Toggle
- mock 강제:
  - `VITE_APP_REALTIME_MOCK=1`
- 실 transport 강제:
  - `VITE_APP_REALTIME_MOCK=0`
- reconnect 제어:
  - `VITE_APP_REALTIME_RECONNECT=1`
  - `VITE_APP_REALTIME_RECONNECT_MAX_ATTEMPTS=5`
  - `VITE_APP_REALTIME_RECONNECT_BASE_DELAY_MS=1000`
  - `VITE_APP_REALTIME_RECONNECT_MAX_DELAY_MS=15000`

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
