# Meeting Notes: Realtime Transport SSE/WS Switching Plan (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-18 22:21:40`
> - **Updated At**: `2026-02-18 22:21:40`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 현재 SSE 사용 구간 재확인
> - 안건 2: SSE 유지 + WebSocket 병행 구조
> - 안건 3: 구현 착수 전 관리 순서
> - 후속작업
<!-- DOC_TOC_END -->

## 안건 1: 현재 SSE 사용 구간 재확인
- Created At: 2026-02-18 22:21:40
- Updated At: 2026-02-18 22:21:40
- Status: DONE
- 결정사항:
  - 현재 `ticket-core-service`에는 예약/대기열 실시간 흐름에 SSE 구간이 존재한다.
  - 기존 SSE 구간은 하위호환을 위해 즉시 제거하지 않고 유지한다.

## 안건 2: SSE 유지 + WebSocket 병행 구조
- Created At: 2026-02-18 22:21:40
- Updated At: 2026-02-18 22:21:40
- Status: DONE
- 결정사항:
  - 전송 채널은 인터페이스(`PushNotifier`)로 추상화하고 구현체를 분리한다.
  - 구현체 명명은 채널이 드러나게 유지한다(예: `SsePushNotifier`, `WebSocketPushNotifier`).
  - 컨트롤러는 채널별 책임 분리를 원칙으로 하며, 기존 SSE 컨트롤러는 유지한다.
  - 설정값(`application*.yaml`)으로 SSE/WS 모드를 스위칭할 수 있게 설계한다.

## 안건 3: 구현 착수 전 관리 순서
- Created At: 2026-02-18 22:21:40
- Updated At: 2026-02-18 22:21:40
- Status: DONE
- 결정사항:
  - 구현 전에 sidecar 회의록/태스크/제품 레포 이슈를 먼저 동기화한다.
  - 제품 레포 구현 트래킹 이슈는 `rag-cargoo/ticket-core-service#3`을 단일 SoT로 사용한다.

## 후속작업
- Created At: 2026-02-18 22:21:40
- Updated At: 2026-02-18 22:21:40
- Action Items:
  - `#3` 이슈 본문을 mode switch 전략 기준으로 정리
  - sidecar `task.md`에 구현 항목(TODO) 등록
  - 구현 재개 시 테스트 스크립트/HTTP 예제를 mode 분리(공통 + 채널별)로 갱신
