# Meeting Notes: DDD Phase3-A Application Command/Result Decoupling Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 08:55:00`
> - **Updated At**: `2026-02-23 09:00:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase3-A)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase2-A/2-B에서 `domain -> api` 의존을 0으로 만들었다.
  - 다음 잔여는 `application -> api dto` 직접 의존 제거다.

## 안건 2: 이번 범위(Phase3-A)
- Status: DONE
- 범위:
  - `application.waitingqueue.service`가 API DTO를 직접 참조하지 않도록 분리한다.
  - `application.payment.webhook.PgReadyWebhookService`가 API DTO를 직접 참조하지 않도록 분리한다.
  - controller에서 API DTO <-> application command/result 변환 책임을 가진다.
  - 적용 결과:
    - waitingqueue: `WaitingQueueJoinCommand`/`WaitingQueueStatusQuery`/`WaitingQueueStatusResult`/`WaitingQueueStatusType` 도입
    - payment webhook: `PgReadyWebhookCommand`/`PgReadyWebhookResult` 도입
    - API 컨트롤러에서 request/response 매핑 책임화 완료

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - `application.reservation.service` 전면 command/result 분리는 Phase3-B로 미룬다.
  - API 스펙 필드 변경은 하지 않는다(응답 스키마 호환 유지).

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.application.waitingqueue.service.WaitingQueueServiceImplTest' --tests 'com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest'` PASS

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open)
- Sidecar:
  - `rag-cargoo/aki-agentops#155` (reopened)
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에서 누적 관리

## 결과 스냅샷
- `application -> api dto` import 잔여: `12`건 / `6`파일
- 잔여 파일(Phase3-B 대상):
  - `src/main/java/com/ticketrush/application/reservation/service/ReservationService.java`
  - `src/main/java/com/ticketrush/application/reservation/service/ReservationServiceImpl.java`
  - `src/main/java/com/ticketrush/application/reservation/service/ReservationLifecycleService.java`
  - `src/main/java/com/ticketrush/application/reservation/service/ReservationLifecycleServiceImpl.java`
  - `src/main/java/com/ticketrush/application/reservation/service/SalesPolicyService.java`
  - `src/main/java/com/ticketrush/application/reservation/service/SalesPolicyServiceImpl.java`
