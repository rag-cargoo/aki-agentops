# Meeting Notes: DDD Phase2-A Reservation Application Boundary Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 07:55:00`
> - **Updated At**: `2026-02-23 08:30:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase2-A)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase1에서 `Entity -> api`/`Controller -> Repository` 경계 위반은 해소했다.
  - 현재 잔여는 `domain service -> api dto` 의존이며, DDD 경계상 Phase2에서 제거가 필요하다.

## 안건 2: 이번 범위(Phase2-A)
- Status: DONE
- 범위:
  - `reservation` 도메인 서비스 계층에서 `api.dto` 의존을 제거한다.
  - 적용 대상:
    - `ReservationService*`
    - `ReservationLifecycleService*`
    - `SalesPolicyService*`
  - 방향:
    - `reservation` 서비스 6개 클래스를 `domain.reservation.service`에서 `application.reservation.service`로 이동
    - 컨트롤러/락/메시징/스케줄러/테스트의 참조 경로를 `application` 패키지로 정렬
  - 결과:
    - `domain -> api` import 잔여에서 `reservation service` 6개 파일이 제외됨

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - `waitingqueue` 서비스 계층 정리는 Phase2-B에서 수행한다.
  - `payment/webhook` 서비스 계층 정리는 Phase2-B에서 수행한다.
  - application/use-case 계층 전면 도입은 별도 후속 단계로 유지한다.

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.domain.reservation.service.ReservationLifecycleServiceIntegrationTest'` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest'` PASS
  - 참고:
    - `ConcertExplorerIntegrationTest` 포함 실행은 로컬 Redis 미기동으로 실패(`RedisConnectionException`)

## 안건 5: 트래킹
- Status: DOING
- Product:
  - `rag-cargoo/ticket-core-service#33` (reopened, cross-repo shorthand)
  - `rag-cargoo/ticket-core-service#33 comment 3941854946` (phase2-a kickoff)
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에서 Phase2 진행상태를 누적 관리한다.

## 증빙
- Context:
  - `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-23-clean-ddd-hexagonal-governance-kickoff.md`
- Residual Snapshot:
  - `domain -> api` import 잔여: `5`건 / `3`파일
  - 잔여 파일:
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/domain/waitingqueue/service/WaitingQueueService.java`
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/domain/waitingqueue/service/WaitingQueueServiceImpl.java`
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/domain/payment/webhook/PgReadyWebhookService.java`
