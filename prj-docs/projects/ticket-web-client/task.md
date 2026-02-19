# Task Dashboard (ticket-web-client sidecar)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 20:36:00`
> - **Updated At**: `2026-02-20 06:42:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Checklist
> - Current Items
> - Next Items
<!-- DOC_TOC_END -->

## Scope
- 이 문서는 `ticket-web-client` 운영 sidecar 태스크를 관리한다.
- 구현 상세 태스크는 제품 레포 이슈/PR에서 관리한다.

## Checklist
- [x] TWC-SC-001 프론트 프로젝트 sidecar 등록 및 기본 문서 생성
- [x] TWC-SC-002 글로벌 프론트 개발 규칙 스킬 생성 및 연결
- [x] TWC-SC-003 Playwright 파트별 시연/로그 검증 문서화
- [x] TWC-SC-004 장기 공백 복귀용 Frontend 리마인더 자동화
- [x] TWC-SC-005 WS/SSE 실시간 시나리오 Playwright 케이스 확장
- [x] TWC-SC-006 Auth/session 흐름 e2e + CI 파이프라인 분리(smoke/nightly)
- [x] TWC-SC-007 Playwright 실행 이력 누적 거버넌스(글로벌/프로젝트 동기화)
- [x] TWC-SC-008 메인 화면 서비스 우선 정렬 + Dev Lab 분리
- [x] TWC-SC-009 티켓 목록 판매상태/카운트다운 계약 + 예매 버튼 노출 연동
- [x] TWC-SC-010 Queue 카드 `예매하기` v7 hold/paying/confirm 연동

## Current Items
- TWC-SC-001 프론트 프로젝트 sidecar 등록 및 기본 문서 생성
  - Status: DONE
  - Description:
    - `project-map.yaml`에 `ticket-web-client`를 등록하고 sidecar 기본 문서를 생성
    - Active Project 전환 시 요구되는 기본 파일(`PROJECT_AGENT.md`, `task.md`, `meeting-notes/README.md`, `rules/`)을 충족
  - Evidence:
    - `prj-docs/projects/project-map.yaml`
    - `prj-docs/projects/ticket-web-client/README.md`
    - `prj-docs/projects/ticket-web-client/PROJECT_AGENT.md`
    - `prj-docs/projects/ticket-web-client/meeting-notes/README.md`

- TWC-SC-002 글로벌 프론트 개발 규칙 스킬 생성 및 연결
  - Status: DONE
  - Description:
    - 서비스 비종속 `aki-frontend` 규칙 스킬을 추가
    - sidecar `PROJECT_AGENT.md`와 연결
  - Evidence:
    - `skills/aki-frontend-delivery-governance/SKILL.md`
    - `skills/aki-frontend-delivery-governance/references/playwright-partition-runbook.md`
    - `prj-docs/projects/ticket-web-client/PROJECT_AGENT.md`

- TWC-SC-003 Playwright 파트별 시연/로그 검증 문서화
  - Status: DONE
  - Description:
    - 기능 상세 문서 + Playwright 카탈로그/실행 가이드 작성
    - list-first, 파트별 실행, 콘솔 로그 검증 기준 고정
  - Evidence:
    - `prj-docs/projects/ticket-web-client/product-docs/frontend-feature-spec.md`
    - `prj-docs/projects/ticket-web-client/testing/playwright-suite-catalog.md`
    - `prj-docs/projects/ticket-web-client/testing/playwright-runbook.md`
    - `prj-docs/projects/ticket-web-client/meeting-notes/2026-02-19-frontend-governance-and-playwright-baseline.md`
    - `workspace/apps/frontend/ticket-web-client/tests/e2e/landing.spec.ts`
    - `workspace/apps/frontend/ticket-web-client/scripts/playwright/run-playwright.sh`

- TWC-SC-004 장기 공백 복귀용 Frontend 리마인더 자동화
  - Status: DONE
  - Description:
    - 프론트 Active Project일 때 `session_start.sh` 결과에 Frontend Quick Remind를 자동 노출
    - 장기 공백 복귀용 리콜 카드 문서를 공개 내비게이션에 연결
  - Evidence:
    - `skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
    - `prj-docs/references/frontend-long-gap-recall-card.md`
    - `prj-docs/references/aki-skills-user-prompt-guide.md`

- TWC-SC-005 WS/SSE 실시간 시나리오 Playwright 케이스 확장
  - Status: DONE
  - Description:
    - Realtime demo panel + websocket 실패 시 sse fallback 시뮬레이션 추가
    - Playwright `realtime` scope 추가 및 목록/실행 스크립트 반영
  - Evidence:
    - `workspace/apps/frontend/ticket-web-client/src/app/App.tsx`
    - `workspace/apps/frontend/ticket-web-client/src/shared/realtime/create-realtime-client.ts`
    - `workspace/apps/frontend/ticket-web-client/src/shared/realtime/transports/mock/create-mock-transports.ts`
    - `workspace/apps/frontend/ticket-web-client/tests/e2e/landing.spec.ts`
    - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-011504-3212976/run.log`
    - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-011504-3212976/summary.txt`

- TWC-SC-006 Auth/session 흐름 e2e + CI 파이프라인 분리(smoke/nightly)
  - Status: DONE
  - Description:
    - Auth Session Lab(로그인/만료/재발급/로그아웃/보호 API 호출) UI 및 상태/로그 패널 추가
    - Playwright `auth` scope + 스코프 실행 스크립트/카탈로그 반영
    - GitHub Actions workflow를 `e2e-smoke`/`e2e-nightly`로 분리
  - Evidence:
    - `workspace/apps/frontend/ticket-web-client/src/app/App.tsx`
    - `workspace/apps/frontend/ticket-web-client/tests/e2e/landing.spec.ts`
    - `workspace/apps/frontend/ticket-web-client/scripts/playwright/list-scopes.mjs`
    - `workspace/apps/frontend/ticket-web-client/scripts/playwright/run-playwright.sh`
    - `workspace/apps/frontend/ticket-web-client/.github/workflows/e2e-smoke.yml`
    - `workspace/apps/frontend/ticket-web-client/.github/workflows/e2e-nightly.yml`
    - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-015058-3253606/run.log`
    - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-015058-3253606/summary.txt`

