# Backend Contract Inventory (ticket-web-app)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-25 01:15:00`
> - **Updated At**: `2026-02-25 06:22:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Source of Truth
> - Runtime Snapshot
> - Domain Map
> - Endpoint Boundary
> - Reservation/Payment State Contract
> - Realtime Contract (WS/SSE)
> - Runtime/Profile Contract
> - Drift & Risks
> - Frontend Guardrails
<!-- DOC_TOC_END -->

## Scope
- 목적: `ticket-web-app` 프론트 구현의 백엔드 계약을 코드 기준으로 고정한다.
- 기준: 백엔드 구현체를 우선하고, 문서/실환경 응답은 보조 검증으로 기록한다.
- 비목표: 프론트 편의 가정(임의 필드/임의 상태 전이/하드코딩 정책) 허용 금지.

## Source of Truth
- Backend code root:
  - `workspace/apps/backend/ticket-core-service/src/main/java`
- Backend runtime config:
  - `workspace/apps/backend/ticket-core-service/src/main/resources/application.yml`
  - `workspace/apps/backend/ticket-core-service/src/main/resources/application-local.yml`
  - `workspace/apps/backend/ticket-core-service/src/main/resources/application-docker.yml`
- Key classes:
  - 예약 상태머신: `application/reservation/service/ReservationLifecycleServiceImpl.java`
  - 좌석 soft-lock: `application/reservation/service/SeatSoftLockServiceImpl.java`
  - 결제수단 카탈로그: `application/payment/service/PaymentMethodCatalogService.java`
  - 결제 webhook 처리: `application/payment/webhook/PgReadyWebhookService.java`
  - WS 구독 등록: `api/controller/WebSocketPushController.java`
  - 보안 경계: `global/config/SecurityConfig.java`

## Runtime Snapshot
- 검증일시: `2026-02-25`
- `GET /api/payments/methods` (`http://127.0.0.1:18080`) 응답:
  - `provider=pg-ready`
  - `defaultMethod=CARD`
  - `providerMode=PG_WEBHOOK_READY`
  - `WALLET enabled=false`
- `GET /api/concerts/search` (`18080`)는 현재 환경에서 `500` 케이스가 관측됨.
  - 에러: `lower(bytea)` SQL 예외
  - 이 항목은 프론트 설계 이슈가 아니라 백엔드/데이터 상태 리스크로 기록한다.

## Domain Map
- Auth Session/OAuth
  - `SocialAuthController`, `AuthController`
  - authorize-url, code exchange, refresh, me, logout
- Catalog/Concert
  - `ConcertController`, `AdminConcertController`
  - 공연/회차/좌석 조회, Admin CRUD, 썸네일, 판매정책
- Reservation Lifecycle (v7)
  - `ReservationController` + `ReservationLifecycleServiceImpl`
  - 핵심 전이: `HOLD -> PAYING -> CONFIRMED`
  - 후속 전이: `CONFIRMED -> CANCELLED -> REFUNDED`, timeout 시 `EXPIRED`
- Seat Soft Lock
  - `SeatSoftLockServiceImpl`
  - 선택 중 상태(`SELECTING`)를 TTL 기반으로 관리
- Payment
  - provider: `wallet`, `mock`, `pg-ready`
  - method catalog + method availability 검증
  - pg-ready는 webhook 승인 전 `PENDING`
- Realtime
  - Waiting Queue: SSE/WS
  - Reservation status: SSE/WS
  - Seat-map status: WS 경로 중심 (`SEAT_STATUS`)

## Endpoint Boundary
- Public
  - `GET /api/concerts/**`
  - `POST /api/concerts/setup`, `DELETE /api/concerts/cleanup/{concertId}`
  - `GET/POST /api/v1/waiting-queue/**`
  - `GET /api/auth/social/{provider}/authorize-url`
  - `POST /api/auth/social/{provider}/exchange`
  - `POST /api/auth/token/refresh`
- Auth required
  - `GET /api/auth/me`
  - `POST /api/auth/logout`
  - `POST /api/reservations/v7/locks/seats/{seatId}`
  - `DELETE /api/reservations/v7/locks/seats/{seatId}`
  - `POST /api/reservations/v7/holds`
  - `POST /api/reservations/v7/{reservationId}/paying`
  - `POST /api/reservations/v7/{reservationId}/confirm`
  - `POST /api/reservations/v7/{reservationId}/cancel`
  - `POST /api/reservations/v7/{reservationId}/refund`
  - `GET /api/reservations/v7/me`
  - `GET /api/reservations/v7/{reservationId}`
  - `POST|DELETE /api/push/websocket/**/subscriptions`
- Admin
  - `/api/admin/concerts/**`
  - `POST /api/reservations/v7/admin/{reservationId}/refund`
  - `GET /api/reservations/v7/audit/abuse`
  - `GET /api/reservations/v7/audit/admin-refunds`
- System (backend-only)
  - `POST /api/payments/webhooks/pg-ready`
  - OAuth callback endpoint `/login/oauth2/code/{provider}`

