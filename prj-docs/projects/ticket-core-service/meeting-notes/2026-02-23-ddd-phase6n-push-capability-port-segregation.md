# Meeting Notes: DDD Phase6-N Push Capability Port Segregation (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 22:02:00`
> - **Updated At**: `2026-02-23 22:02:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase6-N)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - 일부 컴포넌트는 `RealtimePushPort`의 전체 기능이 아니라 단일 기능만 사용하고 있었다.
  - 예: `KafkaReservationConsumer`/`PgReadyWebhookService`는 reservation status 전송만, `SeatSoftLockServiceImpl`는 seat-map status 전송만 사용.

## 안건 2: 이번 범위(Phase6-N)
- Status: DONE
- 범위:
  - push capability 포트 분리:
    - `ReservationStatusPushPort`
    - `SeatMapPushPort`
  - 포트 계층 정렬:
    - `RealtimePushPort extends QueueRuntimePushPort, ReservationStatusPushPort, SeatMapPushPort`
  - 의존 축소:
    - `KafkaReservationConsumer`: `RealtimePushPort` -> `ReservationStatusPushPort`
    - `PgReadyWebhookService`: `RealtimePushPort` -> `ReservationStatusPushPort`
    - `SeatSoftLockServiceImpl`: `RealtimePushPort` -> `SeatMapPushPort`
  - 테스트 정렬:
    - `PgReadyWebhookServiceTest`
    - `SeatSoftLockServiceImplTest`
  - ArchUnit guardrail 추가:
    - `seat_soft_lock_service_should_not_depend_on_realtime_push_port_broad_contract`
    - `pg_ready_webhook_service_should_not_depend_on_realtime_push_port_broad_contract`
    - `kafka_reservation_consumer_should_not_depend_on_realtime_push_port_broad_contract`
- 목표:
  - broad contract 의존을 capability 단위로 축소해 컴포넌트 책임-의존 정합 강화

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - `ReservationLifecycleServiceImpl`의 복합 push 의존은 유지(좌석/예약/queue 모두 사용)
  - push mode 선택 정책/전송 채널(SSE/WebSocket/Kafka) 변경 없음
  - 외부 API 계약 변경 없음

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest' --tests 'com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest' --tests 'com.ticketrush.infrastructure.messaging.KafkaPushEventConsumerTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest'`
- 결과:
  - compile/test PASS
  - 대상 3개 컴포넌트의 `RealtimePushPort` 직접 의존 잔여 `0`건

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` 하위 Phase6-N로 누적 반영
