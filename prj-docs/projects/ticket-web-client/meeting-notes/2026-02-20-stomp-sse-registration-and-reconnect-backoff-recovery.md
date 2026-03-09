# Meeting Notes: STOMP/SSE Registration and Reconnect Backoff Recovery (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-20 08:35:00`
> - **Updated At**: `2026-02-20 08:35:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: TWC-SC-014 구현 범위
> - 안건 2: 실시간 전송/등록 API 연동
> - 안건 3: reconnect backoff 정책
> - 안건 4: 검증/이슈/후속 작업
<!-- DOC_TOC_END -->

## 안건 1: TWC-SC-014 구현 범위
- Status: DONE
- 처리결과:
  - 실백엔드 WS 구독 등록/해제 API 클라이언트를 추가했다.
  - STOMP websocket transport를 추가하고 destination subscribe를 지원한다.
  - SSE transport를 명시 이벤트 수신(`INIT/RANK_UPDATE/ACTIVE/KEEPALIVE/RESERVATION_STATUS`) 가능하게 확장했다.

## 안건 2: 실시간 전송/등록 API 연동
- Status: DONE
- 처리결과:
  - websocket 모드 연결 시 다음 순서를 수행한다.
    - `POST /api/push/websocket/waiting-queue/subscriptions`
    - (선택) `POST /api/push/websocket/reservations/subscriptions`
    - STOMP `/ws` 연결 + 등록된 destination subscribe
  - disconnect/unmount/reconnect 시 구독 해제 API를 호출한다.
    - `DELETE /api/push/websocket/waiting-queue/subscriptions`
    - `DELETE /api/push/websocket/reservations/subscriptions`

## 안건 3: reconnect backoff 정책
- Status: DONE
- 처리결과:
  - transport 오류 시 지수 backoff 재연결 스케줄링을 적용했다.
  - 기본값:
    - max attempts: 5
    - base delay: 1000ms
    - max delay: 15000ms
  - UI 메타(`attempt`, `next delay`, `reason`)를 노출해 상태를 즉시 확인 가능하게 했다.

## 안건 4: 검증/이슈/후속 작업
- Status: DONE
- 검증:
  - `typecheck` PASS
  - `build` PASS
  - `e2e:realtime` PASS
  - `e2e:all` PASS
  - wrapper `realtime` PASS
  - wrapper `all` PASS
- 증빙:
  - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-083058-3768649/summary.txt`
  - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-083058-3768649/run.log`
  - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-083143-3770214/summary.txt`
  - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-083143-3770214/run.log`
- 이슈:
  - `ticket-web-client#5`: `https://github.com/rag-cargoo/ticket-web-client/issues/5`
  - `Issue Progress Comment`: `https://github.com/rag-cargoo/ticket-web-client/issues/5#issuecomment-3930734644`
- Next:
  - `TWC-SC-015` 실백엔드 OAuth+Queue+Realtime 통합 스모크 런북/자동화 시나리오 정리
