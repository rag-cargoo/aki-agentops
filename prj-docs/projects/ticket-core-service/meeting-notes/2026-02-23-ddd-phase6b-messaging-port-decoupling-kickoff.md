# Meeting Notes: DDD Phase6-B Messaging Port Decoupling Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 19:20:11`
> - **Updated At**: `2026-02-23 19:20:11`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase6-B)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase6-A에서 Kafka 구현체를 `global.messaging`에서 `infrastructure.messaging`으로 이동했다.
  - 이후에도 `api/global` 계층에서 `infrastructure.messaging` 구현체를 직접 참조하는 경로가 남아 있었다.
    - `ReservationController` -> `KafkaReservationProducer`
    - `KafkaWebSocketPushNotifier` -> `KafkaPushEventProducer`, `KafkaPushEvent`
  - 이번 단계는 메시징 경계를 포트/모델 기준으로 정리해 직접 의존을 제거한다.

## 안건 2: 이번 범위(Phase6-B)
- Status: DONE
- 범위:
  - reservation enqueue 경계 정리:
    - `application.reservation.port.outbound.ReservationQueueEventPublisher` 추가
    - `ReservationController`가 outbound port 경유로 전환
    - `KafkaReservationProducer`가 port 구현(adapter) 역할 수행
  - push fanout 경계 정리:
    - `global.push.PushEvent`, `global.push.PushEventPublisher` 추가
    - `KafkaWebSocketPushNotifier`가 `infrastructure.messaging` 직접 타입 의존 없이 이벤트 발행
    - `KafkaPushEventProducer`가 `PushEventPublisher` 구현체로 동작
  - ArchUnit 규칙 보강:
    - `api_layer_should_not_depend_on_infrastructure_messaging`
    - `global_push_should_not_depend_on_infrastructure_messaging`
- 목표:
  - `api/global`은 포트/모델만 의존하고 Kafka 구현체는 `infrastructure`에 고정
- 구현 결과:
  - 변경 파일:
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/application/reservation/port/outbound/ReservationQueueEventPublisher.java`
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/global/push/PushEvent.java`
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/global/push/PushEventPublisher.java`
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/api/controller/ReservationController.java`
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/global/push/KafkaWebSocketPushNotifier.java`
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/infrastructure/messaging/KafkaReservationProducer.java`
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/infrastructure/messaging/KafkaPushEventProducer.java`
    - `workspace/apps/backend/ticket-core-service/src/test/java/com/ticketrush/architecture/LayerDependencyArchTest.java`
    - `workspace/apps/backend/ticket-core-service/src/test/java/com/ticketrush/global/push/KafkaWebSocketPushNotifierTest.java`

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - Kafka topic/group-id/partition 운영값 변경
  - push payload 외부 계약 변경(필드/이벤트명 자체 변경)
  - Redis/웹소켓 전송 경로(`WebSocketPushNotifier`) 구조 변경

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.infrastructure.messaging.KafkaPushEventConsumerTest' --tests 'com.ticketrush.global.push.KafkaWebSocketPushNotifierTest' --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest'`
- 결과:
  - compile/test 타깃 세트 PASS
  - `api/global -> infrastructure.messaging` 직접 import 잔여 `0`건 확인

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open, DDD 연속 트래킹)
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에 누적 관리
