# Meeting Notes: DDD Phase6-L Queue EventName Enum Hardening (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 21:45:00`
> - **Updated At**: `2026-02-23 21:45:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase6-L)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase6-J까지 queue payload는 typed model로 고정됐지만, queue event name은 문자열(`String`)로 전달되고 있었다.
  - queue event 식별자가 문자열로 남아있으면 오타/회귀가 컴파일 타임에 차단되지 않는다.

## 안건 2: 이번 범위(Phase6-L)
- Status: DONE
- 범위:
  - queue event name enum 도입:
    - `application.port.outbound.QueueEventName`
  - 포트/모델 타입 강화:
    - `WebSocketEventDispatchPort#publishQueueEvent(..., QueueEventName, QueuePushPayload)`
    - `PushEvent.eventName: String -> QueueEventName`
    - `KafkaPushEvent.eventName: String -> QueueEventName`
  - 구현체 정렬:
    - `WebSocketPushNotifier`
    - `KafkaWebSocketPushNotifier`
  - consumer/test 정렬:
    - `KafkaPushEventConsumer`
    - `KafkaPushEventConsumerTest`
    - `KafkaWebSocketPushNotifierTest`
- 목표:
  - queue 이벤트 이름 계약을 문자열에서 enum으로 고정해 이벤트 식별자 회귀를 컴파일 단계에서 차단

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - SSE event constants(`SseEventNames`) 구조 자체는 유지
  - reservation/seat-map 이벤트 타입 변경 없음
  - Kafka topic/group/runtime 설정 변경 없음

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.global.push.KafkaWebSocketPushNotifierTest' --tests 'com.ticketrush.global.push.WebSocketPushNotifierTest' --tests 'com.ticketrush.infrastructure.messaging.KafkaPushEventConsumerTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.global.sse.SsePushNotifierTest'`
- 결과:
  - compile/test PASS
  - queue event name string 의존 잔여 `0`건

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` 하위 Phase6-L로 누적 반영
