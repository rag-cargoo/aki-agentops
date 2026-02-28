# Meeting Notes: Service Card Server-Time Realtime WS Alignment (ticket-web-app)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-28 06:10:00`
> - **Updated At**: `2026-02-28 07:08:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 현상 점검(현재 구현/갭)
> - 안건 2: 서버시간 기준 정렬 원칙
> - 안건 3: 멀티 인스턴스 전파 원칙
> - 안건 4: 실행 태스크/수용 기준
> - 안건 5: 이슈/태스크 동기화
> - 안건 6: 모드 정책 확정(Revision)
> - 안건 7: 실행 체크리스트(Revision)
<!-- DOC_TOC_END -->

## 안건 1: 현상 점검(현재 구현/갭)
- Status: DONE
- 요약:
  - 현재 서비스 카드 경로는 WebSocket 연결은 존재하나, 카드 갱신 이벤트는 `CONCERTS_REFRESH` 중심으로 동작한다.
  - `오픈 남은시간/오픈 카운트다운/오픈 시점 상태 전환`을 서버가 주기 계산해 카드로 push하는 채널은 미구현이다.
  - 좌석/예약/대기열 실시간 이벤트와 카드 시간 상태 실시간 이벤트는 별도 범위로 분리 관리한다.

## 안건 2: 서버시간 기준 정렬 원칙
- Status: DOING
- 결정:
  - 오픈 상태 판정과 카운트다운 기준 시각은 클라이언트 로컬 시간이 아니라 서버 기준 시간으로 고정한다.
  - 카드 실시간 payload에 `serverNow`를 포함해 클라이언트 표시 드리프트를 보정한다.
  - 프론트는 서버가 보낸 상태를 렌더링하고, 로컬 시계는 보조 표시 용도로만 사용한다.

## 안건 3: 멀티 인스턴스 전파 원칙
- Status: DOING
- 결정:
  - 상태 원본은 DB에서 확정하고, 인스턴스 간 이벤트 전파는 Redis/Kafka를 사용한다.
  - 주기 계산 스케줄러는 분산락으로 단일 실행 보장 후 이벤트를 fanout한다.
  - WebSocket은 각 인스턴스가 전파 이벤트를 받아 연결된 클라이언트로 브로드캐스트한다.

## 안건 4: 실행 태스크/수용 기준
- Status: DOING
- 실행 태스크:
  - 서비스 카드 전용 실시간 이벤트 스키마 정의(`concertId`, `status`, `remainingSeats`, `remainingRate`, `openAt`, `openInSeconds`, `serverNow`).
  - 오픈 시각 임박/도달 시점 상태 전환 이벤트 주기 발행.
  - 백엔드 스냅샷 API + WebSocket 실시간 + 장애 시 fallback(저주기 poll) 계약 정렬.
  - 멀티 인스턴스 검증(이벤트 중복/누락/순서)과 런타임 모니터링 항목 추가.
- 진행 업데이트 (2026-02-28):
  - backend 1차 구현 완료:
    - `GET /api/concerts/search` 응답에 카드 실시간 필드(`saleStatus`, `saleOpensAt`, `saleOpensInSeconds`, `reservationButton*`, `seat count`, `serverNow`) 추가
    - 판매 상태 전환 감지 스케줄러(`ConcertSaleStatusScheduler`) 추가
  - backend 2차 정렬(아키텍처 + payload 확장):
    - `/topic/concerts/live` `CONCERTS_REFRESH` payload에 `items`(카드 전체 필드), `realtimeMode`, `hybridPollIntervalMillis`, `serverNow` 포함
    - 아키텍처 규칙 정렬: `application port`(`ConcertCardRuntimeUseCase`) 경유로 controller/global의 `application..service` 직참조 제거
    - `global -> api` 의존 제거를 위해 WS payload 전용 application model(`ConcertLiveCardPayload`) 도입
  - 런타임 검증:
    - 전환 전 `OPEN_SOON_5M` -> 전환 후 `OPEN` 확인
    - 전환 시점 WS `CONCERTS_REFRESH` 수신 확인
  - 테스트 검증:
    - `LayerDependencyArchTest` 통과
    - `WebSocketPushNotifierTest` 통과 (`CONCERTS_REFRESH` payload 필드 검증 포함)
    - `ConcertExplorerIntegrationTest` 통과 (`/api/concerts/search`의 `serverNow/realtimeMode/hybridPollIntervalMillis` 검증 포함)
- 수용 기준:
  - 두 개 이상의 클라이언트에서 동일 `serverNow` 기준으로 카운트다운이 일관되게 표시된다.
  - 오픈 시점 도달 시 카드 상태가 새로고침 없이 실시간 전환된다.
  - 단일 인스턴스/멀티 인스턴스 모두에서 동일 동작을 재현한다.

## 안건 5: 이슈/태스크 동기화
- Status: DONE
- 정책:
  - 동일 범위 후속작업은 기존 이슈 재오픈/코멘트 누적을 기본으로 한다.
  - backend issue(재사용): `https://github.com/rag-cargoo/ticket-core-service/issues/3` (2026-02-28 재오픈 + 코멘트 누적 + 체크리스트 재확정)
  - sidecar task: `prj-docs/projects/ticket-web-app/task.md` (`TWA-SC-013`)

## 안건 6: 모드 정책 확정(Revision)
- Status: DONE
- 확정:
  - 기본 모드(default): `websocket`
  - 선택 모드(optional): `hybrid`
  - 비상 모드(emergency): `polling`
- 모드별 동작:
  - `websocket`: 초기 1회 HTTP 스냅샷 + WS 구독, 상시 폴링 없음
  - `hybrid`: WS 구독 + 저주기 보정 폴링
  - `polling`: WS 미사용, 폴링만 사용
- 운영 원칙:
  - 모드 결정은 백엔드 설정(롤아웃) 기준으로 내리고 프론트는 설정값을 따라 자동 동작한다.
  - "WS 연결되어 있어도 상시 폴링이 도는 상태"는 `websocket` 모드 정의 위반으로 간주한다.

## 안건 7: 실행 체크리스트(Revision)
- Status: DOING
- Backend:
  - [x] `GET /api/concerts/search`에 카드 실시간 필드 + `serverNow` 반영
  - [x] `/api/concerts/search`에 `realtimeMode`, `hybridPollIntervalMillis` 반영
  - [x] 판매 상태 전환 감지 스케줄러 + 분산락 적용
  - [x] 상태 전환 시 `/topic/concerts/live` refresh 이벤트 발행
  - [x] `/topic/concerts/live` payload에 카드 `items` 직접 포함(HTTP 재조회 의존 축소)
  - [x] ArchUnit 경계 준수(`controller/global -> application port`, `global -> api` 제거)
  - [x] 런타임 실측(`OPEN_SOON_5M -> OPEN`, WS refresh 수신) 확인
- Frontend:
  - [ ] `service-card` 모드 분기(`websocket|hybrid|polling`) consume 구현
  - [ ] `websocket` 모드에서 상시 30초 polling 제거
  - [ ] `hybrid` 모드에서만 저주기 polling 사용
  - [ ] `serverNow` 기준 카운트다운 보정 렌더링 적용
  - [ ] 모드별 네트워크 호출/WS 수신 증빙 캡처
