# Meeting Notes: DDD Phase8-H Remaining API DTO Domain-Model Decoupling Completion (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-24 03:54:00`
> - **Updated At**: `2026-02-24 03:54:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase8-H)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase8-G 이후 API DTO domain import 잔여 12건이 남아 있었다.
    - concert 응답 DTO 3건
    - reservation/sales-policy/admin-audit DTO 5건
    - payment transaction DTO 1건
    - reservation lifecycle 관련 응답/요청 경계 포함
  - adapter(API)에서 domain 모델/enum을 직접 참조하면 경계 변경 시 파급이 커지므로 application 결과/문자열 계약으로 정렬이 필요했다.

## 안건 2: 이번 범위(Phase8-H)
- Status: DONE
- 범위:
  - reservation/sales-policy/admin-audit 경계 정렬:
    - `ReservationResponse`, `ReservationLifecycleResponse`의 domain 오버로드 제거
    - `SalesPolicyUpsertRequest`, `SalesPolicyUpsertCommand`의 tier를 `String` 계약으로 전환
    - `SalesPolicyServiceImpl`에서 tier 문자열 파싱/검증 수행
    - `SalesPolicyResult`, `SalesPolicyResponse` tier를 문자열 계약으로 정렬
    - `AdminRefundAuditRecord`, `AdminRefundAuditResponse` actorRole을 문자열 계약으로 정렬
  - payment 경계 정렬:
    - `application.payment.model.PaymentTransactionResult` 추가
    - `PaymentUseCase` wallet-facing result 메서드 추가:
      - `chargeWalletResult(...)`
      - `getTransactionResults(...)`
    - `WalletController`, `PaymentTransactionResponse`를 result 모델 기반으로 전환
  - concert 경계 정렬:
    - `application.concert.model.{ConcertResult, ConcertOptionResult, SeatResult}` 추가
    - `ConcertUseCase`에 result wrapper 메서드(`...Result`) 추가
    - `ConcertController`, `AdminConcertController`를 result wrapper 메서드 기반으로 전환
    - `ConcertResponse`, `ConcertOptionResponse`, `SeatResponse`를 result 모델 기반으로 전환
  - 테스트/규칙 정렬:
    - ArchUnit 규칙 추가:
      - `reservation_and_payment_api_dto_should_not_depend_on_domain_models`
- 목표:
  - 잔여 API DTO/controller의 domain 직접 의존을 `0`으로 수렴하고 adapter 경계를 `api -> application result` 계약으로 고정

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - domain 엔티티/리포지토리 구조 자체 변경 없음
  - API endpoint URI/HTTP 스펙 자체 변경 없음
  - Redis 런타임 의존 통합테스트(`ConcertExplorerIntegrationTest`)의 환경 구성 문제는 별도 운영 이슈로 유지

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests com.ticketrush.architecture.LayerDependencyArchTest --tests com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest --tests com.ticketrush.application.payment.service.PaymentServiceIntegrationTest --tests com.ticketrush.application.catalog.service.EntertainmentArtistCrudDataJpaTest`
  - `rg -n "^import com\\.ticketrush\\.domain\\." src/main/java/com/ticketrush/api/dto src/main/java/com/ticketrush/api/controller src/main/java/com/ticketrush/api/waitingqueue`
- 결과:
  - compile/test PASS
  - API DTO/controller 기준 domain import 잔여 `12 -> 0` 확인
  - 참고: `ConcertExplorerIntegrationTest`는 Redis 미기동 환경에서 실패 가능(환경 의존)

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
  - comment: `https://github.com/rag-cargoo/ticket-core-service/issues/33#issuecomment-3946655907`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` Phase8-H 반영
