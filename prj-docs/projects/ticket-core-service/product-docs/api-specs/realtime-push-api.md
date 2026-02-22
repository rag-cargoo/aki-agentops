# Realtime Push API (SSE/WebSocket)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 00:15:00`
> - **Updated At**: `2026-02-22 11:45:00`
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
> - 6. 장애/폴백 운영 Runbook (WS->SSE + DB 재동기화)
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

---

## 6. 장애/폴백 운영 Runbook (WS->SSE + DB 재동기화)

### 6.1 전제
- 기준 운영 모드: `APP_PUSH_MODE=websocket`
- fallback 모드: `APP_PUSH_MODE=sse`
- soft lock key: `seat:lock:{optionId}:{seatId}`
- 좌석 상태 표준: `AVAILABLE -> SELECTING -> HOLD -> CONFIRMED`

### 6.2 WebSocket 장애 감지 기준
- WebSocket broker 연결 실패/재시도 급증
- STOMP subscribe 성공률 저하
- 동일 `optionId` 좌석맵 이벤트 지연/누락 징후

### 6.3 즉시 완화(WS -> SSE)
1. 운영 환경 변수 `APP_PUSH_MODE=sse`로 전환하고 앱 인스턴스를 순차 재기동한다.
2. 대기열 구독은 `GET /api/v1/waiting-queue/subscribe`로 유지한다.
3. 예약 결과 구독은 `GET /api/reservations/v5/subscribe`로 유지한다.
4. WebSocket 구독 등록/해제 API(`/api/push/websocket/**`)는 폴백 기간 동안 신규 호출을 중단한다.
5. 장애 해소 후 `APP_PUSH_MODE=websocket`로 복귀하고 STOMP 구독을 재등록한다.

### 6.4 DB 기준 좌석 재동기화(운영 수동 절차)
재동기화 기준 원장은 Redis가 아니라 DB(`seats`, `reservations`)다.

1. 대상 공연 옵션(`optionId`)을 확정한다.
2. 아래 SQL로 좌석별 최신 상태 스냅샷을 추출한다.

```sql
WITH latest_reservation AS (
  SELECT r.*,
         ROW_NUMBER() OVER (PARTITION BY r.seat_id ORDER BY r.id DESC) AS rn
  FROM reservations r
  WHERE r.status IN ('HOLD', 'PAYING', 'CONFIRMED')
)
SELECT s.id                                  AS seat_id,
       s.concert_option_id                    AS option_id,
       s.status                               AS seat_status,
       lr.user_id                             AS owner_user_id,
       lr.status                              AS reservation_status,
       lr.hold_expires_at                     AS hold_expires_at
FROM seats s
LEFT JOIN latest_reservation lr
  ON lr.seat_id = s.id
 AND lr.rn = 1
WHERE s.concert_option_id = :option_id
ORDER BY s.id;
```

3. Redis soft lock 키(`seat:lock:{optionId}:*`)를 함께 확인해 `SELECTING` 상태를 우선 판정한다.
4. 상태 매핑 규칙:
   - Redis soft lock 존재: `SELECTING`
   - `reservation_status IN ('HOLD','PAYING')` 또는 `seat_status='TEMP_RESERVED'`: `HOLD`
   - `reservation_status='CONFIRMED'` 또는 `seat_status='RESERVED'`: `CONFIRMED`
   - 그 외: `AVAILABLE`
5. 매핑 결과를 좌석맵 이벤트(`AVAILABLE/SELECTING/HOLD/CONFIRMED/RELEASED`)로 재발행해 화면을 수렴시킨다.
6. 재동기화 이후 API 조회(`GET /api/concerts/options/{optionId}/seats`)와 화면 상태 일치를 샘플 검증한다.

### 6.5 재동기화 완료 판정
- 샘플 좌석 집합에서 DB 상태와 프론트 상태가 동일하다.
- WebSocket 복귀 후 이벤트 누락 없이 상태 전이가 지속된다.
