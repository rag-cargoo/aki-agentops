# Meeting Notes: Checkout HOLD 취소 UX Follow-up (ticket-web-app)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-25 16:20:00`
> - **Updated At**: `2026-02-25 17:22:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 사용자 불편점
> - 안건 2: UX 동작 결정
> - 안건 3: API 연동 원칙
> - 안건 4: 후속 검증
<!-- DOC_TOC_END -->

## 안건 1: 사용자 불편점
- Status: DONE
- 요약:
  - 좌석 예약(HOLD) 완료 후에는 모달에서 취소가 불가능해 사용자가 즉시 되돌릴 수 없다.
  - 다중 좌석 선택 시 전체 취소를 한 번에 처리하는 동작이 필요하다.

## 안건 2: UX 동작 결정
- Status: DONE
- 결정:
  - 선택 좌석 테이블의 `X`는 HOLD 상태에서도 동작하게 유지한다.
  - `전체 취소`는 HOLD 상태일 때 벌크 취소 API를 호출한다.
  - 취소 완료 시 `선택 좌석 목록`, `결제 진행 가능 상태`, `좌석 가용 목록`을 즉시 동기화한다.

## 안건 3: API 연동 원칙
- Status: DONE
- 기준:
  - 단건 취소: `POST /api/reservations/v7/{reservationId}/cancel`
  - 벌크 취소: `POST /api/reservations/v7/cancel/bulk`
  - 실패 메시지는 좌석 단위 식별 가능하도록 사용자 문구에 반영한다.

## 안건 4: 후속 검증
- Status: DOING
- 후속:
  - [x] `npm run build` 통과
  - [ ] 실제 모달 시나리오(단건 취소/전체 취소/취소 후 재선택/결제창 닫힘) 수동 검증
  - [x] 이슈/task 문서 상태 동기화
