# Meeting Notes: DDD Phase2-B WaitingQueue/Webhook Application Boundary Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 08:35:00`
> - **Updated At**: `2026-02-23 08:40:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase2-B)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase2-A에서 `reservation` 서비스 계층 6개 클래스를 `application` 경계로 이동했다.
  - 현재 `domain -> api` import 잔여는 `waitingqueue`/`payment webhook` 3파일이다.

## 안건 2: 이번 범위(Phase2-B)
- Status: DONE
- 범위:
  - `WaitingQueueService*`를 `application.waitingqueue.service`로 이동한다.
  - `PgReadyWebhookService`를 `application.payment.webhook`로 이동한다.
  - 컨트롤러/스케줄러/어댑터/테스트 참조 경로를 `application` 패키지로 정렬한다.
  - 적용 결과:
    - `WaitingQueueService`, `WaitingQueueServiceImpl` 이동 완료
    - `PgReadyWebhookService` 이동 완료
    - `WaitingQueueController`, `WaitingQueueScheduler`, `ReservationWaitingQueuePortAdapter`, `PaymentWebhookController` 참조 정렬 완료

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - `api.dto` 계약 자체를 도메인 전용 command/result로 분리하는 작업은 별도 후속으로 유지한다.
  - CQRS/Event Sourcing 확장은 이번 단계 범위에 포함하지 않는다.

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest' --tests 'com.ticketrush.application.waitingqueue.service.WaitingQueueServiceImplTest' --tests 'com.ticketrush.domain.reservation.service.ReservationLifecycleServiceIntegrationTest'` PASS

## 안건 5: 트래킹
- Status: DOING
- Product:
  - `rag-cargoo/ticket-core-service#33` (reopened, cross-repo shorthand)
- Sidecar:
  - `rag-cargoo/aki-agentops#155` (reopened)
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에서 누적 관리

## 증빙
- Context:
  - `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-23-ddd-phase2a-reservation-application-layer-kickoff.md`
- Residual Snapshot(after Phase2-B):
  - `domain -> api` import 잔여: `0`건 / `0`파일
