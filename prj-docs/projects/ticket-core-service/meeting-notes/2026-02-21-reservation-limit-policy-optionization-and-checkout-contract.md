# Meeting Notes: Reservation Limit Policy Optionization and Checkout Contract (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-21 09:35:00`
> - **Updated At**: `2026-02-22 06:20:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 한도 정책 옵션화 범위
> - 안건 2: 결제창/확인 단계 계약
> - 안건 3: 백엔드 상태전이 책임 경계
> - 안건 4: API/모델 변경 계획
> - 진행현황: 완료/남은 항목
> - 결정 대기 항목
<!-- DOC_TOC_END -->

## 안건 1: 한도 정책 옵션화 범위
- Status: AGREED
- 결정사항:
  - 콘서트별 Sales Policy에 아래 한도값을 옵션 필드로 관리한다.
    - `maxTicketsPerOrder` (1회 주문 최대 매수)
    - `maxTicketsPerUserPerConcert` (1인 총 구매 한도)
    - `maxConcurrentHoldsPerUser` (동시 홀드 한도)
  - 하드코딩 대신 콘서트 CRUD에서 생성/수정 가능하도록 API 계약을 확장한다.
  - 기본값은 `application.yml` 기반 fallback을 두고, 콘서트별 값이 있으면 override한다.

## 안건 2: 결제창/확인 단계 계약
- Status: AGREED
- 결정사항:
  - 현재 `좌석 선택 -> 즉시 hold/paying/confirm` 흐름은 사용자 인지 관점에서 결제확인 단계가 부족하다.
  - 프론트 결제 모달에서 아래를 먼저 표시한다.
    - 선택 좌석/회차/금액 요약
    - 결제 확인 문구(컨펌)
  - 사용자가 컨펌한 경우에만 백엔드 hold/paying/confirm 체인을 실행한다.

## 안건 3: 백엔드 상태전이 책임 경계
- Status: AGREED
- 기준 흐름:
  1. 좌석 선택
  2. 사용자 결제 확인(프론트)
  3. `HOLD` 생성(백엔드, 좌석 TEMP_RESERVED)
  4. 결제 승인 성공 시 `CONFIRMED`(좌석 RESERVED)
  5. 실패 시 `PAYING/HOLD` 유지(재시도 가능)
  6. TTL 만료 시 백엔드가 `EXPIRED`로 전환하고 좌석 해제
- 책임 경계:
  - 프론트는 상태 표시/확인 UI 담당
  - 만료 판정/좌석 해제/상태전이는 백엔드 단일 책임

## 안건 4: API/모델 변경 계획
- Status: DONE
- Workstream:
  1. (완료) `SalesPolicy` 엔티티/DTO/API에 3개 한도 필드 추가
  2. (완료) `validateHoldRequest`에서 총 한도/동시 홀드 한도 적용
  3. (완료) `seatIds[]` 기반 다중 좌석 주문 계약으로 hold/paying/confirm 경로 확장
  4. (완료) 주문 단위 회귀 테스트 추가
    - 주문당 최대 매수(`maxTicketsPerOrder`) 경계값 검증
    - 주문 단위 paying/confirm/cancel/refund 검증
    - 만료/취소 후 좌석/카운트 정상 복원 검증

## 진행현황: 완료/남은 항목
- Status: DONE
- 완료된 것:
  - 정책 옵션화 방향(콘서트별 CRUD + 기본값 fallback) 합의
  - 결제 확인 UI 선행 후 hold/paying/confirm 실행 계약 합의
  - 상태전이 책임 경계(프론트 표시, 백엔드 판정) 재확인
  - 트래킹 이슈 생성:
    - `https://github.com/rag-cargoo/ticket-core-service/issues/20` (closed)
    - 생성 근거 코멘트: `https://github.com/rag-cargoo/ticket-core-service/issues/20#issuecomment-3937779070`
    - 진행 코멘트: `https://github.com/rag-cargoo/ticket-core-service/issues/20#issuecomment-3937787703`
    - 완료 코멘트: `https://github.com/rag-cargoo/ticket-core-service/issues/20#issuecomment-3939533794`
  - 구현 완료:
    - `SalesPolicy` 필드 확장(`maxTicketsPerOrder`, `maxTicketsPerUserPerConcert`, `maxConcurrentHoldsPerUser`)
    - `SalesPolicyUpsertRequest/Response` 신규 필드 + legacy alias 호환
    - 정책 fallback 설정(`app.sales-policy.*`) 및 `SalesPolicyLimitProperties` 추가
    - `validateHoldRequest`에 총 한도/동시 홀드 한도 검증 반영
    - `POST /api/reservations/v7/holds/batch` 추가(`seatIds[]` 기반 다중 HOLD 생성)
    - `POST /api/reservations/v7/orders/paying|confirm|cancel|refund` 추가(`reservationIds[]` 기반 주문 단위 상태전이)
    - 다중 HOLD 요청에서 주문 매수 기반 정책 검증 반영
      - 주문당 한도(`maxTicketsPerOrder`)
      - 총 한도(`maxTicketsPerUserPerConcert`)
      - 동시 홀드 한도(`maxConcurrentHoldsPerUser`)
    - `ReservationLifecycleServiceIntegrationTest` 케이스 추가
      - 다중 HOLD 성공/주문당 한도 초과
      - 주문 단위 paying/confirm
      - 주문 단위 cancel/refund
    - 결제 실패 시 홀드 연장 정책 반영
      - `app.reservation.payment-retry-hold-extension-seconds`
      - `app.reservation.max-payment-retry-hold-extensions`
      - 잔액 부족/비성공 결제 상태에서 `PAYING` 유지 + 1회 홀드 연장 응답
    - 주문 단위 `confirm` 정책 확정
      - 결제 실패 건은 `PAYING` 유지
      - 성공 건은 `CONFIRMED` 전이
      - 동일 주문 내 상태 혼재(부분 성공) 허용
    - 한도 기본값 운영값 고정
      - `default-max-tickets-per-order: 1`
      - `default-max-tickets-per-user-per-concert: 4`
      - `default-max-concurrent-holds-per-user: 2`
  - 검증:
    - `./gradlew test --tests '*ReservationLifecycleServiceIntegrationTest'` PASS
- 남은 것:
  - 분산 환경 대규모 좌석 실시간 선점(soft lock) 상태머신은 별도 안건으로 분리
    - `https://github.com/rag-cargoo/ticket-core-service/issues/21`

## 결정 대기 항목
- Status: CLOSED
- 확정사항:
  - 한도 기본값은 운영 기본값 `1/4/2`로 고정하고, 콘서트별 policy 값으로 override한다.
  - 다중 좌석 주문 `confirm`은 현재 구현 기준으로 부분 성공 허용 정책을 사용한다.
  - 절대 상한값(예: 주문당 최대 4 고정 등)은 본 이슈 범위에서는 별도 도입하지 않고,
    도메인 제약(양수/상호관계) + 운영 설정값으로 관리한다.
