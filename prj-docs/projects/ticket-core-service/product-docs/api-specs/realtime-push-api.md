# Realtime Push API (SSE/WebSocket)

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
> - 1. 전송 모드 개요
> - 2. SSE 구독 API
> - 3. WebSocket(STOMP) 연결/구독 규약
> - 4. WebSocket 구독 등록/해제 REST API
> - 5. 이벤트 페이로드 계약
<!-- DOC_TOC_END -->

## Source
- SoT: `AKI AgentOps sidecar` (`prj-docs/projects/ticket-core-service/product-docs/**`)

## Publication Policy
- 이 문서는 GitHub Pages 사용자 탐색용 공식 문서다.
- 변경은 `rag-cargoo/aki-agentops` sidecar PR에서 관리한다.

## Content

실시간 예약/대기열 이벤트는 SSE와 WebSocket(STOMP) 2가지 채널을 지원합니다.

---

## 1. 전송 모드 개요

설정값:
- `APP_PUSH_MODE=sse|websocket`
- 기본값: `websocket`

모드별 사용 경로:

| Mode | 수신 채널 | 프론트 권장 사용 |
| :--- | :--- | :--- |
| `sse` | HTTP SSE stream | 단일 탭/단순 수신 |
| `websocket` | STOMP topic subscribe | 다중 구독/양방향 확장 대비 |

---

## 2. SSE 구독 API

### 2.1 Waiting Queue SSE
- **Endpoint**: `GET /api/v1/waiting-queue/subscribe?userId={userId}&concertId={concertId}`
- **Content-Type**: `text/event-stream`
- **Event**: `INIT`, `RANK_UPDATE`, `ACTIVE`, `KEEPALIVE`

### 2.2 Reservation SSE
- **Endpoint**: `GET /api/reservations/v5/subscribe?userId={userId}&seatId={seatId}`
- **Content-Type**: `text/event-stream`
- **Event**: `RESERVATION_STATUS` (예: `SUCCESS`, `FAIL`)

---

## 3. WebSocket(STOMP) 연결/구독 규약

Handshake endpoint:
- `GET /ws` (STOMP over WebSocket)

Broker/topic:
- Waiting Queue topic: `/topic/waiting-queue/{concertId}/{userId}`
- Reservation topic: `/topic/reservations/{seatId}/{userId}`

프론트 예시 순서:
1. `/api/push/websocket/.../subscriptions`로 구독 등록
2. STOMP client로 `/ws` 연결
3. 위 topic destination subscribe
4. 화면 이탈 시 unsubscribe + 구독 해제 API 호출

---

## 4. WebSocket 구독 등록/해제 REST API

Base: `/api/push/websocket`

### 4.1 대기열 구독 등록
- **Endpoint**: `POST /api/push/websocket/waiting-queue/subscriptions`

**Request**

```json
{
  "userId": 100,
  "concertId": 1
}
```

**Response (200)**

```json
{
  "transport": "websocket",
  "destination": "/topic/waiting-queue/1/100"
}
```

### 4.2 대기열 구독 해제
- **Endpoint**: `DELETE /api/push/websocket/waiting-queue/subscriptions?userId={userId}&concertId={concertId}`
- **Response**: `204 No Content`

### 4.3 예약 구독 등록
- **Endpoint**: `POST /api/push/websocket/reservations/subscriptions`

**Request**

```json
{
  "userId": 100,
  "seatId": 55
}
```

**Response (200)**

```json
{
  "transport": "websocket",
  "destination": "/topic/reservations/55/100"
}
```

### 4.4 예약 구독 해제
- **Endpoint**: `DELETE /api/push/websocket/reservations/subscriptions?userId={userId}&seatId={seatId}`
- **Response**: `204 No Content`

---

## 5. 이벤트 페이로드 계약

### 5.1 Waiting Queue (WebSocket payload)

```json
{
  "event": "RANK_UPDATE",
  "userId": 100,
  "concertId": 1,
  "data": {
    "userId": 100,
    "concertId": 1,
    "status": "WAITING",
    "rank": 12,
    "activeTtlSeconds": 0,
    "timestamp": "2026-02-19T01:20:10.224Z"
  }
}
```

`event` 가능 값:
- `RANK_UPDATE`
- `ACTIVE`
- `KEEPALIVE`

### 5.2 Reservation (WebSocket payload)

```json
{
  "event": "RESERVATION_STATUS",
  "userId": 100,
  "seatId": 55,
  "status": "SUCCESS",
  "timestamp": "2026-02-19T01:21:00.000Z"
}
```

`status` 가능 값:
- `SUCCESS`
- `FAIL`

관련 검증 스크립트:
- `scripts/api/v13-websocket-switching.sh`
