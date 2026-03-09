# Meeting Notes: SC019 Frontend Service Contract Alignment Review (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-22 23:59:00`
> - **Updated At**: `2026-02-22 23:59:30`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 리뷰 범위
> - 안건 2: 핵심 발견사항
> - 안건 3: 서비스 정책 결정(토큰/계약)
> - 안건 4: task 동기화 및 우선순위
<!-- DOC_TOC_END -->

## 안건 1: 리뷰 범위
- Status: DONE
- 범위:
  - 서비스 사용자 플로우(`/`, `/service/reservations`) 기준 코드/계약 정합성 점검
  - 백엔드(`ticket-core-service`) 현재 API 시그니처와 프론트 호출 경로 대조
  - 실시간(WS/SSE) 구독 등록/해제 흐름과 회귀 검증 방식 점검

## 안건 2: 핵심 발견사항
- Status: DONE
- 발견사항:
  - `Critical`: 좌석 예매 모달 호출이 백엔드 v7 계약과 불일치
    - 프론트: `holds/batch`, `orders/paying`, `orders/confirm`
    - 백엔드: `holds`, `{reservationId}/paying`, `{reservationId}/confirm`
  - `High`: 주문 단위 취소/환불(`/v7/orders/{action}`) 호출이 백엔드 매핑과 불일치
  - `Medium`: 서비스 화면에 수동 Access Token 입력 UI가 남아 있고, 인증 게이트는 `authStatus` 중심이라 동작 정책이 일관되지 않음
  - `Medium`: 예약 실시간 구독 seatId snapshot이 연결 시점 + 최대 5건 기준이라 이후 신규 예약 반영 누락 가능성 존재
  - `Medium`: 현재 E2E가 API route mocking 중심이라 계약 불일치를 CI에서 조기 탐지하지 못함
  - `High`: Admin 화면 연동 기준 `/api/admin/concerts/**` 백엔드 `main` 구현 부재가 확인되어, 관리자 플로우는 백엔드 `Issue #16` 재오픈 의존성이 생김

## 안건 3: 서비스 정책 결정(토큰/계약)
- Status: DONE
- 결정사항:
  - 서비스 화면 정책은 `OAuth 세션 기반 인증`을 기준으로 고정한다.
  - 수동 토큰 입력은 서비스 화면에서 제거하고 필요 시 Labs 범위로 분리한다.
  - 예약/취소/환불 호출은 백엔드 현재 계약(단건 v7) 기준으로 정렬한다.
  - E2E는 유지하되, 별도로 `non-mock 실백엔드 smoke`를 추가해 계약 회귀를 보강한다.

## 안건 4: task 동기화 및 우선순위
- Status: DONE
- 처리결과:
  - sidecar task에 후속 항목 `TWC-SC-019`를 추가하고 `TODO`로 등록한다.
  - 백엔드 의존 갭은 `ticket-core-service Issue #16` 재오픈으로 연계한다.
  - 우선순위:
    - 1) 서비스 토큰 정책 단일화(수동 토큰 입력 제거)
    - 2) 예약/취소/환불 API 계약 정렬
    - 3) 실백엔드 smoke 검증 추가
    - 4) 실시간 예약 구독 갱신 전략 보완

## 증빙
- 프론트 코드:
  - `workspace/apps/frontend/ticket-web-client/src/app/pages/service/SeatReservationModal.tsx`
  - `workspace/apps/frontend/ticket-web-client/src/shared/api/reservation-v7-client.ts`
  - `workspace/apps/frontend/ticket-web-client/src/app/pages/service/QueueToolbar.tsx`
  - `workspace/apps/frontend/ticket-web-client/src/app/App.tsx`
- 백엔드 코드:
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/api/controller/ReservationController.java`
- 검증:
  - `workspace/apps/frontend/ticket-web-client`: `npm run typecheck` PASS, `npm run build` PASS
