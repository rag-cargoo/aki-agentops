# Meeting Notes: DDD Phase4-C Reservation Controller Domain Decoupling Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 10:02:00`
> - **Updated At**: `2026-02-23 10:28:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase4-C)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase4-B에서 reservation 오케스트레이션 서비스를 `application` 계층으로 이동했다.
  - `ReservationController`에는 아직 `domain.reservation` 타입(`event/entity enum`)이 노출되어 있다.

## 안건 2: 이번 범위(Phase4-C)
- Status: DONE
- 범위:
  - reservation controller 입력/출력/전송 타입의 `domain.reservation` 직접 의존 제거
    - queue lock type
    - abuse/admin-audit query/result 타입
  - application model 기반 매핑으로 전환
  - ArchUnit 규칙 강화:
    - `ReservationController -> domain.reservation..` 직접 의존 금지
- 구현 결과:
  - application model 추가:
    - `ReservationQueueLockType`
    - `AbuseAuditActionType`
    - `AbuseAuditResultType`
    - `AbuseAuditReasonType`
    - `AbuseAuditRecord`
    - `AdminRefundAuditResultType`
    - `AdminRefundAuditRecord`
  - controller/producer 매핑 전환:
    - `ReservationController`에서 queue lock type을 application enum으로 사용
    - `KafkaReservationProducer`에 application enum 기반 `send(userId, seatId, lockType)` 추가
  - audit 서비스 API 전환:
    - `AbuseAuditService*`, `AdminRefundAuditService`의 query/result 시그니처를 application model 기준으로 변경
    - `AbuseAuditResponse`, `AdminRefundAuditResponse` 매핑을 application record 기준으로 전환
  - ArchUnit 규칙 강화:
    - `LayerDependencyArchTest`의 reservation controller 규칙을
      `domain.reservation.service..` -> `domain.reservation..`로 확장

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - 도메인 엔티티/상태머신 로직 변경
  - DB 스키마 변경
  - API 필드명/스키마 변경

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest'`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest'`
- 결과:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest'` PASS

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open)
- Sidecar:
  - `rag-cargoo/aki-agentops#155` (reopened)
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에서 누적 관리
