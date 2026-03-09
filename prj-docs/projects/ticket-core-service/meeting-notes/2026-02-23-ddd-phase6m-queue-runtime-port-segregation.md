# Meeting Notes: DDD Phase6-M Queue Runtime Port Segregation (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 21:52:00`
> - **Updated At**: `2026-02-23 21:52:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase6-M)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - `WaitingQueueScheduler`가 `RealtimePushPort` 전체 계약에 의존하고 있었다.
  - scheduler 책임은 queue runtime 이벤트에 한정되므로 포트 세분화가 필요했다.

## 안건 2: 이번 범위(Phase6-M)
- Status: DONE
- 범위:
  - queue runtime 전용 포트 도입:
    - `application.port.outbound.QueueRuntimePushPort`
  - 포트 계층 정렬:
    - `RealtimePushPort extends QueueRuntimePushPort`
  - scheduler 의존 축소:
    - `WaitingQueueScheduler` 의존 타입
      - `RealtimePushPort` -> `QueueRuntimePushPort`
    - `WaitingQueueSchedulerTest` mock 타입 동일 전환
  - ArchUnit guardrail 추가:
    - `waiting_queue_scheduler_should_not_depend_on_realtime_push_port_broad_contract`
- 목표:
  - queue scheduler가 broad push contract 대신 queue runtime 전용 포트만 의존하도록 경계 명확화

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - `ReservationLifecycleServiceImpl`, `SeatSoftLockServiceImpl`, `PgReadyWebhookService`의 `RealtimePushPort` 의존은 유지
  - push mode 선택 정책/런타임 설정 변경 없음
  - SSE/WebSocket/Kafka 외부 계약 변경 없음

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.global.push.KafkaWebSocketPushNotifierTest' --tests 'com.ticketrush.global.push.WebSocketPushNotifierTest' --tests 'com.ticketrush.infrastructure.messaging.KafkaPushEventConsumerTest' --tests 'com.ticketrush.global.sse.SsePushNotifierTest'`
- 결과:
  - compile/test PASS
  - `WaitingQueueScheduler -> RealtimePushPort` 직접 의존 잔여 `0`건

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` 하위 Phase6-M로 누적 반영
