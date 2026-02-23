# Meeting Notes: DDD Phase8-A Inbound Port Application-Service Decoupling (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 23:59:50`
> - **Updated At**: `2026-02-23 23:59:50`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase8-A)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase7-C에서 API controller의 outbound 포트 직접 의존은 제거됐지만,
    일부 controller는 여전히 `application.*.service` 구현 계약에 직접 의존했다.
  - 헥사고날 관점에서 adapter(controller)는 inbound contract(usecase/port)를 기준으로 바라보는 것이 더 명시적이다.

## 안건 2: 이번 범위(Phase8-A)
- Status: DONE
- 범위:
  - inbound 포트 추가:
    - `application.realtime.port.inbound.RealtimeSubscriptionUseCase`
    - `application.waitingqueue.port.inbound.WaitingQueueUseCase`
    - `application.reservation.port.inbound.ReservationQueueOrchestrationUseCase`
  - service 인터페이스 정렬:
    - `RealtimeSubscriptionService extends RealtimeSubscriptionUseCase`
    - `WaitingQueueService extends WaitingQueueUseCase`
    - `ReservationQueueService extends ReservationQueueOrchestrationUseCase`
  - controller 의존 전환:
    - `ReservationController` -> `RealtimeSubscriptionUseCase`, `ReservationQueueOrchestrationUseCase`
    - `WaitingQueueController` -> `WaitingQueueUseCase`, `RealtimeSubscriptionUseCase`
    - `WebSocketPushController` -> `RealtimeSubscriptionUseCase`
  - ArchUnit 규칙 강화:
    - `reservation_controller_should_not_depend_on_reservation_queue_service_directly`
    - `waiting_queue_controller_should_not_depend_on_waiting_queue_service_directly`
    - `realtime_controllers_should_not_depend_on_realtime_subscription_service_directly`
- 목표:
  - API adapter가 application implementation(service) 대신 inbound contract(port)에 의존하도록 경계를 강화

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - 도메인 모델/상태머신 변경 없음
  - queue/push transport 구현 로직(SSE/WS/Kafka) 변경 없음
  - API endpoint/응답 스키마 변경 없음

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.api.controller.WebSocketPushControllerTest' --tests 'com.ticketrush.application.realtime.service.RealtimeSubscriptionServiceImplTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.global.sse.SsePushNotifierTest' --tests 'com.ticketrush.global.push.WebSocketPushNotifierTest' --tests 'com.ticketrush.global.push.KafkaWebSocketPushNotifierTest' --tests 'com.ticketrush.infrastructure.messaging.KafkaPushEventConsumerTest' --tests 'com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest' --tests 'com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest'`
- 결과:
  - compile/test PASS
  - 대상 controller의 service 직접 의존 잔여 `0` 확인

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` Phase8-A 반영
