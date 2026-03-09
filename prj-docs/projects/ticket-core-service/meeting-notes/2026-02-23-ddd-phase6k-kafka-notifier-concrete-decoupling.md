# Meeting Notes: DDD Phase6-K Kafka Notifier Concrete Decoupling (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 21:32:00`
> - **Updated At**: `2026-02-23 21:32:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase6-K)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - `KafkaWebSocketPushNotifier`가 `WebSocketPushNotifier` 구체 타입에 직접 의존하고 있었다.
  - queue payload 타입 고정(Phase6-I/J) 이후에도 notifier 구현체 간 구체 결합이 남아있어 교체 가능성과 테스트 격리가 제한됐다.

## 안건 2: 이번 범위(Phase6-K)
- Status: DONE
- 범위:
  - queue 구독 조회 포트 도입:
    - `application.port.outbound.QueueSubscriberQueryPort`
      - `getSubscribedQueueUsers(Long concertId)`
      - `snapshotQueueSubscribers()`
  - 구현체 정렬:
    - `WebSocketPushNotifier`가 `QueueSubscriberQueryPort` 구현
  - Kafka notifier 의존 전환:
    - `KafkaWebSocketPushNotifier` 의존 타입
      - `WebSocketPushNotifier` -> `QueueSubscriberQueryPort`
  - ArchUnit guardrail 추가:
    - `kafka_websocket_push_notifier_should_not_depend_on_websocket_push_notifier_concrete`
  - 테스트 정렬:
    - `KafkaWebSocketPushNotifierTest` mock 타입을 `QueueSubscriberQueryPort`로 전환
- 목표:
  - Kafka notifier의 구체 구현체 결합을 제거하고 포트 경계 기반으로 정렬

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - push mode 선택 정책 변경 없음
  - queue 이벤트 payload 스키마 변경 없음
  - SSE/WebSocket 외부 API 엔드포인트 변경 없음

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.global.push.KafkaWebSocketPushNotifierTest' --tests 'com.ticketrush.global.push.WebSocketPushNotifierTest' --tests 'com.ticketrush.infrastructure.messaging.KafkaPushEventConsumerTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest'`
- 결과:
  - compile/test PASS
  - `KafkaWebSocketPushNotifier -> WebSocketPushNotifier` 구체 의존 잔여 `0`건

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` 하위 Phase6-K로 누적 반영
