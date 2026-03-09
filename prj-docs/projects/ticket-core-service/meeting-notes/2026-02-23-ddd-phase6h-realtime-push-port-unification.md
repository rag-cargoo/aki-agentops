# Meeting Notes: DDD Phase6-H Realtime Push Port Unification (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 20:56:00`
> - **Updated At**: `2026-02-23 20:56:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase6-H)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase6-G 이후에도 `global.push.PushNotifier`가 런타임 타입 축으로 남아 있었다.
  - application 포트(`RealtimePushPort`)와 global 인터페이스가 중복 역할을 수행하고 있어 경계 표현이 분산되어 있었다.

## 안건 2: 이번 범위(Phase6-H)
- Status: DONE
- 범위:
  - `global.push.PushNotifier` 제거
  - `RealtimePushPort`에 queue heartbeat/subscriber 조회 기본 계약을 통합
    - `sendQueueHeartbeat()`
    - `getSubscribedQueueUsers(Long concertId)`
  - 구현/설정 전환:
    - `PushNotifierConfig` 반환 타입을 `RealtimePushPort`로 통합
    - `WaitingQueueScheduler` 의존 타입을 `RealtimePushPort`로 전환
    - `SsePushNotifier`, `KafkaWebSocketPushNotifier`, `WebSocketPushNotifier` 구현 타입 정렬
  - 테스트 정렬:
    - `PushNotifierConfigTest`
    - `WaitingQueueSchedulerTest`
    - `PgReadyWebhookServiceTest`
    - `SeatSoftLockServiceImplTest`
    - `ReservationLifecycleServiceIntegrationTest`
- 목표:
  - push runtime 계약을 application outbound port로 단일화해 global 전용 인터페이스 중복 제거

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - push mode 선택 정책 변경 없음(`sse` vs `websocket`)
  - SSE/WebSocket payload/schema 변경 없음
  - Kafka topic 구성 변경 없음

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.global.config.PushNotifierConfigTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest' --tests 'com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest'`
- 결과:
  - compile/test PASS
  - `PushNotifier` 타입 참조(main/test) 잔여 `0`건

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` 하위 Phase6-H로 누적 반영

