# Meeting Notes: DDD Phase8-C Runtime Adapter Inbound-Port Decoupling (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-24 00:49:00`
> - **Updated At**: `2026-02-24 00:49:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase8-C)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase8-B 이후 API adapter는 inbound port 의존으로 정렬됐지만,
    일부 runtime adapter(global/infrastructure)는 여전히 `application..service`에 직접 의존했다.
  - 헥사고날 원칙상 scheduler/consumer/gateway/adapter도 구현 패키지가 아니라 use case contract를 바라봐야 한다.

## 안건 2: 이번 범위(Phase8-C)
- Status: DONE
- 범위:
  - runtime용 inbound 포트 추가:
    - `application.waitingqueue.port.inbound.WaitingQueueRuntimeUseCase`
    - `application.reservation.port.inbound.ReservationQueueRuntimeUseCase`
  - service 인터페이스 정렬:
    - `WaitingQueueService extends WaitingQueueRuntimeUseCase`
    - `ReservationQueueService extends ReservationQueueRuntimeUseCase`
  - runtime adapter 의존 전환:
    - `global.scheduler.WaitingQueueScheduler` -> `WaitingQueueRuntimeUseCase`
    - `global.scheduler.ReservationLifecycleScheduler` -> `ReservationLifecycleUseCase`
    - `global.lock.RedissonLockFacade` -> `ReservationUseCase`
    - `infrastructure.messaging.KafkaReservationConsumer` -> `ReservationUseCase`, `ReservationQueueRuntimeUseCase`
    - `infrastructure.payment.gateway.WalletPaymentGateway` -> `PaymentUseCase`
    - `infrastructure.reservation.adapter.outbound.ReservationWaitingQueuePortAdapter` -> `WaitingQueueRuntimeUseCase`
  - ArchUnit 규칙 강화:
    - `waiting_queue_scheduler_should_not_depend_on_waiting_queue_service_directly`
    - `reservation_lifecycle_scheduler_should_not_depend_on_reservation_lifecycle_service_directly`
    - `redisson_lock_facade_should_not_depend_on_reservation_service_directly`
    - `wallet_payment_gateway_should_not_depend_on_payment_service_directly`
    - `reservation_waiting_queue_adapter_should_not_depend_on_waiting_queue_service_directly`
    - `kafka_reservation_consumer_should_not_depend_on_reservation_services_directly`
- 목표:
  - API뿐 아니라 runtime adapter까지 `adapter -> inbound port(use case)` 경계를 일관 적용

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - JWT 인증필터(`JwtAuthenticationFilter`)의 `JwtTokenProvider` 의존은 기술적 인증 경계로 유지
  - 비즈니스 로직/상태머신 변경 없음
  - endpoint/메시지 스키마 변경 없음

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests com.ticketrush.architecture.LayerDependencyArchTest --tests com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest --tests com.ticketrush.global.scheduler.WaitingQueueSchedulerTest --tests com.ticketrush.application.realtime.service.RealtimeSubscriptionServiceImplTest --tests com.ticketrush.api.controller.WebSocketPushControllerTest --tests com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest --tests com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest --tests com.ticketrush.application.auth.service.AuthSessionServiceTest --tests com.ticketrush.application.auth.service.SocialAuthServiceTest --tests com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest --tests com.ticketrush.application.payment.service.PaymentServiceIntegrationTest`
  - `rg -n "com\\.ticketrush\\.application\\..*\\.service" src/main/java/com/ticketrush/global src/main/java/com/ticketrush/infrastructure`
- 결과:
  - compile/test PASS
  - global/infrastructure의 service 직접 의존은 `JwtAuthenticationFilter -> JwtTokenProvider` 1건만 잔여(의도된 기술 경계)

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` Phase8-C 반영
