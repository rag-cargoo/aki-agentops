# Meeting Notes: SC016 Admin CRUD Adapter and Playwright Scope (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-20 18:26:40`
> - **Updated At**: `2026-02-20 18:26:40`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: SC016 구현 범위 확정
> - 안건 2: Admin API 어댑터/화면 반영
> - 안건 3: Playwright admin scope 및 전역 래퍼 동기화
> - 안건 4: 이슈/검증/후속
<!-- DOC_TOC_END -->

## 안건 1: SC016 구현 범위 확정
- Status: DONE
- 처리결과:
  - `/admin` 라우트를 placeholder 텍스트에서 실제 운영 CRUD 화면으로 전환한다.
  - 1차 범위는 아래로 고정한다.
    - 공연 create/update/delete
    - 옵션(date/seatCount/price) create/update/delete
    - 판매 정책 upsert/reload
    - 썸네일 multipart upload/delete
    - 유튜브 링크 메타 입력/수정

## 안건 2: Admin API 어댑터/화면 반영
- Status: DONE
- 처리결과:
  - `src/shared/api/admin-concert-client.ts` 신규 추가
    - `/api/admin/concerts/**`, `/api/concerts/{id}/options`, `/api/concerts/{id}/sales-policy` 호출을 통합
    - 에러 정규화(`AdminConcertApiError`)와 타입 파싱을 일관 처리
  - `src/app/pages/AdminPage.tsx`를 CRUD 실행 UI로 교체
    - Token 입력, 공연 목록/선택, 생성/수정/삭제
    - 옵션 생성/수정/삭제
    - 판매정책 저장/재로드
    - 썸네일 업로드/삭제 + 프리뷰
  - `src/app/App.tsx`에서 `AdminPage`에 `apiBaseUrl/accessToken` 주입
  - `src/app/App.css`에 admin 전용 레이아웃/폼/리스트 스타일 추가

## 안건 3: Playwright admin scope 및 전역 래퍼 동기화
- Status: DONE
- 처리결과:
  - `tests/e2e/landing.spec.ts`에 `@admin` 시나리오 추가
    - 공연/옵션/정책/썸네일 전체 흐름을 route mocking으로 회귀 검증
  - 로컬 실행 스코프 추가
    - `package.json`: `e2e:admin`
    - `scripts/playwright/list-scopes.mjs`: `admin`
    - `scripts/playwright/run-playwright.sh`: `admin`
  - 전역 래퍼 동기화
    - `skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh`에 `admin` scope 지원 추가

## 안건 4: 이슈/검증/후속
- Status: DONE
- 이슈:
  - 신규 이슈 생성: `ticket-web-client#7`
  - 링크: `https://github.com/rag-cargoo/ticket-web-client/issues/7`
  - 진행 코멘트: `https://github.com/rag-cargoo/ticket-web-client/issues/7#issuecomment-3932659509`
  - 생성 근거:
    - SC015(#6) 리팩토링 범위와 SC016 운영 CRUD 범위가 달라 재오픈 대신 신규 생성
- 검증:
  - `npm run typecheck` PASS
  - `npm run build` PASS
  - `npm run e2e:admin` PASS
  - `npm run e2e:all` PASS (9 passed)
  - wrapper `--scope admin` PASS
- 증빙:
  - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-182534-76641/summary.txt`
  - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-182534-76641/run.log`
- Next:
  - 없음(현재 sidecar 체크리스트 기준 16/16 완료)
