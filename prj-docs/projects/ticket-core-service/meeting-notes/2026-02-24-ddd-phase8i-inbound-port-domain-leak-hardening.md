# Meeting Notes: DDD Phase8-I Inbound Port Domain-Leak Hardening (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-24 04:09:00`
> - **Updated At**: `2026-02-24 04:09:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase8-I)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase8-H 이후 API DTO/controller의 domain import는 `0`이 되었지만, 일부 `application..port.inbound` 계약에서 domain 타입 노출이 남아 있었다.
    - `ConcertUseCase`
    - `PaymentUseCase`
    - `AdminRefundAuditUseCase`
  - inbound 포트가 domain 모델을 직접 노출하면 adapter/usecase 경계에서 계약 안정성이 떨어져 후속 변경 파급이 커질 수 있어 계약 정리가 필요했다.

## 안건 2: 이번 범위(Phase8-I)
- Status: DONE
- 범위:
  - inbound 포트 계약 정리:
    - `ConcertUseCase`를 result 계약 중심으로 재구성
      - `ConcertResult`, `ConcertOptionResult`, `SeatResult`
    - `PaymentUseCase`에서 domain `PaymentTransaction` 노출 제거
    - `AdminRefundAuditUseCase` actorRole을 `String` 계약으로 전환
  - bridge 포트 도입:
    - `application.payment.port.bridge.PaymentGatewayUseCase` 추가
    - `WalletPaymentGateway` 의존을 bridge 포트로 전환
  - 구현 정렬:
    - `ConcertService`에 domain 연산 계약을 분리 유지(테스트/내부 사용 호환)
    - `ConcertServiceImpl`에 result 메서드 명시 구현
    - `AdminRefundAuditService`에 actorRole 문자열 파싱/검증 추가
    - `ReservationLifecycleServiceImpl`의 admin audit 호출부를 string role 계약으로 전환
  - 규칙 강화:
    - ArchUnit: `inbound_ports_should_not_depend_on_domain_models`
- 목표:
  - `application..port.inbound` 기준 domain 직접 의존 잔여를 `0`으로 수렴하고 재유입을 테스트로 차단

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - reservation/payment 도메인 엔티티/리포지토리 구조 변경 없음
  - endpoint URI/HTTP 계약 변경 없음
  - Redis 런타임 의존 테스트(`ConcertExplorerIntegrationTest`)는 별도 환경 이슈로 유지

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests com.ticketrush.architecture.LayerDependencyArchTest --tests com.ticketrush.application.payment.service.PaymentServiceIntegrationTest --tests com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest --tests com.ticketrush.infrastructure.payment.gateway.MockPaymentGatewayIntegrationTest --tests com.ticketrush.infrastructure.payment.gateway.PgReadyPaymentGatewayIntegrationTest`
  - `rg -n "^import com\\.ticketrush\\.domain\\." src/main/java/com/ticketrush/application --glob "**/port/inbound/*.java" | wc -l`
  - `rg -n "^import com\\.ticketrush\\.domain\\." src/main/java/com/ticketrush/api/dto src/main/java/com/ticketrush/api/controller src/main/java/com/ticketrush/api/waitingqueue | wc -l`
- 결과:
  - compile/test PASS
  - inbound port domain import `0` 확인
  - API DTO/controller domain import `0` 유지 확인

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
  - comment: `https://github.com/rag-cargoo/ticket-core-service/issues/33#issuecomment-3946749572`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` Phase8-I 반영
