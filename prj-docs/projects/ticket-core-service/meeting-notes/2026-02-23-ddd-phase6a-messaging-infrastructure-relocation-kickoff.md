# Meeting Notes: DDD Phase6-A Messaging Infrastructure Relocation Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 18:52:00`
> - **Updated At**: `2026-02-23 19:01:20`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase6-A)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase5-B에서 global 계층의 Redis 직접 의존을 제거했다.
  - Kafka producer/consumer 구현체는 아직 `global.messaging` 패키지에 남아 있다.
  - 메시징 구현체는 infrastructure 책임으로 정렬하는 것이 clean architecture 경계에 부합한다.

## 안건 2: 이번 범위(Phase6-A)
- Status: DONE
- 범위:
  - `global.messaging`의 Kafka 구현체/모델을 `infrastructure.messaging`으로 이동
    - `KafkaReservationProducer`, `KafkaReservationConsumer`
    - `KafkaPushEvent`, `KafkaPushEventProducer`, `KafkaPushEventConsumer`
  - 참조 경로 정렬:
    - `ReservationController`
    - `KafkaWebSocketPushNotifier`
    - 관련 테스트 패키지/import
  - ArchUnit 규칙 보강:
    - `global..`의 `org.springframework.kafka..` 직접 의존 금지
- 목표:
  - Kafka 구현체는 infrastructure로 집약하고 global/application은 구현체 패키지 직접 의존을 최소화
- 구현 결과:
  - 메시징 구현체/모델 이동:
    - `KafkaReservationProducer`, `KafkaReservationConsumer`
    - `KafkaPushEvent`, `KafkaPushEventProducer`, `KafkaPushEventConsumer`
    - 테스트 `KafkaPushEventConsumerTest` 패키지/경로 정렬
  - 참조 경로 정렬:
    - `ReservationController`
    - `KafkaWebSocketPushNotifier`
    - `KafkaWebSocketPushNotifierTest`
  - ArchUnit 보강:
    - `global_should_not_depend_on_spring_kafka_directly` 규칙 추가
    - 메시징 규칙 대상을 `infrastructure.messaging..`으로 정렬

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - Kafka 토픽/파티션/consumer group 설정 변경
  - 메시지 payload 스키마 변경
  - Redis/Kafka 브로커 운영 구성 변경

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.infrastructure.messaging.KafkaPushEventConsumerTest' --tests 'com.ticketrush.global.push.KafkaWebSocketPushNotifierTest' --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest'`
- 결과:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - 타깃 테스트 세트 PASS

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open)
  - `rag-cargoo/ticket-core-service PR #49` (merged, cross-repo shorthand)
  - merge commit: `3637879eb55fb574107c6d0aadb98695ca37b994`
- Sidecar:
  - `rag-cargoo/aki-agentops#155` (reopened)
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에서 누적 관리
