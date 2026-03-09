# Wallet/Payment API Specification

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 00:15:00`
> - **Updated At**: `2026-02-25 02:35:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Source
> - Publication Policy
> - Content
> - 1. 개요
> - 2. 지갑 API 상세 명세
> - 2.4 결제수단 상태 조회 (프론트 연동)
> - 3. 예약 결제/환불 연동 규약
> - 4. 거래 타입/상태 enum
> - 5. 오류 응답
<!-- DOC_TOC_END -->

## Source
- SoT: `AKI AgentOps sidecar` (`prj-docs/projects/ticket-core-service/product-docs/**`)

## Publication Policy
- 이 문서는 GitHub Pages 사용자 탐색용 공식 문서다.
- 변경은 `rag-cargoo/aki-agentops` sidecar PR에서 관리한다.

## Content

지갑 잔액, 충전, 거래원장 조회와 예약 결제/환불 연동 계약을 정의합니다.

---

## 1. 개요

- Base Path: `/api/users/{userId}/wallet`
- Payment Method Catalog Path: `/api/payments/methods`
- 초기 잔액:
  - 신규 사용자 생성 시 `walletBalanceAmount=200000`
- 기본 결제 금액:
  - `app.payment.default-ticket-price-amount` (기본 `100000`)

---

## 2. 지갑 API 상세 명세

### 2.1 지갑 잔액 조회
- **Endpoint**: `GET /api/users/{userId}/wallet`

**Response (200)**

```json
{
  "userId": 101,
  "walletBalanceAmount": 250000
}
```

### 2.2 지갑 충전
- **Endpoint**: `POST /api/users/{userId}/wallet/charges`

**Request Body**

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `amount` | Long | Yes | 충전 금액(양수) |
| `idempotencyKey` | String | No | 재시도 멱등 키(권장) |
| `description` | String | No | 거래 설명(미입력 시 `WALLET_CHARGE`) |

**Request Example**

```json
{
  "amount": 50000,
  "idempotencyKey": "wallet-charge-101-20260219-0001",
  "description": "MANUAL_TOPUP"
}
```

**Response (200)**

```json
{
  "id": 901,
  "userId": 101,
  "reservationId": null,
  "type": "CHARGE",
  "status": "SUCCESS",
  "paymentMethod": "WALLET",
  "paymentProvider": "wallet",
  "providerTransactionId": null,
  "amount": 50000,
  "balanceAfterAmount": 250000,
  "idempotencyKey": "wallet-charge-101-20260219-0001",
  "description": "MANUAL_TOPUP",
  "createdAt": "2026-02-19T00:20:11"
}
```

### 2.3 거래내역 조회
- **Endpoint**: `GET /api/users/{userId}/wallet/transactions?limit={n}`

쿼리 규약:
- `limit` 기본값 `20`
- `limit <= 0` 이면 `20`으로 정규화
- 최대 `100`

**Response (200)**

```json
[
  {
    "id": 903,
    "userId": 101,
    "reservationId": 77,
    "type": "REFUND",
    "status": "SUCCESS",
    "paymentMethod": "WALLET",
    "paymentProvider": "wallet",
    "providerTransactionId": null,
    "amount": 100000,
    "balanceAfterAmount": 250000,
    "idempotencyKey": "reservation-refund-77",
    "description": "RESERVATION_REFUND",
    "createdAt": "2026-02-19T00:28:21"
  },
  {
    "id": 902,
    "userId": 101,
    "reservationId": 77,
    "type": "PAYMENT",
    "status": "SUCCESS",
    "paymentMethod": "WALLET",
    "paymentProvider": "wallet",
    "providerTransactionId": null,
    "amount": 100000,
    "balanceAfterAmount": 150000,
    "idempotencyKey": "reservation-payment-77",
    "description": "RESERVATION_PAYMENT",
    "createdAt": "2026-02-19T00:25:04"
  }
]
```

### 2.4 결제수단 상태 조회 (프론트 연동)
- **Endpoint**: `GET /api/payments/methods`
- **Description**:
  - 프론트 결제수단 UI의 단일 Source of Truth.
  - provider별 기본 가용성 + 운영 override를 합성해 반환.
- **운영 override 설정**:
  - `app.payment.external-live-enabled` (`APP_PAYMENT_EXTERNAL_LIVE_ENABLED`)
  - `app.payment.method-status-overrides.{methodCode}` (`available|planned|maintenance|disabled`)
  - `app.payment.method-message-overrides.{methodCode}` (사용자 안내문구)