- TWC-SC-007 Playwright 실행 이력 누적 거버넌스(글로벌/프로젝트 동기화)
  - Status: DONE
  - Description:
    - 전역 프론트 규칙에 실행 이력 누적 계약을 추가
    - 전역 래퍼 실행 시 sidecar 이력 문서를 자동 append하도록 구현
    - ticket-web-client sidecar에 실행 이력 문서/런북/카탈로그/내비게이션 동기화
  - Evidence:
    - `skills/aki-frontend-delivery-governance/SKILL.md`
    - `skills/aki-frontend-delivery-governance/references/sidecar-frontend-docs-contract.md`
    - `skills/aki-frontend-delivery-governance/references/playwright-execution-history-template.md`
    - `skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh`
    - `prj-docs/projects/ticket-web-client/testing/playwright-execution-history.md`
    - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-020706-3275247/run.log`
    - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-020706-3275247/summary.txt`

- TWC-SC-008 메인 화면 서비스 우선 정렬 + Dev Lab 분리
  - Status: DONE
  - Description:
    - 기본 랜딩에서 테스트 패널(Contract/Auth/Realtime)을 숨기고 서비스 섹션 우선 구성으로 재정렬
    - Dev Lab은 `?labs=1` 또는 `VITE_APP_DEV_LABS=1`일 때만 노출되도록 분리
    - e2e probe 모드에서는 기존 계약/인증/실시간 테스트가 유지되도록 호환
  - Evidence:
    - `workspace/apps/frontend/ticket-web-client/src/app/App.tsx`
    - `workspace/apps/frontend/ticket-web-client/src/app/App.css`
    - `workspace/apps/frontend/ticket-web-client/src/vite-env.d.ts`
    - `prj-docs/projects/ticket-web-client/product-docs/frontend-feature-spec.md`
    - `prj-docs/projects/ticket-web-client/testing/playwright-suite-catalog.md`
    - `prj-docs/projects/ticket-web-client/testing/playwright-runbook.md`

- TWC-SC-009 티켓 목록 판매상태/카운트다운 계약 + 예매 버튼 노출 연동
  - Status: DONE
  - Description:
    - 백엔드 목록 응답에 오픈 임계(1h/5m) 기반 `saleStatus`/카운트다운/버튼 노출 필드 추가
    - 프론트에서 응답값 기반으로 예매 버튼 노출/활성 시점을 제어할 수 있도록 계약 고정
    - Queue 섹션을 정적 KPI 카드에서 실 API(`concerts/search`) 기반 목록으로 전환
  - Evidence:
    - `prj-docs/projects/ticket-web-client/meeting-notes/2026-02-20-ticket-listing-sale-status-and-media-contract-kickoff.md`
    - `workspace/apps/frontend/ticket-web-client/src/shared/api/fetch-concert-search-page.ts`
    - `workspace/apps/frontend/ticket-web-client/src/app/App.tsx`
    - `workspace/apps/frontend/ticket-web-client/src/app/App.css`
    - `workspace/apps/frontend/ticket-web-client/vite.config.ts`
    - `workspace/apps/frontend/ticket-web-client/.env.example`
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/api/dto/ConcertResponse.java`
    - `prj-docs/projects/ticket-core-service/product-docs/api-specs/concert-api.md`
    - `AKI AgentOps Issue #128`: `https://github.com/rag-cargoo/aki-agentops/issues/128`
    - `Issue Progress Comment`: `https://github.com/rag-cargoo/aki-agentops/issues/128#issuecomment-3929066936`

- TWC-SC-010 Queue 카드 `예매하기` v7 hold/paying/confirm 연동
  - Status: DONE
  - Description:
    - Queue 카드 클릭 시 `concert options -> available seats -> reservations/v7/holds -> /paying -> /confirm` 체인으로 실제 예약 전이를 수행한다.
    - 카드 단위 진행상태(`running/success/error`)와 메시지, 재시도 UX를 추가했다.
    - Queue scope Playwright 케이스를 추가하고 글로벌 래퍼/로컬 스크립트 모두 `queue` scope를 지원하도록 동기화했다.
  - Evidence:
    - `workspace/apps/frontend/ticket-web-client/src/shared/api/run-reservation-v7-flow.ts`
    - `workspace/apps/frontend/ticket-web-client/src/app/App.tsx`
    - `workspace/apps/frontend/ticket-web-client/src/app/App.css`
    - `workspace/apps/frontend/ticket-web-client/tests/e2e/landing.spec.ts`
    - `workspace/apps/frontend/ticket-web-client/scripts/playwright/list-scopes.mjs`
    - `workspace/apps/frontend/ticket-web-client/scripts/playwright/run-playwright.sh`
    - `skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh`
    - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-063756-3625555/run.log`
    - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-063756-3625555/summary.txt`
    - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-063816-3626289/run.log`
    - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-063816-3626289/summary.txt`
    - `ticket-web-client Issue #1`: `https://github.com/rag-cargoo/ticket-web-client/issues/1`
    - `Issue Progress Comment`: `https://github.com/rag-cargoo/ticket-web-client/issues/1#issuecomment-3930278588`

## Next Items
- TWC-SC-011 실제 OAuth 세션 발급(access/refresh) 연동 + `/api/auth/me` 기반 사용자 컨텍스트 표시
