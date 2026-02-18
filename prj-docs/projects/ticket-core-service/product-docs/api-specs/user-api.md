# User API Specification

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 17:03:13`
> - **Updated At**: `2026-02-19 00:15:05`
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
> - 1. API 상세 명세 (Endpoint Details)
> - 2. 공통 에러 응답 (Common Error)
<!-- DOC_TOC_END -->

## Source
- SoT: `AKI AgentOps sidecar` (`prj-docs/projects/ticket-core-service/product-docs/**`)
- Updated For Dedup: 2026-02-17 22:38:23

## Publication Policy
- 이 문서는 GitHub Pages 사용자 탐색용 공식 문서다.
- 변경은 `rag-cargoo/aki-agentops` sidecar PR에서 관리한다.

## Content



티켓 서비스 이용자의 사용자 프로필을 관리하는 API입니다.

---

## 1. API 상세 명세 (Endpoint Details)

### 1.1. 신규 유저 생성
- **Endpoint**: `POST /api/users`
- **Description**: 시스템 이용을 위한 유저를 생성합니다.

**Request Body**

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `username` | String | Yes | 사용자 식별 이름 (중복 불가) |
| `tier` | String | No | 사용자 등급 (`BASIC`, `SILVER`, `GOLD`, `VIP`) |

**Response (200 OK)**

```json
{
  "id": 1,
  "username": "tester1",
  "tier": "BASIC",
  "role": "USER",
  "socialProvider": null,
  "socialId": null,
  "email": null,
  "displayName": null,
  "walletBalanceAmount": 200000
}
```

---

### 1.2. 유저 목록 조회
- **Endpoint**: `GET /api/users`
- **Description**: 전체 유저 목록을 조회합니다.

**Response Summary (200 OK)**

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | Long | 유저 ID |
| `username` | String | 사용자 이름 |
| `tier` | String | 사용자 등급 |
| `role` | String | 권한 (`USER`, `ADMIN`) |
| `socialProvider` | String\|Null | 소셜 공급자 (`KAKAO`, `NAVER`) |
| `socialId` | String\|Null | 소셜 계정 식별자 |
| `email` | String\|Null | 이메일 |
| `displayName` | String\|Null | 표시 이름 |
| `walletBalanceAmount` | Long | 지갑 잔액 |

---

### 1.3. 유저 단건 조회
- **Endpoint**: `GET /api/users/{id}`
- **Description**: ID를 기반으로 유저 상세 정보를 조회합니다.

---

### 1.4. 유저 수정
- **Endpoint**: `PUT /api/users/{id}`
- **Description**: 유저 프로필을 수정합니다.

**Request Body**

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `username` | String | No | 사용자 이름 |
| `tier` | String | No | 사용자 등급 |
| `email` | String | No | 이메일 |
| `displayName` | String | No | 표시 이름 |

**Request Example**

```json
{
  "username": "tester1-updated",
  "tier": "VIP",
  "email": "tester1@example.com",
  "displayName": "Tester One"
}
```

**Response (200 OK)**

```json
{
  "id": 1,
  "username": "tester1-updated",
  "tier": "VIP",
  "role": "USER",
  "socialProvider": "KAKAO",
  "socialId": "1234567890",
  "email": "tester1@example.com",
  "displayName": "Tester One",
  "walletBalanceAmount": 200000
}
```

---

### 1.5. 유저 삭제
- **Endpoint**: `DELETE /api/users/{id}`
- **Description**: 유저 계정을 삭제합니다.
- **Response**: `204 No Content`

---

### 1.6. 지갑/결제 API 연계
- 지갑 조회/충전/거래내역은 별도 문서 `./wallet-payment-api.md`를 참조합니다.
- 유저 응답(`POST/GET/PUT /api/users`)의 `walletBalanceAmount`는 현재 잔액 스냅샷입니다.

---

## 2. 공통 에러 응답 (Common Error)

```json
{
  "timestamp": "2026-02-18T08:35:00.000",
  "status": 404,
  "error": "Not Found",
  "path": "/api/users/999"
}
```
