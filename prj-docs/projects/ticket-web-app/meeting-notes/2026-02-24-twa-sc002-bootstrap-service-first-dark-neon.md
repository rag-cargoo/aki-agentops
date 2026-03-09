# Meeting Notes: TWA-SC-002 Bootstrap and Service-First Dark Neon IA

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-24 10:43:00`
> - **Updated At**: `2026-02-24 10:43:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 구현 범위 고정
> - 안건 2: 라우트/IA 적용
> - 안건 3: 디자인 토큰/접근성 기준
> - 안건 4: 품질 게이트/CI
> - 안건 5: 검증 및 후속작업
<!-- DOC_TOC_END -->

## 안건 1: 구현 범위 고정
- Status: DONE
- 결정:
  - `TWA-SC-002`를 서비스 우선 UX 기준으로 구현한다.
  - 기본 라우트 분리를 `service/admin/labs`로 고정한다.

## 안건 2: 라우트/IA 적용
- Status: DONE
- 반영:
  - 경로 분리: `/service`, `/admin`, `/labs`
  - 헤더 전역 네비: `Service`, `Admin`, `Labs`
  - 기본 진입 `/`는 `/service`로 정렬
- 증빙:
  - `workspace/apps/frontend/ticket-web-app/src/App.tsx`
  - `workspace/apps/frontend/ticket-web-app/src/components/HeaderNav.tsx`
  - `workspace/apps/frontend/ticket-web-app/src/pages/ServicePage.tsx`
  - `workspace/apps/frontend/ticket-web-app/src/pages/AdminPage.tsx`
  - `workspace/apps/frontend/ticket-web-app/src/pages/LabsPage.tsx`

## 안건 3: 디자인 토큰/접근성 기준
- Status: DONE
- 반영:
  - 다크 + 네온 포인트 토큰(배경/텍스트/강조색/보더/글로우)
  - 카드 기반 레이아웃 + 반응형 기본 대응
  - skip link + `aria-label`/`aria-current` + `focus-visible` 유지
- 증빙:
  - `workspace/apps/frontend/ticket-web-app/src/styles.css`

## 안건 4: 품질 게이트/CI
- Status: DONE
- 반영:
  - 스크립트: `lint`, `typecheck`, `build`
  - CI: push/PR에서 동일 게이트 실행
  - 런타임 샘플 env: `.env.example`
- 증빙:
  - `workspace/apps/frontend/ticket-web-app/package.json`
  - `workspace/apps/frontend/ticket-web-app/scripts/lint-style.mjs`
  - `workspace/apps/frontend/ticket-web-app/.github/workflows/ci.yml`
  - `workspace/apps/frontend/ticket-web-app/.env.example`

## 안건 5: 검증 및 후속작업
- Status: DONE
- 검증 결과:
  - `npm run lint` pass
  - `npm run typecheck` pass
  - `npm run build` pass
  - dev route check: `/service`, `/admin`, `/labs` HTTP 200 확인
- 관련 이슈:
  - `https://github.com/rag-cargoo/ticket-web-app/issues/1`
- 다음 작업:
  - `TWA-SC-003` SC019 Sprint-1 이관(토큰 정책/예약 API 경로/non-mock smoke)
