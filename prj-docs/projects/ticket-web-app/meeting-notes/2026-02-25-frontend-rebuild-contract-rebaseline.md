# Meeting Notes: Frontend Rebuild Contract Rebaseline (ticket-web-app)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-25 06:22:00`
> - **Updated At**: `2026-02-25 06:22:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 재베이스라인 필요성
> - 안건 2: 백엔드 계약 재확인 결과
> - 안건 3: 프론트 IA/예매 플로우 재확정
> - 안건 4: 즉시 실행 항목
<!-- DOC_TOC_END -->

## 안건 1: 재베이스라인 필요성
- Status: DONE
- 결정:
  - 기존 문서의 완료 표기가 실제 구현 상태와 불일치하는 항목이 있어, 제품 문서 3종을 백엔드 코드 기준으로 재작성한다.
  - 문서에는 "완료"뿐 아니라 `DOING/TODO/RISK/BLOCKED`를 함께 기록해 실제 진행상태를 노출한다.

## 안건 2: 백엔드 계약 재확인 결과
- Status: DONE
- 확인사항:
  - 결제 provider 기본값은 `pg-ready`이며, 현재 runtime catalog에서 `defaultMethod=CARD`, `WALLET disabled=false가 아니라 disabled=true` 상태다.
  - confirm 응답은 `paymentAction(REDIRECT/WAIT_WEBHOOK/RETRY_CONFIRM)` 분기 처리가 필수다.
  - 좌석 soft-lock API(`v7/locks/seats`)와 seat-map WS topic(`/topic/seats/{optionId}`) 계약이 이미 존재한다.
  - `GET /api/concerts/search`는 현 환경에서 500(SQL `lower(bytea)`)이 재현되어 목록 안정성 리스크가 있다.

## 안건 3: 프론트 IA/예매 플로우 재확정
- Status: DONE
- 결정:
  - 메인 `/service`는 공연 탐색/예매 진입만 담당한다.
  - 결제/지갑/내예약은 프로필 메뉴 기반 `/account/*`에서 처리한다.
  - 예매는 카드 클릭 즉시 자동 체인이 아니라 checkout modal에서 단계형(`좌석 선택 -> soft-lock -> hold -> paying -> confirm`)으로 수행한다.

## 안건 4: 즉시 실행 항목
- Status: DOING
- 실행 계획:
  - `ServiceCheckoutModal`를 `ServicePage` 카드 CTA와 연결 (완료)
  - `runReservationV7Flow` fail-open fallback 제거 (완료)
  - `payments/methods` 실패 시 WALLET 강제 전환 로직 제거
  - WS seat-map 구독 + fallback poll 전략 구현
- 증빙 문서:
  - `prj-docs/projects/ticket-web-app/product-docs/backend-contract-inventory.md`
  - `prj-docs/projects/ticket-web-app/product-docs/frontend-implementation-blueprint.md`
  - `prj-docs/projects/ticket-web-app/product-docs/backend-capability-adoption-checklist.md`
  - `prj-docs/projects/ticket-web-app/task.md`
