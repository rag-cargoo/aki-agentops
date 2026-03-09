# Meeting Notes: DDD Phase3-B Reservation Command/Result Decoupling Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 09:10:00`
> - **Updated At**: `2026-02-23 09:24:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase3-B)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase3-A에서 waitingqueue/webhook의 `application -> api dto` 직접 의존을 제거했다.
  - 현재 잔여는 reservation 서비스 계층 6파일(`12` imports)이다.

## 안건 2: 이번 범위(Phase3-B)
- Status: DONE
- 범위:
  - `application.reservation.service`의 API DTO 직접 의존 제거
    - `ReservationService*`
    - `ReservationLifecycleService*`
    - `SalesPolicyService*`
  - controller/facade/consumer에서 API DTO <-> application command/result 매핑 책임화
- 구현 결과:
  - application model 추가:
    - `ReservationCreateCommand`
    - `ReservationResult`
    - `ReservationLifecycleResult`
    - `SalesPolicyUpsertCommand`
    - `SalesPolicyResult`
  - service 시그니처 전환:
    - `ReservationService*`
    - `ReservationLifecycleService*`
    - `SalesPolicyService*`
  - 매핑 책임 전환:
    - `ReservationController`
    - `ConcertController`
    - `AdminConcertController`
    - `RedissonLockFacade`
    - `KafkaReservationConsumer`
  - 테스트 정렬:
    - `ReservationLifecycleServiceIntegrationTest`
    - `동시성_테스트_1_낙관적_락`
    - `동시성_테스트_2_비관적_락`
    - `ConcertExplorerIntegrationTest`
  - 잔여 의존 카운트:
    - `application -> api dto import`: `0`건
    - `domain -> api dto import`: `0`건

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - reservation 도메인 엔티티/상태머신 규칙 변경
  - API 스펙 필드 변경(기존 응답 스키마 호환 유지)

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.domain.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.domain.concert.service.ConcertExplorerIntegrationTest' --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest'`
- 결과:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.domain.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest'` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.domain.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.domain.concert.service.ConcertExplorerIntegrationTest' --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest'` FAIL
    - 원인: 로컬 Redis 미기동(`RedisConnectionException`, `ConcertExplorerIntegrationTest` 컨텍스트 부팅 실패)

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open)
- Sidecar:
  - `rag-cargoo/aki-agentops#155` (reopen)
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에서 누적 관리
