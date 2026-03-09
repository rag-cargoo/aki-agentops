# Meeting Notes: DDD Phase6-I Queue Payload Typed Port Hardening (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 21:05:00`
> - **Updated At**: `2026-02-23 21:05:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase6-I)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase6-H 이후 push runtime 계약은 `RealtimePushPort`로 단일화됐지만, queue payload는 `Object`로 남아 타입 안정성이 낮았다.
  - 동일 payload 필드(`userId`, `concertId`, `status`, `rank`, `activeTtlSeconds`, `timestamp`)가 scheduler/controller/service에서 반복 생성되고 있었다.

## 안건 2: 이번 범위(Phase6-I)
- Status: DONE
- 범위:
  - `RealtimePushPort` queue 전송 시그니처 타입 강화:
    - `sendQueueRankUpdate(Long, Long, QueuePushPayload)`
    - `sendQueueActivated(Long, Long, QueuePushPayload)`
  - application 모델 추가:
    - `application.port.outbound.QueuePushPayload`
  - 호출부 정렬:
    - `WaitingQueueScheduler`
    - `WaitingQueueController`
    - `ReservationLifecycleServiceImpl`
  - 구현체 정렬:
    - `SsePushNotifier`
    - `WebSocketPushNotifier`
    - `KafkaWebSocketPushNotifier`
  - 불필요 API DTO 제거:
    - `api.dto.waitingqueue.WaitingQueueSsePayload` 삭제
  - 테스트 정렬:
    - `WebSocketPushNotifierTest`
    - `KafkaWebSocketPushNotifierTest`
    - `WaitingQueueSchedulerTest`
    - `ReservationLifecycleServiceIntegrationTest`(시그니처 영향 범위 회귀)
- 목표:
  - queue 실시간 이벤트 payload를 포트 레벨에서 타입 고정해 런타임 경계의 계약 명시성을 강화

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - SSE/WebSocket 이벤트 이름 및 외부 노출 JSON 필드 스키마 변경 없음
  - Kafka topic/key 전략 변경 없음
  - waiting queue 활성화 정책(배치 크기, heartbeat 주기) 변경 없음

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.global.push.WebSocketPushNotifierTest' --tests 'com.ticketrush.global.push.KafkaWebSocketPushNotifierTest' --tests 'com.ticketrush.global.sse.SsePushNotifierTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest'`
- 결과:
  - compile/test PASS
  - queue push 시그니처의 `Object` 의존 잔여 `0`건
  - `WaitingQueueSsePayload` 참조 잔여 `0`건

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` 하위 Phase6-I로 누적 반영
