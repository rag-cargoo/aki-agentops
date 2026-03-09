# Meeting Notes: Service/Admin/Labs Route Separation and Modular Refactor (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-20 10:18:00`
> - **Updated At**: `2026-02-20 10:18:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 리팩토링 범위 확정
> - 안건 2: 페이지 분리(서비스/어드민/검증랩)
> - 안건 3: App.tsx 모듈 분해
> - 안건 4: 검증/이슈/후속 작업
<!-- DOC_TOC_END -->

## 안건 1: 리팩토링 범위 확정
- Status: DONE
- 처리결과:
  - 한 화면에 혼재된 서비스/관리자/검증 UI를 라우트 기준으로 분리한다.
  - 목표 라우트:
    - `/` 서비스 사용자 페이지
    - `/admin` 관리자 전용 페이지
    - `/labs` 개발/검증 전용 페이지

## 안건 2: 페이지 분리(서비스/어드민/검증랩)
- Status: DONE
- 처리결과:
  - `ServicePage`로 기존 hero/highlights/gallery/queue/my-reservations 영역을 분리했다.
  - `LabsPage`로 contract/auth/realtime 검증 패널을 분리했다.
  - `AdminPage`를 별도 엔트리로 추가해 관리자 정보구조를 독립했다.
  - 상단 내비게이션에서 서비스 섹션 링크와 `Admin`/`Labs` 페이지 링크를 함께 제공한다.

## 안건 3: App.tsx 모듈 분해
- Status: DONE
- 처리결과:
  - `App.tsx`의 공통 타입을 `src/app/app-types.ts`로 분리했다.
  - `App.tsx` 유틸/환경 해석 로직을 `src/app/app-utils.ts`로 분리했다.
  - 페이지 렌더링 JSX를 `src/app/pages/*`로 이동해 `App.tsx` 책임을 라우팅/오케스트레이션으로 축소했다.

## 안건 4: 검증/이슈/후속 작업
- Status: DONE
- 검증:
  - `npm run typecheck` PASS
  - `npm run build` PASS
  - `npm run e2e:all` PASS (8 passed)
  - governance wrapper `--scope all` PASS
- 증빙:
  - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-100436-3863129/summary.txt`
  - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-100436-3863129/run.log`
- 이슈:
  - `ticket-web-client#6`: `https://github.com/rag-cargoo/ticket-web-client/issues/6`
- Next:
  - `TWC-SC-016` 관리자 CRUD(공연/좌석/가격/상태/썸네일 업로드/유튜브 링크) 1차 구현
