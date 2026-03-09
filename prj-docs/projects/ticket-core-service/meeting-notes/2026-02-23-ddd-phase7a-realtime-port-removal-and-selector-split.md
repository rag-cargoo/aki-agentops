# Meeting Notes: DDD Phase7-A Realtime Port Removal and Selector Split (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 22:28:00`
> - **Updated At**: `2026-02-23 22:28:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase7-A)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase6-O까지 broad push 계약 의존을 capability 포트로 축소했지만, `RealtimePushPort` 자체는 통합 인터페이스로 잔존했다.
  - 런타임 모드 선택(`SSE/WEBSOCKET`)은 `PushNotifierConfig`의 단일 broad 타입 선택으로 유지되어 capability별 주입 경계가 명시적이지 않았다.

## 안건 2: 이번 범위(Phase7-A)
- Status: DONE
- 범위:
  - broad 계약 제거:
    - `application.port.outbound.RealtimePushPort` 삭제
  - 구현체 인터페이스 정렬:
    - `SsePushNotifier implements QueueRuntimePushPort, ReservationStatusPushPort, SeatMapPushPort, SsePushPort`
    - `KafkaWebSocketPushNotifier implements QueueRuntimePushPort, ReservationStatusPushPort, SeatMapPushPort`
    - `WebSocketPushNotifier implements QueueRuntimePushPort, WebSocketEventDispatchPort, WebSocketSubscriptionPort, QueueSubscriberQueryPort`
  - mode selector 분리:
    - `PushNotifierConfig`를 capability별 primary selector로 분리
      - `queueRuntimePushNotifier`
      - `reservationStatusPushNotifier`
      - `seatMapPushNotifier`
  - 테스트/가드레일 정렬:
    - `PushNotifierConfigTest`를 capability selector 기준으로 갱신
    - `ReservationLifecycleServiceIntegrationTest` mock 주입을 capability 포트 기준으로 분리
    - `LayerDependencyArchTest`의 broad 계약 금지 규칙을 transport-specific 포트 의존 금지 규칙으로 정렬
- 목표:
  - push 경계에서 통합 포트 없이 capability 포트만 남겨 DDD/Hexagonal 의존성을 명시적으로 고정

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - WebSocket subscription API 계약 변경 없음
  - Kafka topic/event payload 스키마 변경 없음
  - push mode 정책(`app.push.mode`) 변경 없음

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.global.config.PushNotifierConfigTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.global.sse.SsePushNotifierTest' --tests 'com.ticketrush.global.push.WebSocketPushNotifierTest' --tests 'com.ticketrush.global.push.KafkaWebSocketPushNotifierTest' --tests 'com.ticketrush.infrastructure.messaging.KafkaPushEventConsumerTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest' --tests 'com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest' --tests 'com.ticketrush.api.controller.WebSocketPushControllerTest'`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.global.config.PushNotifierConfigTest' --tests 'com.ticketrush.api.controller.AuthSecurityIntegrationTest' --tests 'com.ticketrush.api.controller.WebSocketPushControllerTest' --tests 'com.ticketrush.global.sse.SsePushNotifierTest' --tests 'com.ticketrush.global.push.WebSocketPushNotifierTest' --tests 'com.ticketrush.global.push.KafkaWebSocketPushNotifierTest' --tests 'com.ticketrush.infrastructure.messaging.KafkaPushEventConsumerTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest' --tests 'com.ticketrush.application.waitingqueue.service.WaitingQueueServiceImplTest' --tests 'com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest' --tests 'com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.application.auth.service.AuthSessionServiceTest'`
- 결과:
  - compile/test PASS
  - `src/**` 기준 `RealtimePushPort` 참조 잔여 `0`건

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` 하위 Phase7-A로 누적 반영
