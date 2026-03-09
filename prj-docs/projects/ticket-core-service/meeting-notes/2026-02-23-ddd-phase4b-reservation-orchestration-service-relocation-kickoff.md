# Meeting Notes: DDD Phase4-B Reservation Orchestration Service Relocation Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 09:46:00`
> - **Updated At**: `2026-02-23 09:51:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase4-B)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase4-A에서 ArchUnit + CI `verify` 가드레일을 고정했다.
  - reservation 흐름의 일부 오케스트레이션 서비스가 아직 `domain.reservation.service`에 남아 있다.

## 안건 2: 이번 범위(Phase4-B)
- Status: DONE
- 범위:
  - 아래 서비스/구현을 `domain.reservation.service` -> `application.reservation.service`로 이동
    - `ReservationQueueService*`
    - `SeatSoftLockService*`
    - `AbuseAuditService*`
    - `AbuseAuditWriter`
    - `AdminRefundAuditService`
  - 참조 업데이트:
    - `ReservationController`
    - `ReservationLifecycleServiceImpl`
    - `KafkaReservationConsumer`
    - soft-lock response DTO
    - 연관 테스트
  - ArchUnit 규칙 1건 추가:
    - `ReservationController -> domain.reservation.service` 직접 의존 금지
- 구현 결과:
  - 서비스 재배치 완료:
    - `AbuseAuditService*`
    - `AbuseAuditWriter`
    - `AdminRefundAuditService`
    - `ReservationQueueService*`
    - `SeatSoftLockService*`
    - 위치: `domain.reservation.service` -> `application.reservation.service`
  - 참조 업데이트:
    - `ReservationController`
    - `ReservationLifecycleServiceImpl`
    - `KafkaReservationConsumer`
    - `SeatSoftLockAcquireResponse`
    - `SeatSoftLockReleaseResponse`
    - reservation 연관 테스트 전반(import/package 참조 정렬)
  - ArchUnit 규칙 추가:
    - `reservation_controller_should_not_depend_on_domain_reservation_services`

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - reservation 도메인 엔티티/상태머신 로직 변경
  - API 스펙/응답 스키마 변경
  - aggregate 모델 재설계(후속 단계)

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest'`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest'`
- 결과:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest'` PASS

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open)
- Sidecar:
  - `rag-cargoo/aki-agentops#155` (reopened)
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에서 누적 관리
