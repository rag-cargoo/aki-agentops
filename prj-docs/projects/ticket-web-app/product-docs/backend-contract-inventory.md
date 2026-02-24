# Backend Contract Inventory (ticket-web-app)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-25 01:15:00`
> - **Updated At**: `2026-02-25 01:15:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Domain Map
> - Endpoint Boundary
> - State Machines
> - Runtime/Profile Contract
> - Drift Notes
<!-- DOC_TOC_END -->

## Scope
- 목적: `ticket-web-app` 프론트 구현의 기준 계약을 백엔드 코드와 실응답 기준으로 고정한다.
- 기준 소스:
  - 백엔드 코드: `workspace/apps/backend/ticket-core-service/src/main/java/**`
  - 백엔드 설정: `workspace/apps/backend/ticket-core-service/src/main/resources/application*.yml`
  - 공식 API 문서: `prj-docs/projects/ticket-core-service/product-docs/api-specs/**`
  - 실응답 샘플: `http://127.0.0.1:18080/api/concerts/search`

## Domain Map
- Auth Session
  - `SocialAuthController`, `AuthController`, `SocialAuthCallbackRedirectController`
  - 소셜 코드 교환 후 JWT access/refresh 발급, `auth/me`, `auth/logout` 제공
- Catalog / Concert
  - `ConcertController`, `AdminConcertController`
  - 공연/회차/좌석 조회 + 관리자 CRUD + 썸네일 + 판매정책
- Reservation Lifecycle
  - `ReservationController(v6/v7)`, `ReservationLifecycleServiceImpl`, `SeatSoftLockServiceImpl`
  - 상태전이: HOLD -> PAYING -> CONFIRMED -> CANCELLED -> REFUNDED
- Sales Policy
  - `SalesPolicyServiceImpl`, `SalesPolicy`
  - 핵심 정책 필드: `maxReservationsPerUser`, `generalSaleStartAt`, `presale*`
- Payment / Wallet
  - `WalletController`, `PaymentServiceImpl`, `PaymentGateway` 구현체
  - provider: `wallet`(기본), `mock`, `pg-ready`
- Waiting Queue / Realtime
  - `WaitingQueueController`, `WebSocketPushController`, `RealtimeSubscriptionServiceImpl`
  - 대기열 진입/상태/SSE + WS 구독 등록 API 제공

## Endpoint Boundary
- 공개(비인증)
  - `GET /api/concerts/**`
  - `POST /api/auth/social/{provider}/exchange`
  - `GET /api/auth/social/{provider}/authorize-url`
  - `POST /api/auth/token/refresh`
  - `GET|POST /api/v1/waiting-queue/**`
- 인증 필요
  - `/api/auth/me`, `/api/auth/logout`
  - `/api/reservations/v7/**` (단, `/v7/audit/abuse`는 ADMIN)
  - `/api/push/websocket/**`
- 관리자
  - `/api/admin/**`
  - `POST /api/reservations/v7/admin/{reservationId}/refund`
  - `GET /api/reservations/v7/audit/admin-refunds`

## State Machines
- Reservation status
  - `PENDING`, `HOLD`, `PAYING`, `CONFIRMED`, `EXPIRED`, `CANCELLED`, `REFUNDED`
- Seat status
  - `AVAILABLE`, `TEMP_RESERVED`, `RESERVED`
- Hold/Pay timeout
  - `app.reservation.hold-ttl-seconds` (기본 300초)
- 환불 마감
  - `app.reservation.refund-cutoff-hours-before-concert` (기본 공연 24시간 전)
- 정책 기반 제한
  - `maxReservationsPerUser`는 콘서트 단위로 `HOLD/PAYING/CONFIRMED` 상태 개수를 제한
- 결제 실패 핵심 케이스
  - `409 CONFLICT` + `Insufficient wallet balance.`

## Runtime/Profile Contract
- 백엔드 결제 기본값
  - `app.payment.provider=wallet`
  - `app.payment.default-ticket-price-amount=100000`
- 프론트 프로파일(개발)
  - LB 모드: `127.0.0.1:18080`
  - Direct 모드: `127.0.0.1:8080`
- OAuth redirect 운영 원칙
  - OAuth 공급자 redirect URI는 백엔드 callback(`/login/oauth2/code/{provider}`)를 가리킨다.
  - 프론트 callback(`VITE_OAUTH_CALLBACK_PATH`)은 백엔드 `U1_CALLBACK_URL`과 일치해야 한다.

## Drift Notes
- 코드/문서와 실응답 간 드리프트가 일부 존재한다.
  - 실응답(`18080`)에서 `/api/concerts/search`는 `agencyName/agencyCountryCode/agencyHomepageUrl` 키를 반환하는 케이스가 있다.
  - 프론트는 `entertainment*`와 `agency*`를 모두 파싱해야 한다.
- Direct 모드(`8080`)는 현재 미기동일 수 있으므로 프로파일 전환 시 서버 헬스체크가 필요하다.
