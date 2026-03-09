# Meeting Notes: SC017 Realtime WS URL Override and Runtime Default Alignment (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-22 21:07:30`
> - **Updated At**: `2026-02-22 21:21:29`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: SC017 후속 배경 및 구현 범위
> - 안건 2: 이슈 라이프사이클 적용(#5 재오픈)
> - 안건 3: TODO 동기화(task/meeting-notes)
> - 안건 4: 구현/검증 계획
<!-- DOC_TOC_END -->

## 안건 1: SC017 후속 배경 및 구현 범위
- Status: DONE
- 처리결과:
  - SC014 후속으로 운영 환경에서 WS endpoint를 명시 오버라이드할 수 있는 경로를 추가한다.
  - `VITE_WS_URL`을 런타임 로직으로 연결하고, `VITE_API_BASE_URL` 절대 URL 기반 자동 유도와 기본 `/ws` fallback 우선순위를 고정한다.
  - 타입 선언(`vite-env.d.ts`)과 운영 샘플(`.env.example`), README 환경 가이드를 동기화한다.

## 안건 2: 이슈 라이프사이클 적용(#5 재오픈)
- Status: DONE
- 처리결과:
  - 기존 `ticket-web-client#5`를 재오픈하고 후속 범위를 코멘트로 누적했다.
  - 신규 이슈 생성 대신 재오픈을 선택한 근거:
    - 기존 #5 범위(`STOMP/SSE registration + reconnect backoff`)와 동일 축(실시간 연결 안정화/운영 기본값 정렬) 후속 작업이기 때문.
- 링크:
  - 이슈: `https://github.com/rag-cargoo/ticket-web-client/issues/5`
  - 후속 코멘트: `https://github.com/rag-cargoo/ticket-web-client/issues/5#issuecomment-3940815000`

## 안건 3: TODO 동기화(task/meeting-notes)
- Status: DONE
- 처리결과:
  - sidecar task에 `TWC-SC-017` 항목을 추가하고, 완료 상태(`DONE`)까지 반영했다.
  - meeting notes index와 sidebar manifest에 신규 회의록 링크를 추가해 탐색 경로를 갱신했다.

## 안건 4: 구현/검증 계획
- Status: DONE
- 구현 결과:
  - `resolveRealtimeWebSocketUrl(apiBaseUrl, wsUrlOverride)`로 확장해 `VITE_WS_URL` 우선 해석을 반영했다.
  - `VITE_WS_URL`은 `ws(s)://`, `http(s)://`, 상대 경로(`/ws`) 입력을 모두 지원한다.
  - route 분리 이후 realtime 회귀 안정화를 위해 e2e probe 모드에서 홈 화면에서도 `My Reservations` 패널을 노출했다.
  - 타입 선언/샘플 env/README를 구현과 동일하게 갱신했다.
- 검증 결과:
  - `npm run typecheck` PASS
  - `npm run build` PASS
  - `npm run e2e:realtime` PASS
  - wrapper `--scope realtime` PASS
- 증빙:
  - `.codex/tmp/frontend-playwright/ticket-web-client/20260222-211839-251775/summary.txt`
  - `.codex/tmp/frontend-playwright/ticket-web-client/20260222-211839-251775/run.log`
  - `Issue Progress Comment`: `https://github.com/rag-cargoo/ticket-web-client/issues/5#issuecomment-3940840813`
