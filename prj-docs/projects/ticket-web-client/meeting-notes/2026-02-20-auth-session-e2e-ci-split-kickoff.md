# Meeting Notes: Auth/Session E2E + CI Split Kickoff (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-20 01:28:00`
> - **Updated At**: `2026-02-20 02:20:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 진행 대상 확정
> - 안건 2: 구현 범위
> - 안건 3: 검증 범위
> - 안건 4: 이슈/태스크 동기화
<!-- DOC_TOC_END -->

## 안건 1: 진행 대상 확정
- Status: DONE
- 결정사항:
  - `TWC-SC-006`를 현재 우선순위로 착수한다.
  - 범위는 auth/session e2e 추가 + CI 스케줄 분리(`smoke`/`nightly`)다.

## 안건 2: 구현 범위
- Status: DONE
- 범위:
  - Auth Session Lab(로그인/만료/재발급/로그아웃/API 호출 시뮬레이션) UI 추가
  - Playwright `auth` scope 추가
  - 실행 스크립트/카탈로그에 `auth` scope 반영
- 결과:
  - `src/app/App.tsx`에 Auth Session Lab 섹션/상태/로그/콘솔 probe 추가 완료
  - `tests/e2e/landing.spec.ts`에 `@auth` 시나리오 추가 완료
  - scope 목록/실행 스크립트(`list-scopes.mjs`, `run-playwright.sh`, global wrapper) 반영 완료

## 안건 3: 검증 범위
- Status: DONE
- 범위:
  - `typecheck`, `build`, `e2e:auth`, `e2e:all`
  - CI workflow 분리:
    - PR/Push: smoke
    - schedule/manual: nightly(all)
- 결과:
  - `npm run typecheck` PASS
  - `npm run build` PASS
  - `npm run e2e:auth` PASS
  - `npm run e2e:all` PASS (5 passed)
  - `run-playwright-suite.sh --scope all` PASS
  - CI workflow 추가:
    - `workspace/apps/frontend/ticket-web-client/.github/workflows/e2e-smoke.yml`
    - `workspace/apps/frontend/ticket-web-client/.github/workflows/e2e-nightly.yml`

## 안건 4: 이슈/태스크 동기화
- Status: DONE
- 처리계획:
  - 이슈 `#118`에 TWC-SC-006 착수 코멘트 누적
  - `task.md`의 TWC-SC-006 상태를 `DOING`으로 전환
- 처리결과:
  - `task.md`를 `DONE`으로 최종 동기화
  - 완료 증빙 로그:
    - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-015058-3253606/run.log`
    - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-015058-3253606/summary.txt`
