# Meeting Notes: Payment Method Selection and Payment Outcome Contract Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-24 16:40:00`
> - **Updated At**: `2026-02-25 03:02:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 반영 범위(백엔드)
> - 안건 3: API 계약 변경 요약
> - 안건 4: 잔여 TODO/이슈
> - 안건 5: 결제수단 상태 API 추가(프론트 하드코딩 제거)
> - 안건 6: 원장 추적 필드 + pg-ready 이벤트 추적 보강
> - 안건 7: confirm 후속 액션 계약(paymentAction/paymentRedirectUrl) 추가
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - 프론트에서 결제수단을 선택하는 UX를 도입하려면 백엔드 `confirm` API가 결제수단 입력과 처리결과를 명확히 반환해야 한다.
  - 기존 구현은 provider 전역 설정 중심이어서, 요청 단위 결제수단 선택/피드백 계약이 약했다.

## 안건 2: 이번 반영 범위(백엔드)
- Status: DONE
- 반영:
  - `PaymentMethod` enum 도입: `WALLET`, `CARD`, `KAKAOPAY`, `NAVERPAY`, `BANK_TRANSFER`
  - `ReservationLifecycleServiceImpl.confirm`:
    - `paymentMethod` 파싱/검증
    - 결제 실행 결과를 예약 응답에 포함
  - `ReservationController`:
    - v6 confirm: `paymentMethod` body 수신
    - v7 confirm: optional body에서 `paymentMethod` 수신(미지정 시 `WALLET`)
  - Gateway 제약:
    - `wallet` provider는 `WALLET`만 허용
    - 미지원 결제수단은 명시적 예외로 차단

## 안건 3: API 계약 변경 요약
- Status: DONE
- Confirm 응답 보강 필드:
  - `paymentMethod`
  - `paymentProvider`
  - `paymentStatus`
  - `paymentTransactionId`
- 문서 반영:
  - `prj-docs/projects/ticket-core-service/product-docs/api-specs/reservation-api.md`
  - `prj-docs/projects/ticket-core-service/product-docs/api-specs/wallet-payment-api.md`
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.infrastructure.payment.gateway.MockPaymentGatewayIntegrationTest' --tests 'com.ticketrush.infrastructure.payment.gateway.PgReadyPaymentGatewayIntegrationTest'` PASS

## 안건 4: 잔여 TODO/이슈
- Status: TODO
- TODO:
  - `pg-ready`를 실제 외부 PG redirect + callback 승인 계약으로 확장
- Issue Tracking:
  - sidecar task 추적: `TCS-SC-027`
  - 제품 레포 이슈: `rag-cargoo/ticket-core-service#50` (cross-repo shorthand)

## 안건 5: 결제수단 상태 API 추가(프론트 하드코딩 제거)
- Status: DONE
- 반영:
  - `GET /api/payments/methods` 추가
    - 응답: `provider`, `defaultMethod`, `providerMode`, `externalLiveEnabled`, `methods[] { code, label, enabled, status, message }`
  - `PaymentMethodCatalogService`로 provider 기반 기본 가용성 + 운영 override 합성
    - `app.payment.method-status-overrides.{methodCode}`
    - `app.payment.method-message-overrides.{methodCode}`
  - 예약 확정 경로에서 결제수단 선검증 추가
    - `ReservationLifecycleServiceImpl.confirm -> paymentMethodCatalogUseCase.assertMethodAvailable`
- 검증:
  - `./gradlew test --no-daemon --tests 'com.ticketrush.application.payment.service.PaymentMethodCatalogServiceTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.infrastructure.payment.gateway.MockPaymentGatewayIntegrationTest' --tests 'com.ticketrush.infrastructure.payment.gateway.PgReadyPaymentGatewayIntegrationTest'` PASS

## 안건 6: 원장 추적 필드 + pg-ready 이벤트 추적 보강
- Status: DONE
- 반영:
  - `PaymentTransaction` 영속 필드 추가:
    - `paymentMethod`, `paymentProvider`, `providerTransactionId`
  - gateway별 결제/환불 원장에 method/provider 저장 반영
  - `PgReadyWebhookService`:
    - `providerEventId`를 `providerTransactionId`로 저장
    - `paymentProvider=pg-ready` 정합성 검증
  - 결제수단 상태 API 응답 보강:
    - `providerMode`
    - `externalLiveEnabled`
- 검증:
  - `./gradlew test --no-daemon --tests 'com.ticketrush.application.payment.service.PaymentMethodCatalogServiceTest' --tests 'com.ticketrush.application.payment.service.PaymentServiceIntegrationTest' --tests 'com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.infrastructure.payment.gateway.MockPaymentGatewayIntegrationTest' --tests 'com.ticketrush.infrastructure.payment.gateway.PgReadyPaymentGatewayIntegrationTest'` PASS

## 안건 7: confirm 후속 액션 계약(paymentAction/paymentRedirectUrl) 추가
- Status: DONE
- 반영:
  - `ReservationLifecycleServiceImpl.confirm` 응답 구성 보강:
    - `paymentAction`: `NONE`, `REDIRECT`, `WAIT_WEBHOOK`, `RETRY_CONFIRM`
    - `paymentRedirectUrl`: `pg-ready + externalLiveEnabled=true + PENDING`일 때 checkout URL 반환
    - redirect URL 빌더를 `build().encode()`로 고정해 callback/success URL 파라미터 인코딩 예외 제거
  - `ReservationLifecycleResponse`/`ReservationLifecycleResult`에 신규 필드 연결
  - 프론트(`ticket-web-app`)는 `confirm` 응답 상태를 기준으로
    - 확정 완료
    - 결제 승인 대기
    - 외부 결제창 이동 필요
    를 분기 안내하도록 계약 정렬(팝업 자동 오픈 + 차단 시 수동 링크 fallback)
  - `ReservationLifecycleServicePgReadyIntegrationTest` 추가:
    - `externalLiveEnabled=true` -> `paymentAction=REDIRECT` + `paymentRedirectUrl != null`
    - `externalLiveEnabled=false` -> `paymentAction=WAIT_WEBHOOK` + `paymentRedirectUrl == null`
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.application.payment.service.PaymentMethodCatalogServiceTest' --tests 'com.ticketrush.application.payment.service.PaymentServiceIntegrationTest' --tests 'com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServicePgReadyIntegrationTest' --tests 'com.ticketrush.infrastructure.payment.gateway.MockPaymentGatewayIntegrationTest' --tests 'com.ticketrush.infrastructure.payment.gateway.PgReadyPaymentGatewayIntegrationTest'` PASS
