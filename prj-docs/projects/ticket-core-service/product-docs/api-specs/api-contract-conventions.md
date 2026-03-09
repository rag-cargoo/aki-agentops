# API Contract Conventions

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 00:15:00`
> - **Updated At**: `2026-02-19 14:40:00`
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
> - 1. 기본 요청/응답 규약
> - 2. 인증/권한 경계
> - 3. 실시간 전송(SSE/WebSocket) 선택 규칙
> - 4. 시간 값(DateTime/Timestamp) 규약
> - 5. 오류 응답 규약
> - 6. 멱등/조회 제한 규약
<!-- DOC_TOC_END -->

## Source
- SoT: `AKI AgentOps sidecar` (`prj-docs/projects/ticket-core-service/product-docs/**`)

## Publication Policy
- 이 문서는 GitHub Pages 사용자 탐색용 공식 문서다.
- 변경은 `rag-cargoo/aki-agentops` sidecar PR에서 관리한다.

## Content

프론트엔드가 도메인 문서(`User`, `Reservation`, `Wallet/Payment`, `Waiting Queue`)를 공통 규칙으로 일관되게 해석하기 위한 계약입니다.

---

## 1. 기본 요청/응답 규약

- Base URL: `http://{host}:{port}`
- API Prefix:
  - 일반 API: `/api/**`
  - OAuth callback redirect: `/login/oauth2/code/{provider}`
- 기본 Content-Type: `application/json`
- 실시간 SSE 응답은 `text/event-stream`
- WebSocket은 STOMP endpoint `/ws` + broker prefix `/topic/**`를 사용

---

## 2. 인증/권한 경계

| 영역 | 예시 Endpoint | 인증 방식 | 실패 코드 |
| :--- | :--- | :--- | :--- |
| Public | `/api/users/**`, `/api/concerts/**`, `/api/reservations/v1~v6/**`, `/api/v1/waiting-queue/**` | 없음 | 도메인별 4xx/5xx |
| User Auth | `/api/auth/me`, `/api/auth/logout`, `/api/reservations/v7/**` | `Authorization: Bearer {accessToken}` | `401` |
| Admin Auth | `/api/reservations/v7/audit/abuse` | `Authorization: Bearer {accessToken}` + `ROLE_ADMIN` | `403` |

보조 헤더:
- `User-Id`: legacy 대기열 인터셉터 컨텍스트용 헤더(필요 시 사용)

---

## 3. 실시간 전송(SSE/WebSocket) 선택 규칙

서버 설정:
- `APP_PUSH_MODE=sse|websocket` (기본 `websocket`)

동작 규칙:
- `sse`: `/api/v1/waiting-queue/subscribe`, `/api/reservations/v5/subscribe` 기반 실시간 수신
- `websocket`: `/ws` + `/topic/**` 기반 실시간 수신
- WebSocket 구독 등록/해제 API는 항상 호출 가능하지만, 실제 실시간 이벤트 전송은 `APP_PUSH_MODE=websocket`일 때 활성화된다.

상세는 `./realtime-push-api.md`를 참조합니다.

---

## 4. 시간 값(DateTime/Timestamp) 규약

| 필드 계열 | 직렬화 형태 | 예시 | 프론트 처리 권장 |
| :--- | :--- | :--- | :--- |
| 상태머신/도메인 응답 `*At` (`holdExpiresAt`, `confirmedAt`) | LocalDateTime (offset 없음) | `2026-02-19T01:23:45` | 서버 로컬 시간으로 해석 후 화면 표준 시간대로 변환 |
| SSE/WebSocket push timestamp | ISO-8601 UTC (`Instant`) | `2026-02-19T01:23:45.123Z` | UTC 기준 파싱 후 사용자 로컬 시간대로 변환 |

주의:
- 현재 응답은 offset 포함/미포함 포맷이 혼재하므로, 프론트는 파서를 분리해 처리해야 합니다.

---

## 5. 오류 응답 규약

보안 필터 계층(`SecurityConfig`)의 인증/인가 실패:

```json
{
  "status": 401,
  "errorCode": "AUTH_ACCESS_TOKEN_REQUIRED",
  "message": "unauthorized"
}
```

```json
{
  "status": 403,
  "errorCode": "AUTH_FORBIDDEN",
  "message": "forbidden"
}
```

auth path(`/api/auth`, `/api/reservations/v7`)의 도메인 예외(`GlobalExceptionHandler`):
- `IllegalArgumentException` -> `400` + JSON(`status`, `errorCode`, `message`)
- `HttpMessageNotReadableException` -> `400` + JSON(`AUTH_REQUEST_BODY_INVALID`)

예시:

```json
{
  "status": 400,
  "errorCode": "AUTH_REFRESH_TOKEN_REQUIRED",
  "message": "refresh token is required"
}
```

비-auth path의 기본 응답:
- `IllegalArgumentException` -> `400` + JSON(`BAD_REQUEST`)
- `IllegalStateException` -> `409` + JSON(`CONFLICT`)
- `HttpMessageNotReadableException` -> `400` + JSON(`REQUEST_BODY_INVALID`)
- 기타 예외 -> `500` + JSON(`INTERNAL_SERVER_ERROR`)

주요 auth errorCode:
- `AUTH_ACCESS_TOKEN_REQUIRED`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_ACCESS_TOKEN_REVOKED`
- `AUTH_REFRESH_TOKEN_REQUIRED`, `AUTH_REFRESH_TOKEN_NOT_FOUND`, `AUTH_REFRESH_TOKEN_EXPIRED_OR_REVOKED`
- `AUTH_REFRESH_TOKEN_USER_MISMATCH`, `AUTH_REFRESH_TOKEN_TYPE_INVALID`, `AUTH_ACCESS_TOKEN_TYPE_INVALID`
- `AUTH_LOGOUT_TOKEN_USER_MISMATCH`, `AUTH_AUTHENTICATED_USER_REQUIRED`, `AUTH_USER_NOT_FOUND`, `AUTH_REQUEST_BODY_INVALID`

비-auth 예시:

```json
{
  "status": 409,
  "errorCode": "CONFLICT",
  "message": "Insufficient wallet balance."
}
```

---

## 6. 멱등/조회 제한 규약

- 지갑 충전:
  - Endpoint: `POST /api/users/{userId}/wallet/charges`
  - `idempotencyKey`는 optional이지만, 재시도 안전성을 위해 **클라이언트가 항상 고유값을 넣는 것을 권장**합니다.
- 예약 결제/환불:
  - 서버가 `reservationId` 기반 idempotency key를 내부 생성하여 중복 결제를 방지합니다.
- 거래내역 조회:
  - `GET /api/users/{userId}/wallet/transactions?limit={n}`
  - 기본 `20`, 최대 `100`
