# Meeting Notes: DDD Phase4-D Reservation Event Boundary Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 10:38:00`
> - **Updated At**: `2026-02-23 10:42:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase4-D)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase4-C 이후 reservation controller의 `domain.reservation` 직접 의존은 제거되었다.
  - 다만 Kafka 메시징 경로(`KafkaReservationProducer/Consumer`)는 `domain.reservation.event.ReservationEvent`를 직접 payload로 사용하고 있다.

## 안건 2: 이번 범위(Phase4-D)
- Status: DONE
- 범위:
  - `ReservationEvent` 메시징 payload를 application 계층 모델로 분리
  - `KafkaReservationProducer/Consumer`를 application 모델 기준으로 정렬
  - 필요 시 domain event 클래스 제거 또는 내부 전용화
  - ArchUnit 규칙 보강:
    - `global.messaging.. -> domain.reservation.event..` 직접 의존 금지
- 목표:
  - 외부 메시징 스키마와 도메인 내부 이벤트 개념 경계를 분리
- 구현 결과:
  - application 메시지 모델 추가:
    - `ReservationQueueEvent` (`application.reservation.model`)
  - Kafka 경로 전환:
    - `KafkaReservationProducer` payload를 `ReservationQueueEvent`로 전환
    - `KafkaReservationConsumer` listener payload를 `ReservationQueueEvent`로 전환
    - lock 전략 분기 비교를 `ReservationQueueLockType` 기준으로 전환
  - domain 이벤트 정리:
    - `domain.reservation.event.ReservationEvent` 클래스 제거
  - ArchUnit 보강:
    - `LayerDependencyArchTest`에 `global.messaging.. -> domain.reservation.event..` 직접 의존 금지 규칙 추가

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - reservation 도메인 상태머신/엔티티 규칙 변경
  - DB 스키마 변경
  - API endpoint/필드 스펙 변경

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest'`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest'`
- 결과:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest'` PASS

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open)
- Sidecar:
  - `rag-cargoo/aki-agentops#155` (reopened)
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에서 누적 관리
