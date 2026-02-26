# Meeting Notes: Backend Contract-First Planning and Front Alignment

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-25 01:27:00`
> - **Updated At**: `2026-02-25 01:39:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 백엔드 계약 우선 원칙 재확정
> - 안건 2: 도메인/상태전이/권한 경계 고정
> - 안건 3: 프론트 구현 우선순위 재정렬
> - 안건 4: 즉시 반영 항목
<!-- DOC_TOC_END -->

## 안건 1: 백엔드 계약 우선 원칙 재확정
- Status: DONE
- 결정:
  - 프론트 구현은 백엔드 코드 계약을 우선으로 하고, 문서/실응답 드리프트는 보조 노트로 병행 관리한다.
  - 개발 편의 가정(임의 필드/임의 정책)을 금지한다.

## 안건 2: 도메인/상태전이/권한 경계 고정
- Status: DONE
- 확정:
  - 도메인 축: Auth, Catalog, Reservation Lifecycle, Sales Policy, Wallet/Payment, Waiting Queue/Realtime, Admin
  - 예약 상태: `HOLD -> PAYING -> CONFIRMED -> CANCELLED -> REFUNDED` (+ `EXPIRED`)
  - 결제 기본 provider: `wallet` (잔액 부족 시 `409 CONFLICT`)
  - 권한 경계: `v7/auth/logout/me/ws` 인증 필수, `/api/admin/**` 관리자 정책 적용
- 증빙:
  - `prj-docs/projects/ticket-web-app/product-docs/backend-contract-inventory.md`

## 안건 3: 프론트 구현 우선순위 재정렬
- Status: DONE
- 결정:
  - 1순위: 계약 정렬(필드 드리프트 대응, Admin 정책 필드 정합)
  - 2순위: 실사용자 복구 UX(잔액 부족 -> 지갑 충전)
  - 3순위: 실시간/queue 보강과 non-mock smoke
- 증빙:
  - `prj-docs/projects/ticket-web-app/product-docs/frontend-implementation-blueprint.md`

## 안건 4: 즉시 반영 항목
- Status: DONE
- 실행 항목:
  - 콘서트 파서 `agency*`/`entertainment*` 동시 파싱
  - Admin 판매정책 UI를 `maxReservationsPerUser` 중심으로 단순화
  - 서비스 화면 지갑(잔액/충전/거래) UI + `Insufficient wallet balance` 복구 가이드 추가
- 증빙:
  - `workspace/apps/frontend/ticket-web-app/src/shared/api/admin-concert-client.ts`
  - `workspace/apps/frontend/ticket-web-app/src/pages/AdminPage.tsx`
  - `workspace/apps/frontend/ticket-web-app/src/shared/api/wallet-client.ts`
  - `workspace/apps/frontend/ticket-web-app/src/pages/ServicePage.tsx`
  - `workspace/apps/frontend/ticket-web-app/src/styles.css`
  - `npm run lint` pass
  - `npm run typecheck` pass
  - `npm run build` pass
