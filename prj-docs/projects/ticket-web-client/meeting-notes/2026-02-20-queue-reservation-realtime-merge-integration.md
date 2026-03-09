# Meeting Notes: Queue/Reservation Realtime Merge Integration (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-20 08:12:00`
> - **Updated At**: `2026-02-20 08:12:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: TWC-SC-013 구현 범위
> - 안건 2: Queue/Reservation 실시간 병합 규칙
> - 안건 3: Playwright 검증 결과
> - 안건 4: 이슈/후속 작업
<!-- DOC_TOC_END -->

## 안건 1: TWC-SC-013 구현 범위
- Status: DONE
- 처리결과:
  - 실시간 도메인 이벤트 파서(`queue`, `reservation`)를 추가했다.
  - Queue 섹션에 실시간 연결 컨트롤(`userId`, `concertId`, connect/disconnect)을 추가했다.
  - Queue 카드와 My Reservations 상태를 실시간 이벤트로 병합 반영하도록 UI 상태 흐름을 확장했다.

## 안건 2: Queue/Reservation 실시간 병합 규칙
- Status: DONE
- 처리결과:
  - Queue:
    - `RANK_UPDATE`/`ACTIVE` 이벤트를 카드 단위 실시간 상태로 저장한다.
    - `WAITING/REJECTED`는 예매 버튼 비활성, `ACTIVE`는 예매 버튼 활성으로 병합한다.
  - Reservation:
    - `RESERVATION_STATUS`를 lifecycle 상태로 정규화해 카드 상태를 즉시 갱신한다.
    - 정규화 규칙:
      - `SUCCESS -> CONFIRMED`
      - `FAIL -> EXPIRED`

## 안건 3: Playwright 검증 결과
- Status: DONE
- 처리결과:
  - 신규/확장 테스트:
    - `@realtime queue and reservation states merge with realtime events`
  - 실행 결과:
    - `typecheck` PASS
    - `build` PASS
    - `e2e:realtime` PASS
    - `e2e:all` PASS
    - wrapper `realtime` PASS
    - wrapper `all` PASS
  - 증빙:
    - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-080810-3734962/summary.txt`
    - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-080810-3734962/run.log`
    - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-080834-3735805/summary.txt`
    - `.codex/tmp/frontend-playwright/ticket-web-client/20260220-080834-3735805/run.log`

## 안건 4: 이슈/후속 작업
- Status: DONE
- 이슈:
  - `ticket-web-client#4`: `https://github.com/rag-cargoo/ticket-web-client/issues/4`
  - `Issue Progress Comment`: `https://github.com/rag-cargoo/ticket-web-client/issues/4#issuecomment-3930665171`
- Next:
  - `TWC-SC-014` 실백엔드 STOMP/SSE 등록 API 연동 + 재연결(backoff) 복구 고도화
