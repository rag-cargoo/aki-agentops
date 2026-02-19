# Task Dashboard (ticket-web-client sidecar)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 20:36:00`
> - **Updated At**: `2026-02-20 02:20:00`
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

## Next Items
- 현재 고정된 후속 항목 없음 (새 요구 수신 대기)
