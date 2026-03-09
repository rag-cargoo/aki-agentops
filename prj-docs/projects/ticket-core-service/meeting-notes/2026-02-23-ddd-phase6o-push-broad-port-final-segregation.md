# Meeting Notes: DDD Phase6-O Push Broad Port Final Segregation (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 22:13:00`
> - **Updated At**: `2026-02-23 22:13:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase6-O)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - `RealtimePushPort` broad contract 의존은 다수 컴포넌트에서 capability 포트로 축소됐지만 일부 경계에 잔여가 있었다.
  - 특히 `ReservationLifecycleServiceImpl`은 복수 capability를 사용하면서도 broad 계약에 직접 의존했고,
    `WebSocketEventDispatchPort`/`SsePushPort`는 인터페이스 상속 구조로 broad 계약이 전파되고 있었다.

## 안건 2: 이번 범위(Phase6-O)
- Status: DONE
- 범위:
  - `ReservationLifecycleServiceImpl` 의존 축소:
    - `RealtimePushPort` -> `QueueRuntimePushPort`, `ReservationStatusPushPort`, `SeatMapPushPort`
  - 인터페이스 경계 정리:
    - `SsePushPort`에서 `RealtimePushPort` 상속 제거(구독 + queue 알림 메서드만 명시)
    - `WebSocketEventDispatchPort`에서 `RealtimePushPort` 상속 제거
    - `WebSocketEventDispatchPort extends ReservationStatusPushPort, SeatMapPushPort`로 축소
  - ArchUnit guardrail 추가:
    - `reservation_lifecycle_service_should_not_depend_on_realtime_push_port_broad_contract`
    - `kafka_push_event_consumer_should_not_depend_on_realtime_push_port_broad_contract`
- 목표:
  - broad 포트의 간접 전파까지 차단해 capability 중심 포트 경계(DDD/Hexagonal)를 최종 고정

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - push mode 선택 정책(`PushNotifierConfig`) 변경 없음
  - `RealtimePushPort` 제거 작업은 미수행(런타임 선택용 통합 계약으로 유지)
  - API endpoint/응답 스키마 변경 없음

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.global.sse.SsePushNotifierTest' --tests 'com.ticketrush.global.push.WebSocketPushNotifierTest' --tests 'com.ticketrush.global.push.KafkaWebSocketPushNotifierTest' --tests 'com.ticketrush.infrastructure.messaging.KafkaPushEventConsumerTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest' --tests 'com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest' --tests 'com.ticketrush.api.controller.WebSocketPushControllerTest'`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.api.controller.AuthSecurityIntegrationTest' --tests 'com.ticketrush.api.controller.WebSocketPushControllerTest' --tests 'com.ticketrush.global.sse.SsePushNotifierTest' --tests 'com.ticketrush.global.push.WebSocketPushNotifierTest' --tests 'com.ticketrush.global.push.KafkaWebSocketPushNotifierTest' --tests 'com.ticketrush.infrastructure.messaging.KafkaPushEventConsumerTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest' --tests 'com.ticketrush.application.waitingqueue.service.WaitingQueueServiceImplTest' --tests 'com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest' --tests 'com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.application.auth.service.AuthSessionServiceTest'`
- 결과:
  - compile/test PASS
  - `ReservationLifecycleServiceImpl -> RealtimePushPort` 직접 의존 잔여 `0`건
  - `KafkaPushEventConsumer`가 broad 계약 상속 체인 없이 dispatch capability 포트에만 의존

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` 하위 Phase6-O로 누적 반영
