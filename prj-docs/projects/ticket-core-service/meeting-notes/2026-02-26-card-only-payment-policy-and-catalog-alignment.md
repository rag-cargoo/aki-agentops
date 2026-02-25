# Meeting Notes: Card-Only Payment Policy + Catalog Alignment (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-26 07:18:00`
> - **Updated At**: `2026-02-26 07:18:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 정책 변경 요약
> - 안건 2: 기본 provider/카탈로그 정렬
> - 안건 3: 결제게이트웨이 허용 수단 축소
> - 안건 4: 테스트 정렬
> - 안건 5: 이슈/태스크 동기화
<!-- DOC_TOC_END -->

## 안건 1: 정책 변경 요약
- Status: DONE
- 요약:
  - 결제 기본 동작을 `CARD` 단일 경로로 고정한다.
  - 무통장입금(`BANK_TRANSFER`)은 결제수단 계약에서 제거한다.
  - 런타임 기본 provider를 `mock`으로 전환해 카드 결제 시뮬레이션을 기본값으로 사용한다.

## 안건 2: 기본 provider/카탈로그 정렬
- Status: DONE
- 결정:
  - `app.payment.provider` 기본값을 `wallet -> mock`으로 변경한다.
  - `GET /api/payments/methods` 카탈로그에서 기본 노출 수단을 `CARD/KAKAOPAY/NAVERPAY`로 정렬한다.
  - `mock` provider에서는 `CARD`만 enabled, `KAKAOPAY/NAVERPAY`는 planned로 노출한다.
  - wallet provider는 레거시 호환 테스트 경로만 유지하고 기본 런타임에서는 사용하지 않는다.

## 안건 3: 결제게이트웨이 허용 수단 축소
- Status: DONE
- 결정:
  - `MockPaymentGateway`, `PgReadyPaymentGateway`는 `CARD`만 허용한다.
  - `ReservationLifecycleServiceImpl` 결제수단 fallback은 기본 `CARD`로 고정하되, wallet provider 테스트 호환 분기만 유지한다.
  - `PaymentMethod` enum에서 `BANK_TRANSFER`를 제거한다.
  - `PgReadyWebhookService` 검증도 `CARD` 전용으로 정렬한다.

## 안건 4: 테스트 정렬
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.application.payment.service.PaymentMethodCatalogServiceTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest'` PASS

## 안건 5: 이슈/태스크 동기화
- Status: DOING
- 트래킹:
  - backend issue: `https://github.com/rag-cargoo/ticket-core-service/issues/50`
  - frontend issue: `https://github.com/rag-cargoo/ticket-web-app/issues/3`
  - task:
    - `prj-docs/projects/ticket-core-service/task.md` `TCS-SC-031`
    - `prj-docs/projects/ticket-web-app/task.md` `TWA-SC-012`
