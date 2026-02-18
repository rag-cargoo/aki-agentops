# Auth Session API Specification (Auth Track A2)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 17:03:13`
> - **Updated At**: `2026-02-19 01:31:31`
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
<!-- DOC_TOC_END -->

## Source
- SoT: `AKI AgentOps sidecar` (`prj-docs/projects/ticket-core-service/product-docs/**`)
- Updated For Dedup: 2026-02-17 22:38:23

## Publication Policy
- 이 문서는 GitHub Pages 사용자 탐색용 공식 문서다.
- 변경은 `rag-cargoo/aki-agentops` sidecar PR에서 관리한다.

## Content



---

## 0. 개요

- 목적: 소셜 로그인 교환 결과를 실제 서비스 로그인 세션(JWT Access/Refresh)으로 연결한다.
- 기본 경로:
  - 인증: `/api/auth`
  - 예약(v7): `/api/reservations/v7`
- 토큰 형식: `Authorization: Bearer {accessToken}`

**Parameters**

- 공통 헤더: `Authorization: Bearer {accessToken}` (`/api/auth/me`, `/api/reservations/v7/**`)
- 토큰 교환/갱신 요청 본문: JSON (`provider`, `code`, `state`, `refreshToken`)

---

## 1. 세션 토큰 API

### 1.1 소셜 교환 + 세션 발급
- **Endpoint**: `POST /api/auth/social/{provider}/exchange`
- **Description**: 기존 A1의 사용자 매핑 결과에 Access/Refresh 토큰을 함께 반환한다.

**Response Example (200)**

```json
{
  "userId": 12,
  "username": "kakao_123456789",
  "provider": "kakao",
  "socialId": "123456789",
  "email": "user@example.com",
  "displayName": "테스터",
  "role": "USER",
  "newUser": true,
  "tokenType": "Bearer",
  "accessToken": "eyJ...",
  "refreshToken": "eyJ...",
  "accessTokenExpiresInSeconds": 1800,
  "refreshTokenExpiresInSeconds": 1209600
}
```

**Response Summary**

- `200`: 사용자 매핑 정보 + 세션 토큰 페어(access/refresh) 반환
- `4xx`: provider/코드/상태값 검증 실패 또는 토큰 교환 실패

### 1.2 Access Token 재발급
- **Endpoint**: `POST /api/auth/token/refresh`
- **Description**: 유효한 Refresh Token으로 Access/Refresh를 회전 발급한다.

**Request Example**

```json
{
  "refreshToken": "eyJ..."
}
```

**Response Example (200)**

```json
{
  "tokenType": "Bearer",
  "accessToken": "eyJ...",
  "refreshToken": "eyJ...",
  "accessTokenExpiresInSeconds": 1800,
  "refreshTokenExpiresInSeconds": 1209600
}
```

**Response Summary**

- `200`: refresh 토큰 검증 성공, access/refresh 토큰 회전 발급
- `400`: refresh 토큰 만료/폐기/유형 불일치/사용자 불일치
- `401`: 인증 필터 단계에서 access 토큰 자체가 유효하지 않은 경우

### 1.3 로그아웃
- **Endpoint**: `POST /api/auth/logout`
- **Description**: 현재 세션의 refresh/access를 동시에 무효화한다.

**Headers**

- `Authorization: Bearer {accessToken}` (필수)

**Request Example**

```json
{
  "refreshToken": "eyJ..."
}
```

**Response Summary**

- `200`: refresh revoke + access denylist 등록 완료
- `400`: refresh/access 누락, 토큰 유형 불일치, 사용자 불일치
- `401`: 만료 또는 무효 access 토큰

### 1.4 내 정보 조회
- **Endpoint**: `GET /api/auth/me`
- **Description**: Access Token으로 현재 인증 사용자의 프로필을 조회한다.

---

## 2. 인증 사용자 예약 API(v7)

### 2.1 HOLD 생성
- **Endpoint**: `POST /api/reservations/v7/holds`
- **Description**: 요청 본문의 `seatId`를 현재 인증 사용자 컨텍스트로 HOLD 처리한다.

**Request Example**

```json
{
  "seatId": 1,
  "requestFingerprint": "fp-a2-001",
  "deviceFingerprint": "device-a2-001"
}
```

### 2.2 상태 전이/조회
- `POST /api/reservations/v7/{reservationId}/paying`
- `POST /api/reservations/v7/{reservationId}/confirm`
- `POST /api/reservations/v7/{reservationId}/cancel`
- `POST /api/reservations/v7/{reservationId}/refund`
- `GET /api/reservations/v7/{reservationId}`
- `GET /api/reservations/v7/me`

모든 전이는 인증 사용자 ID를 서버 컨텍스트에서만 사용한다.

---

## 3. 권한 정책

- `USER`:
  - `/api/auth/me`
  - `/api/reservations/v7/**`
- `ADMIN`:
  - `GET /api/reservations/v7/audit/abuse`

인증 실패 시 `401`, 권한 부족 시 `403`을 반환한다.

---

## 4. 검증 스크립트

- API 체인 규칙은 Step(`v*.sh`) + Track(`a*.sh`)를 함께 사용한다.
  - A2 검증 스크립트: `scripts/api/a2-auth-track-session-guard.sh`
