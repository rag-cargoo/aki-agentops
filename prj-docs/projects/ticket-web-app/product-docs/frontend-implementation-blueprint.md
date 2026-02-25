# Frontend Implementation Blueprint (ticket-web-app)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-25 01:18:00`
> - **Updated At**: `2026-02-25 06:22:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Product Objective
> - Information Architecture
> - Service UX Contract (Real User)
> - Booking/Payment Flow Spec
> - Realtime Sync Strategy
> - Error & Recovery Matrix
> - Delivery Phases
> - Verification Gates
<!-- DOC_TOC_END -->

## Product Objective
- 목표: 백엔드 상태머신/결제계약을 그대로 반영한 실사용자 중심 예매 UX 구현.
- 핵심 원칙:
  - 메인 페이지는 공연 탐색/선택 중심으로 유지
  - 결제/지갑/내예약은 계정 컨텍스트(`프로필 메뉴 -> /account/*`)로 분리
  - 예매는 반드시 `좌석 선택 -> 홀드 -> 결제수단 선택 -> confirm` 단계를 사용자에게 노출
- 디자인 원칙(요청 반영):
  - 다크 기반 city-pop 톤
  - 카드 과다 사용 금지, 섹션 간 시각적 리듬 우선
  - 핵심 CTA만 강조, 데이터성 패널은 밀도보다 가독성 우선

## Information Architecture
- `/service`
  - 공연 탐색, 필터, 상태 분류(예매 가능/오픈 대기/기타)
  - 공연 카드에서 `예매하기` 클릭 시 checkout modal 진입
- `/account/wallet`
  - 결제수단 상태, 결제 수단 기본값, wallet ledger(백엔드 정책상 노출 필요 시)
- `/account/my-reservations`
  - 내 예약 목록, 상태별 취소/환불 액션
- `/admin/concerts`
  - 콘서트/옵션/판매정책/썸네일 관리
- `/labs`
  - 운영 사용자 비노출 실험/검증 전용

## Service UX Contract (Real User)
- 메인 화면에서 사용자가 즉시 해야 하는 일은 3개로 제한한다.
  - 공연 찾기
  - 예매 모달 열기
  - 예매 진행 상태 확인
- 메인 화면에서 제거/금지:
  - wallet 거래내역 본문 노출
  - 결제수단 설정/정책 안내 패널 고정 노출
  - 개발자 디버그성 지표 노출

## Booking/Payment Flow Spec

### Flow start
1. 사용자가 공연 카드 `예매하기` 클릭
2. `ServiceCheckoutModal` 오픈
3. 모달에서 아래 순서로 진행

### Step 1. 회차/좌석
- API:
  - `GET /api/concerts/{concertId}/options`
  - `GET /api/concerts/options/{optionId}/seats`
- UX:
  - 회차 선택
  - 좌석 목록 + 상태 표시
  - seat status가 `AVAILABLE`이 아니면 선택 차단

### Step 2. 좌석 soft-lock (필수 채택)
- API:
  - `POST /api/reservations/v7/locks/seats/{seatId}`
  - 필요 시 `DELETE /api/reservations/v7/locks/seats/{seatId}`
- UX:
  - 좌석 선택 즉시 selecting 표시
  - 좌석 변경/모달 닫기/unmount 시 soft-lock 해제
  - lock owner mismatch/conflict 메시지 노출

### Step 3. HOLD 생성
- API:
  - `POST /api/reservations/v7/holds`
- UX:
  - hold expires countdown 노출
  - 실패 시 원인(경합/권한/정책 위반) 메시지 + 재시도 버튼

### Step 4. PAYING 전이
- API:
  - `POST /api/reservations/v7/{reservationId}/paying`

### Step 5. CONFIRM
- API:
  - `POST /api/reservations/v7/{reservationId}/confirm`
  - payload: `paymentMethod`
- 결제수단 source of truth:
  - `GET /api/payments/methods`
  - enabled=true 인 수단만 선택 가능

### Step 6. confirm 결과 처리
- `status=CONFIRMED` + `paymentAction=NONE`
  - 예매 완료
- `paymentAction=REDIRECT`
  - 외부 결제창 open
  - 팝업 차단 시 `결제창 열기` fallback 링크 제공
- `paymentAction=WAIT_WEBHOOK`
  - 결제 승인 대기 상태로 전환
  - polling 또는 이벤트 기반으로 상태 재조회
- `paymentAction=RETRY_CONFIRM`
  - 재시도 UX 제공

## Realtime Sync Strategy
- 목표: 좌석/예약/대기열 상태를 push 기반으로 반영하고, 실패 시 안전한 fallback 제공.

### Primary (WS)
- Registration API:
  - `POST /api/push/websocket/waiting-queue/subscriptions`
  - `POST /api/push/websocket/reservations/subscriptions`
  - `POST /api/push/websocket/seats/subscriptions`
- STOMP:
  - endpoint `/ws`
  - queue topic `/topic/waiting-queue/{concertId}/{userId}`
  - reservation topic `/topic/reservations/{seatId}/{userId}`
  - seat-map topic `/topic/seats/{optionId}`

### Fallback (SSE + Poll)
- queue/reservation은 SSE 사용 가능
- seat-map은 SSE 단독 보장이 약하므로 poll fallback 병행
  - 권장: option seat list 3~5초 poll

## Error & Recovery Matrix
- `401/403`
  - 로그인 유도 + 이전 동작 컨텍스트 유지
- `409` hold/soft-lock conflict
  - 다른 좌석 선택 유도
- `409 Insufficient wallet balance`
  - 현재 provider가 wallet일 때만 wallet 복구 가이드 노출
  - provider가 pg-ready면 wallet 복구 가이드 노출 금지
- `paymentAction=WAIT_WEBHOOK`
  - 결제 대기 상태 카드 제공 + 주기적 상태 갱신
- `paymentAction=REDIRECT` + popup blocked
  - 수동 링크 CTA
- `GET /api/payments/methods` 실패
  - 결제 진행 버튼을 fail-open 하지 말고 제한 모드로 전환

## Delivery Phases

### Phase 0. Contract Safety
- 완료 조건:
  - 결제수단/예약/realtime 계약 문서 최신화
  - 런타임 프로파일(`18080`, `8080`) 동작 확인

### Phase 1. Route/IA Stabilization
- `/service`, `/account/*`, `/admin`, `/labs` 역할 고정
- 메인에서 wallet/내역 패널 제거

### Phase 2. Checkout Modal Integration
- 현재 미연결 `ServiceCheckoutModal`를 service card CTA에 연결
- 기존 `runReservationV7Flow` 자동 체인 호출 제거

### Phase 3. Soft-lock + Payment Method Gate
- 좌석 선택 soft-lock 도입
- 결제수단 카탈로그 기반 선택 강제

### Phase 4. Realtime Seat/Reservation Sync
- WS registration + STOMP subscribe
- fallback SSE/poll + reconnect backoff

### Phase 5. Release Hardening
- non-mock smoke:
  - 로그인 -> 좌석선택 -> 홀드 -> 결제수단선택 -> 결제진행 -> 완료/대기
  - 내예약 취소/환불
- 회귀 체크리스트/Playwright 시나리오 갱신

## Verification Gates
- 정적:
  - `npm run lint`
  - `npm run typecheck`
  - `npm run build`
- 계약:
  - `GET /api/payments/methods` 응답 기준 수단 표시 검증
  - v7 전이 체인 요청 순서 검증
  - `paymentAction` 분기 검증
- 실사용:
  - 프로필 메뉴에서 `/account/wallet`, `/account/my-reservations` 접근
  - 서비스 메인에서는 공연 탐색/예매 모달 중심 UX만 노출
