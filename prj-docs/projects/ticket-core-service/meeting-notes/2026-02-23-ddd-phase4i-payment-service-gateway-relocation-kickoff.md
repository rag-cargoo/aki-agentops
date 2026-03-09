# Meeting Notes: DDD Phase4-I Payment Service/Gateway Relocation Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 12:46:00`
> - **Updated At**: `2026-02-23 13:11:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase4-I)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase4-H에서 concert controller의 `domain.concert.service` 직접 의존을 제거했다.
  - 현재 controller direct dependency 잔여는 `WalletController -> domain.payment.service.PaymentService` 1축이다.
  - 또한 `WalletPaymentGateway`가 payment service를 사용하므로 service relocation 시 gateway 구현체 경계도 함께 정렬이 필요하다.

## 안건 2: 이번 범위(Phase4-I)
- Status: DONE
- 범위:
  - `PaymentService*`를 `domain.payment.service` -> `application.payment.service`로 이동
  - `WalletPaymentGateway`, `MockPaymentGateway`, `PgReadyPaymentGateway`를 `domain.payment.gateway` -> `infrastructure.payment.gateway`로 이동
  - `WalletController` 및 payment 관련 테스트 import/package 정렬
  - ArchUnit 규칙 보강:
    - `WalletController`의 `domain.payment.service..` 직접 의존 금지
- 목표:
  - payment API는 application service를 경유하고, gateway 구현체는 infrastructure로 정렬
- 구현 결과:
  - 서비스 이동:
    - `domain.payment.service.PaymentService*` -> `application.payment.service.PaymentService*`
  - gateway 구현체 이동:
    - `domain.payment.gateway.WalletPaymentGateway` -> `infrastructure.payment.gateway.WalletPaymentGateway`
    - `domain.payment.gateway.MockPaymentGateway` -> `infrastructure.payment.gateway.MockPaymentGateway`
    - `domain.payment.gateway.PgReadyPaymentGateway` -> `infrastructure.payment.gateway.PgReadyPaymentGateway`
  - API/테스트 정렬:
    - `WalletController`의 service 의존을 `application.payment.service.PaymentService`로 정렬
    - `ReservationLifecycleServiceIntegrationTest` import/`@Import` 정렬
    - payment integration test package 정렬:
      - `application.payment.service.PaymentServiceIntegrationTest`
      - `infrastructure.payment.gateway.MockPaymentGatewayIntegrationTest`
      - `infrastructure.payment.gateway.PgReadyPaymentGatewayIntegrationTest`
  - ArchUnit 보강:
    - `wallet_controller_should_not_depend_on_domain_payment_services` 규칙 추가

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - `PaymentGateway` interface(package: `domain.payment.gateway`) 변경
  - 결제 도메인 엔티티/리포지토리/비즈니스 로직 변경
  - DB 스키마 변경
  - API endpoint/필드 스키마 변경

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.application.payment.service.PaymentServiceIntegrationTest' --tests 'com.ticketrush.infrastructure.payment.gateway.MockPaymentGatewayIntegrationTest' --tests 'com.ticketrush.infrastructure.payment.gateway.PgReadyPaymentGatewayIntegrationTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest'`
- 결과:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.application.payment.service.PaymentServiceIntegrationTest' --tests 'com.ticketrush.infrastructure.payment.gateway.MockPaymentGatewayIntegrationTest' --tests 'com.ticketrush.infrastructure.payment.gateway.PgReadyPaymentGatewayIntegrationTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest'` PASS

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open)
- Sidecar:
  - `rag-cargoo/aki-agentops#155` (reopened)
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에서 누적 관리
