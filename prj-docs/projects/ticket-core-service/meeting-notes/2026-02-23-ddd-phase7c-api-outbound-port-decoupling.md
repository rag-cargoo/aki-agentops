# Meeting Notes: DDD Phase7-C API Outbound Port Decoupling (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 23:58:00`
> - **Updated At**: `2026-02-23 23:58:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase7-C)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase7-B까지 queue/push 운영 관측성은 고정되었지만, 일부 API controller가 outbound 포트를 직접 참조하고 있었다.
  - 헥사고날 경계 기준으로 API adapter는 application 경계를 통해 동작해야 하므로, controller의 outbound 직접 의존 제거가 필요했다.

## 안건 2: 이번 범위(Phase7-C)
- Status: DONE
- 범위:
  - application 실시간 구독 서비스 도입:
    - `application.realtime.service.RealtimeSubscriptionService`
    - `application.realtime.service.RealtimeSubscriptionServiceImpl`
  - controller 경계 정렬:
    - `ReservationController`:
      - `SsePushPort`, `ReservationQueueEventPublisher` 직접 의존 제거
      - `RealtimeSubscriptionService.subscribeReservationSse(...)` 사용
      - queue enqueue는 `ReservationQueueService.enqueue(...)`로 위임
    - `WaitingQueueController`:
      - subscribe bootstrap 로직을 `RealtimeSubscriptionService.subscribeWaitingQueueSse(...)`로 이동
    - `WebSocketPushController`:
      - `WebSocketSubscriptionPort` 직접 의존 제거
      - 모든 websocket 구독/해제를 `RealtimeSubscriptionService`로 위임
  - application 서비스 확장:
    - `ReservationQueueService.enqueue(userId, seatId, lockType)` 추가
    - `ReservationQueueServiceImpl`에서 `PENDING` 저장 + event publish 통합
  - ArchUnit 강화:
    - `api_layer_should_not_depend_on_application_outbound_ports`
- 목표:
  - API adapter가 outbound 포트를 직접 참조하지 않고 application 경계만 사용하도록 고정

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - queue/push 전송 구현체(SSE/WS/Kafka) 내부 동작 변경은 이번 범위에서 제외
  - API 스펙 경로/응답 필드 변경 없음
  - 외부 모니터링 백엔드 연동 범위 없음

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.global.config.PushNotifierConfigTest' --tests 'com.ticketrush.api.controller.AuthSecurityIntegrationTest' --tests 'com.ticketrush.api.controller.WebSocketPushControllerTest' --tests 'com.ticketrush.application.realtime.service.RealtimeSubscriptionServiceImplTest' --tests 'com.ticketrush.global.sse.SsePushNotifierTest' --tests 'com.ticketrush.global.push.WebSocketPushNotifierTest' --tests 'com.ticketrush.global.push.KafkaWebSocketPushNotifierTest' --tests 'com.ticketrush.infrastructure.messaging.KafkaPushEventConsumerTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest' --tests 'com.ticketrush.application.waitingqueue.service.WaitingQueueServiceImplTest' --tests 'com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest' --tests 'com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.application.auth.service.AuthSessionServiceTest'`
- 결과:
  - compile/test PASS
  - `src/main/java/com/ticketrush/api/**` 기준 `application.port.outbound` 직접 의존 잔여 `0`건 확인

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md` `TCS-SC-026`의 Phase7-C 블록 반영
