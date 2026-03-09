# Meeting Notes: DDD Phase6-J Queue Event Dispatch Typed Hardening (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 21:18:00`
> - **Updated At**: `2026-02-23 21:18:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase6-J)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase6-I에서 queue push 포트 시그니처는 typed payload(`QueuePushPayload`)로 정렬됐지만,
    Kafka bridge/dispatch 경계(`PushEvent`, `KafkaPushEvent`, `WebSocketEventDispatchPort`)에는 `Object`가 잔존했다.
  - queue 이벤트가 Kafka를 경유하는 경로에서 payload 계약의 컴파일 타임 보장이 필요했다.

## 안건 2: 이번 범위(Phase6-J)
- Status: DONE
- 범위:
  - dispatch 포트 타입 강화:
    - `WebSocketEventDispatchPort#publishQueueEvent(..., QueuePushPayload)`
  - Kafka bridge 이벤트 모델 타입 강화:
    - `PushEvent.data: Object -> QueuePushPayload`
    - `KafkaPushEvent.data: Object -> QueuePushPayload`
  - queue 이벤트 발행 구현 정렬:
    - `WebSocketPushNotifier`
    - `KafkaWebSocketPushNotifier`
  - heartbeat payload 정렬:
    - KEEPALIVE 전송 시 `QueuePushPayload` 기반으로 통일
  - consumer 테스트 정렬:
    - `KafkaPushEventConsumerTest`
- 목표:
  - queue 이벤트의 publish -> Kafka -> consume -> WebSocket dispatch 전체 경로를 typed payload 계약으로 고정

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - SSE 내부 전송 유틸(`send`/`sendAndComplete`)의 범용 `Object` 파라미터는 유지
  - reservation/seat-map 이벤트 모델 구조 변경 없음
  - Kafka topic/group 설정 변경 없음

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.infrastructure.messaging.KafkaPushEventConsumerTest' --tests 'com.ticketrush.global.push.KafkaWebSocketPushNotifierTest' --tests 'com.ticketrush.global.push.WebSocketPushNotifierTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.global.sse.SsePushNotifierTest'`
- 결과:
  - compile/test PASS
  - queue dispatch 경계의 `Object data` 잔여 `0`건

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` 하위 Phase6-J로 누적 반영
