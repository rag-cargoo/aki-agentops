# Realtime Queue/Push Monitoring Guide

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 22:40:00`
> - **Updated At**: `2026-02-23 22:40:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 1. 목적
> - 2. 운영 로그 키
> - 3. Push Snapshot 메트릭 규약
> - 4. 알람 기준(권장)
> - 5. 운영 점검 절차
<!-- DOC_TOC_END -->

## 1. 목적
- 대기열/실시간 전송 구간의 운영 상태를 `로그 키 + 주기 스냅샷`으로 빠르게 파악한다.
- 장애 상황에서 "큐 활성화 문제인지, push fanout 문제인지"를 분리해 본다.

## 2. 운영 로그 키

### `QUEUE_MONITOR`
- 발생 위치: `WaitingQueueScheduler`
- 주요 이벤트:
  - `event=activation` (활성화 배치 실행 결과)
  - `event=rank_refresh` (활성 사용자/대기순번 재전송 결과)
  - `event=activation_lock_miss`, `event=heartbeat_lock_miss` (스케줄러 분산락 미획득)

### `PUSH_MONITOR`
- 발생 위치: `SsePushNotifier`, `WebSocketPushNotifier`, `KafkaWebSocketPushNotifier`
- 주요 이벤트:
  - `event=queue_keepalive` + `fanout=<count>`
- 목적:
  - 채널별(`sse`, `websocket`, `kafka`) keepalive fanout 변동을 즉시 확인

### `PUSH_MONITOR_SNAPSHOT`
- 발생 위치: `PushMonitoringSnapshotScheduler`
- 기본 주기:
  - `app.push.monitor.snapshot-delay-millis` (기본 60000ms)
  - 환경변수: `APP_PUSH_MONITOR_SNAPSHOT_DELAY_MILLIS`
- 예시:
  - `PUSH_MONITOR_SNAPSHOT total=184 metrics={domain=push,transport=websocket,event=queue_activated=53, ...}`

## 3. Push Snapshot 메트릭 규약
- 키 형식:
  - `domain=<push|queue>,transport=<sse|websocket|kafka|scheduler>,event=<name>`
- 대표 이벤트:
  - `domain=push`:
    - `queue_rank_update`
    - `queue_activated`
    - `queue_keepalive`
    - `reservation_status`
    - `seat_map_status`
  - `domain=queue`:
    - `activation_runs`
    - `activation_empty_runs`
    - `activated_users`
    - `active_refresh`
    - `rank_updates`
    - `heartbeat_runs`
    - `activation_lock_miss`
    - `heartbeat_lock_miss`

## 4. 알람 기준(권장)
- 5분 이동합 기준:
  - `activation_lock_miss` 연속 증가: 분산락/스케줄러 경쟁 점검
  - `activation_runs` 대비 `activated_users` 급감: 대기열 소진/데이터 이상 여부 점검
  - `queue_keepalive` fanout 급감: 구독 저장소(Redis) 또는 WS/SSE 연결 상태 점검
  - `queue_rank_update` 장시간 0: 스케줄러/상태 갱신 루프 중단 여부 점검

## 5. 운영 점검 절차
1. `QUEUE_MONITOR`에서 활성화/락 미획득 여부 확인
2. 같은 시간대 `PUSH_MONITOR` fanout 로그로 채널별 전송량 확인
3. `PUSH_MONITOR_SNAPSHOT`의 누적 이벤트 분포 확인
4. 필요 시 `Waiting Queue API` + `Realtime Push API` 계약과 교차 검증