- **연동 상태 필드**:
  - `providerMode`: `WALLET_LEDGER`, `MOCK_SIMULATION`, `PG_WEBHOOK_READY`, `PG_EXTERNAL_LIVE`
  - `externalLiveEnabled`: 실결제 연동 활성화 여부

**Response (200)**

```json
{
  "provider": "wallet",
  "defaultMethod": "WALLET",
  "providerMode": "WALLET_LEDGER",
  "externalLiveEnabled": false,
  "methods": [
    {
      "code": "WALLET",
      "label": "Wallet",
      "enabled": true,
      "status": "AVAILABLE",
      "message": "현재 사용 가능"
    },
    {
      "code": "CARD",
      "label": "카드",
      "enabled": false,
      "status": "PLANNED",
      "message": "구현 예정"
    }
  ]
}
```

---

## 3. 예약 결제/환불 연동 규약

예약 상태머신 연동:
- `POST /api/reservations/v6/{reservationId}/confirm`
  - `paymentMethod`(선택): `WALLET`, `CARD`, `KAKAOPAY`, `NAVERPAY`, `BANK_TRANSFER` (미지정 시 `WALLET`)
  - `GET /api/payments/methods` 결과에서 `enabled=false`인 수단으로 confirm 요청 시 `409 CONFLICT`로 차단
  - `pg-ready` + `externalLiveEnabled=false`인 경우, 결제는 `PENDING`으로 기록되고 승인 webhook 이후 `SUCCESS`로 전이
  - `wallet` provider: 즉시 성공(`SUCCESS`)으로 확정되며 지갑에서 결제 금액 차감
  - `pg-ready` provider: 초기 `PENDING` 기록 후 webhook 승인 시 `SUCCESS` 전이
  - 거래 타입 `PAYMENT` 원장 기록
  - 응답 보강 필드:
    - `paymentMethod`
    - `paymentProvider`
    - `paymentStatus`
    - `paymentTransactionId`
- `POST /api/reservations/v6/{reservationId}/refund`
  - 성공 시 지갑으로 결제 금액 환불
  - 거래 타입 `REFUND` 원장 기록

Auth Track A2 동일 규칙:
- `POST /api/reservations/v7/{reservationId}/confirm`
- `POST /api/reservations/v7/{reservationId}/refund`
- v7 `confirm`도 동일하게 `paymentMethod` body(선택)를 허용합니다.

PG webhook 연동:
- `POST /api/payments/webhooks/pg-ready`
  - `eventType=PAYMENT`, `status=APPROVED`: 결제 원장 `SUCCESS`, 예약 `CONFIRMED` 확정
  - `eventType=PAYMENT`, `status=FAILED`: 결제 원장 `FAILED`, 예약은 `PAYING` 유지
  - `providerEventId`가 있으면 `payment_transactions.provider_transaction_id`에 저장되어 외부 이벤트 추적 가능

원장 영속 보강:
- `payment_transactions.payment_method`
- `payment_transactions.payment_provider`
- `payment_transactions.provider_transaction_id`

검증 스크립트:
- `scripts/api/v14-wallet-payment-flow.sh`

---

## 4. 거래 타입/상태 enum

| Field | Values |
| :--- | :--- |
| `type` | `CHARGE`, `PAYMENT`, `REFUND` |
| `status` | `PENDING`, `SUCCESS`, `FAILED` |

결제수단 상태 enum:

| Field | Values |
| :--- | :--- |
| `methodStatus` | `AVAILABLE`, `PLANNED`, `MAINTENANCE`, `DISABLED` |

결제 provider mode:

| Field | Values |
| :--- | :--- |
| `providerMode` | `WALLET_LEDGER`, `MOCK_SIMULATION`, `PG_WEBHOOK_READY`, `PG_EXTERNAL_LIVE` |

---

## 5. 오류 응답

대표 오류:
- `400` + JSON(`BAD_REQUEST`): `amount must be positive`
- `404/400` + JSON(`BAD_REQUEST`): `User not found: {userId}`
- `409` + JSON(`CONFLICT`): `Insufficient wallet balance.`

예시:

```json
{
  "status": 409,
  "errorCode": "CONFLICT",
  "message": "Insufficient wallet balance."
}
```
