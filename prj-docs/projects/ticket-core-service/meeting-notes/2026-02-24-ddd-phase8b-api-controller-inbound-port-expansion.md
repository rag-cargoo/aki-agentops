# Meeting Notes: DDD Phase8-B API Controller Inbound Port Expansion (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-24 00:37:30`
> - **Updated At**: `2026-02-24 00:37:30`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase8-B)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase8-A에서 realtime/queue 계열 controller 경계는 inbound port로 고정했지만,
    auth/user/catalog/concert/reservation/webhook controller에는 `application..service` 의존이 남아 있었다.
  - 헥사고날 원칙상 adapter(controller)는 구현체(service package)가 아니라 inbound contract(use case)에 의존해야 한다.

## 안건 2: 이번 범위(Phase8-B)
- Status: DONE
- 범위:
  - inbound 포트 추가:
    - `application.auth.port.inbound.AuthSessionUseCase`
    - `application.auth.port.inbound.SocialAuthUseCase`
    - `application.user.port.inbound.UserUseCase`
    - `application.payment.port.inbound.PaymentUseCase`
    - `application.catalog.port.inbound.{EntertainmentUseCase,ArtistUseCase,PromoterUseCase,VenueUseCase}`
    - `application.concert.port.inbound.ConcertUseCase`
    - `application.reservation.port.inbound.{ReservationUseCase,ReservationLifecycleUseCase,SalesPolicyUseCase,SeatSoftLockUseCase,AbuseAuditUseCase,AdminRefundAuditUseCase}`
    - `application.payment.webhook.port.inbound.PgReadyWebhookUseCase`
  - service 인터페이스 정렬:
    - 기존 `application..service` 인터페이스는 inbound port를 상속하는 adapter 계약으로 축소
  - controller 의존 전환:
    - `AuthController`, `SocialAuthController`, `UserController`, `WalletController`
    - `EntertainmentController`, `EntertainmentCatalogController`, `ArtistController`, `PromoterController`, `VenueController`
    - `ConcertController`, `AdminConcertController`
    - `ReservationController`, `PaymentWebhookController`
  - DTO 경계 정렬:
    - `SeatSoftLockAcquireResponse`, `SeatSoftLockReleaseResponse`가 service nested type 대신 inbound port nested type 사용
  - ArchUnit 규칙 강화:
    - `rest_controllers_should_not_depend_on_application_service_package_directly`
    - `payment_webhook_controller_should_not_depend_on_pg_ready_webhook_service_directly`
- 목표:
  - API adapter가 application service 구현 패키지 의존 없이 inbound port contract 중심으로 고정되도록 강화

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - 도메인 엔티티/상태머신/비즈니스 규칙 변경 없음
  - API endpoint 경로/HTTP 스키마 변경 없음
  - Redis/Kafka 런타임 설정 변경 없음

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests com.ticketrush.architecture.LayerDependencyArchTest --tests com.ticketrush.api.controller.AuthSecurityIntegrationTest --tests com.ticketrush.api.controller.SocialAuthControllerIntegrationTest --tests com.ticketrush.api.controller.WebSocketPushControllerTest --tests com.ticketrush.application.realtime.service.RealtimeSubscriptionServiceImplTest --tests com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest --tests com.ticketrush.application.user.service.UserServiceImplDataJpaTest --tests com.ticketrush.application.payment.service.PaymentServiceIntegrationTest --tests com.ticketrush.application.catalog.service.EntertainmentArtistCrudDataJpaTest --tests com.ticketrush.application.concert.service.ConcertExplorerIntegrationTest --tests com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest --tests com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest --tests com.ticketrush.application.auth.service.AuthSessionServiceTest --tests com.ticketrush.application.auth.service.SocialAuthServiceTest`
  - `./gradlew test --no-daemon --tests com.ticketrush.architecture.LayerDependencyArchTest --tests com.ticketrush.api.controller.AuthSecurityIntegrationTest --tests com.ticketrush.api.controller.SocialAuthControllerIntegrationTest --tests com.ticketrush.api.controller.WebSocketPushControllerTest --tests com.ticketrush.application.realtime.service.RealtimeSubscriptionServiceImplTest --tests com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest --tests com.ticketrush.application.user.service.UserServiceImplDataJpaTest --tests com.ticketrush.application.payment.service.PaymentServiceIntegrationTest --tests com.ticketrush.application.catalog.service.EntertainmentArtistCrudDataJpaTest --tests com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest --tests com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest --tests com.ticketrush.application.auth.service.AuthSessionServiceTest --tests com.ticketrush.application.auth.service.SocialAuthServiceTest`
- 결과:
  - compile PASS
  - 첫 번째 통합 테스트 세트는 `ConcertExplorerIntegrationTest` 3건이 Redis 연결 타임아웃으로 FAIL(환경 의존)
  - Redis 비의존 핵심 세트 재실행 PASS
  - `rg -n "com\\.ticketrush\\.application\\..*\\.service" src/main/java/com/ticketrush/api` 결과 0건 확인

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` Phase8-B 반영
