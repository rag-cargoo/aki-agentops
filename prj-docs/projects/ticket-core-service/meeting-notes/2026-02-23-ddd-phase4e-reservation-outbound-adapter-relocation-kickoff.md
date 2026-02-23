# Meeting Notes: DDD Phase4-E Reservation Outbound Adapter Relocation Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 11:26:00`
> - **Updated At**: `2026-02-23 11:29:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase4-E)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase4-D에서 Kafka reservation 이벤트 payload를 application 모델로 분리했다.
  - 현재 `domain/reservation/adapter/outbound`에 위치한 포트 어댑터는 인프라 구현체 역할이며, `ReservationWaitingQueuePortAdapter`는 `application` 계층을 직접 참조한다.

## 안건 2: 이번 범위(Phase4-E)
- Status: DONE
- 범위:
  - `domain/reservation/adapter/outbound/*` 구현체를 `infrastructure` 패키지로 이동
    - `ReservationSeatPortAdapter`
    - `ReservationUserPortAdapter`
    - `ReservationPaymentPortAdapter`
    - `ReservationWaitingQueuePortAdapter`
  - ArchUnit 규칙 강화:
    - `domain.. -> application..` 직접 의존 금지
- 목표:
  - domain 레이어는 포트 정의만 유지하고 adapter 구현은 infrastructure 레이어로 정렬
- 구현 결과:
  - adapter relocation:
    - `domain.reservation.adapter.outbound` -> `infrastructure.reservation.adapter.outbound`
    - 이동 대상:
      - `ReservationSeatPortAdapter`
      - `ReservationUserPortAdapter`
      - `ReservationPaymentPortAdapter`
      - `ReservationWaitingQueuePortAdapter`
  - 경계 정리:
    - `ReservationWaitingQueuePortAdapter`가 `application.waitingqueue.service.WaitingQueueService`를 참조하더라도
      domain 패키지가 아닌 infrastructure 패키지에 위치하도록 정렬
  - 테스트 정렬:
    - `ReservationLifecycleServiceIntegrationTest` adapter import를 infrastructure 경로로 갱신
  - ArchUnit 보강:
    - `domain.. -> application..` 직접 의존 금지 규칙 추가

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - reservation 도메인 엔티티/상태머신 변경
  - DB 스키마 변경
  - API endpoint/응답 스키마 변경

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