## Reservation/Payment State Contract
- Reservation states
  - `PENDING`, `HOLD`, `PAYING`, `CONFIRMED`, `EXPIRED`, `CANCELLED`, `REFUNDED`
- Seat states
  - `AVAILABLE`, `TEMP_RESERVED`, `RESERVED`
- Hold/timeout
  - `app.reservation.hold-ttl-seconds` (default `300`)
  - `app.reservation.soft-lock-ttl-seconds` (default `30`)

### Standard booking chain (v7)
1. 좌석 선택(optional strong mode)
- `POST /api/reservations/v7/locks/seats/{seatId}`
2. HOLD 생성
- `POST /api/reservations/v7/holds`
3. PAYING 전이
- `POST /api/reservations/v7/{reservationId}/paying`
4. CONFIRM
- `POST /api/reservations/v7/{reservationId}/confirm` with `paymentMethod`

### Confirm response contract
- 항상 확인할 필드:
  - `status`
  - `paymentMethod`, `paymentProvider`, `paymentStatus`
  - `paymentAction`, `paymentRedirectUrl`
- 주요 케이스:
  - `status=CONFIRMED` + `paymentStatus=SUCCESS` + `paymentAction=NONE`
  - `status=PAYING` + `paymentStatus=PENDING` + `paymentAction=WAIT_WEBHOOK`
  - `status=PAYING` + `paymentStatus=PENDING` + `paymentAction=REDIRECT` (provider=pg-ready + externalLiveEnabled=true)
  - `paymentStatus=FAILED` + `paymentAction=RETRY_CONFIRM`

### Provider behavior
- `provider=pg-ready`
  - 지원 수단: `CARD`, `KAKAOPAY`, `NAVERPAY`, `BANK_TRANSFER`
  - `WALLET`은 비지원/비활성
  - confirm 시 거래는 우선 `PENDING`, webhook 승인 후 `SUCCESS` 처리
- `provider=wallet`
  - 지원 수단: `WALLET` only
  - 잔액 부족 시 `IllegalStateException("Insufficient wallet balance.")`
  - 글로벌 핸들러에서 `409 CONFLICT`

## Realtime Contract (WS/SSE)
- STOMP endpoint
  - handshake: `/ws`
  - topic prefix: `/topic/**`
- WS registration API (auth required)
  - queue: `POST|DELETE /api/push/websocket/waiting-queue/subscriptions`
  - reservation: `POST|DELETE /api/push/websocket/reservations/subscriptions`
  - seat-map: `POST|DELETE /api/push/websocket/seats/subscriptions`
- WS destinations
  - queue: `/topic/waiting-queue/{concertId}/{userId}`
  - reservation: `/topic/reservations/{seatId}/{userId}`
  - seat-map: `/topic/seats/{optionId}`
- Push mode switch
  - `app.push.mode=websocket`이면 Kafka fanout + WS dispatch 경로 사용
  - `app.push.mode=sse`이면 SSE notifier 경로 사용
- SSE 범위
  - queue/reservation 이벤트 중심
  - seat-map은 인터페이스상 optional이라 SSE만으로는 실시간 좌석맵 보장이 약함

## Runtime/Profile Contract
- Payment defaults (`application*.yml`)
  - `app.payment.provider=${APP_PAYMENT_PROVIDER:pg-ready}`
  - `app.payment.external-live-enabled=${APP_PAYMENT_EXTERNAL_LIVE_ENABLED:false}`
- OAuth/callback
  - provider redirect URI는 백엔드 callback (`/login/oauth2/code/{provider}`)를 향해야 함
  - 프론트 callback path는 백엔드 `U1_CALLBACK_URL`과 정합 필요
- Ports/profiles (운영 체크)
  - LB 경유: `127.0.0.1:18080`
  - direct backend: `127.0.0.1:8080`

## Drift & Risks
- `GET /api/concerts/search` 반환 필드 드리프트
  - 프론트는 `saleStatus`, `reservationButton*`, `availableSeatCount` 등을 기대하는 구현이 존재
  - 백엔드 현재 `ConcertResponse` DTO에는 해당 필드가 명시되지 않음
  - 결론: 해당 필드 의존 UX는 계약 보강 또는 프론트 계산 로직 보완이 필요
- 런타임 리스크
  - 현 환경에서 `GET /api/concerts/search` 500(SQL `lower(bytea)`) 관측
- 보안 리스크
  - `SecurityConfig`에 `/api/users/**` permitAll 설정이 있어 wallet 조회/충전 보안 경계 재검토 필요

## Frontend Guardrails
- 금지
  - 결제수단 하드코딩 활성화/비활성 처리
  - `confirm` 결과 무시 후 성공 고정 처리
  - 카드 클릭 즉시 hold/paying/confirm 자동 실행(좌석/결제 선택 생략)
- 필수
  - 결제수단은 `GET /api/payments/methods` 기준으로만 노출/활성
  - 좌석 선택 UX는 `soft-lock -> hold -> paying -> confirm` 단계를 명시
  - `paymentAction` 기반 후속 처리(`REDIRECT/WAIT_WEBHOOK/RETRY_CONFIRM`) 분기
