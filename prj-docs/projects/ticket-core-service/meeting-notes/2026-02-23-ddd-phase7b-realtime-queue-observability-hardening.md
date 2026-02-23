# Meeting Notes: DDD Phase7-B Realtime Queue Observability Hardening (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 22:43:00`
> - **Updated At**: `2026-02-23 22:43:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase7-B)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase7-A로 push 경계는 capability 포트로 고정됐지만,
    운영 관점에서는 queue/push 구간의 로그 키/지표 규약이 분산돼 있었다.
  - 인증 구간은 `AUTH_MONITOR` 표준이 있었으나, 실시간 구간은 동일 수준의 표준이 부족했다.

## 안건 2: 이번 범위(Phase7-B)
- Status: DONE
- 범위:
  - push/queue 관측성 지표 수집 유틸 추가:
    - `global.monitoring.PushMonitoringMetrics`
  - 주기 스냅샷 로그 추가:
    - `global.monitoring.PushMonitoringSnapshotScheduler`
    - 로그 키: `PUSH_MONITOR_SNAPSHOT`
  - 런타임 이벤트 계측/로그 추가:
    - `SsePushNotifier`, `WebSocketPushNotifier`, `KafkaWebSocketPushNotifier`
      - 로그 키: `PUSH_MONITOR`
    - `WaitingQueueScheduler`
      - 로그 키: `QUEUE_MONITOR`
  - 설정 추가:
    - `app.push.monitor.snapshot-delay-millis`
    - env override: `APP_PUSH_MONITOR_SNAPSHOT_DELAY_MILLIS`
  - 문서 반영:
    - `product-docs/api-specs/realtime-ops-monitoring-guide.md`
    - API Specs/Pages Sidebar/Service README 링크 정렬
- 목표:
  - queue/push 운영 구간을 `표준 로그 키 + 주기 스냅샷`으로 관찰 가능하게 고정

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - 외부 메트릭 백엔드(Prometheus/Grafana) 연동은 이번 범위에서 제외
  - API 계약/엔드포인트 변경 없음
  - 인증 모니터링(`AUTH_MONITOR`) 규약 변경 없음

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.global.monitoring.PushMonitoringMetricsTest' --tests 'com.ticketrush.global.sse.SsePushNotifierTest' --tests 'com.ticketrush.global.push.WebSocketPushNotifierTest' --tests 'com.ticketrush.global.push.KafkaWebSocketPushNotifierTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.global.config.PushNotifierConfigTest'`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.global.config.PushNotifierConfigTest' --tests 'com.ticketrush.api.controller.AuthSecurityIntegrationTest' --tests 'com.ticketrush.api.controller.WebSocketPushControllerTest' --tests 'com.ticketrush.global.sse.SsePushNotifierTest' --tests 'com.ticketrush.global.push.WebSocketPushNotifierTest' --tests 'com.ticketrush.global.push.KafkaWebSocketPushNotifierTest' --tests 'com.ticketrush.infrastructure.messaging.KafkaPushEventConsumerTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest' --tests 'com.ticketrush.application.waitingqueue.service.WaitingQueueServiceImplTest' --tests 'com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest' --tests 'com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.application.auth.service.AuthSessionServiceTest'`
- 결과:
  - compile/test PASS
  - queue/push 로그 키(`QUEUE_MONITOR`, `PUSH_MONITOR`, `PUSH_MONITOR_SNAPSHOT`) 기준 운영 추적 가능

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` 하위 Phase7-B로 누적 반영
