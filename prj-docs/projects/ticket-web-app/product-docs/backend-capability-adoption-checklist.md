# Backend Capability Adoption Checklist (ticket-web-app)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-25 03:05:00`
> - **Updated At**: `2026-02-25 06:22:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Purpose
> - Decision Codes
> - Implementation Status Codes
> - Front Capability Matrix
> - Backend-Only / System Matrix
> - Open Gaps (Must Fix)
> - Operating Rules
> - Change Trigger Checklist
<!-- DOC_TOC_END -->

## Purpose
- 목적: 백엔드 기능을 프론트에 기계적으로 복제하지 않고, 사용자 가치/운영리스크 기준으로 채택 범위를 통제한다.
- 기본 원칙:
  - `백엔드에 구현됨 != 프론트 즉시 반영`
  - `ADOPT_NOW` 항목은 실제 코드/검증 증빙이 없으면 DONE으로 표기하지 않는다.

## Decision Codes
- `ADOPT_NOW`: 현재 스프린트에서 프론트 반영
- `ADOPT_LATER`: 후속 반영
- `BACKEND_ONLY`: 사용자 UI 미노출(시스템 연동)
- `LEGACY_SKIP`: 신규 프론트 미적용(구버전/호환 경로)

## Implementation Status Codes
- `DONE`: 코드 반영 + 검증 경로 확인
- `DOING`: 일부 반영, 핵심 시나리오 미완료
- `TODO`: 설계만 있고 구현 시작 전
- `BLOCKED`: 백엔드 계약/런타임 이슈로 진행 차단
- `RISK`: 동작은 하나 계약 드리프트로 회귀 위험 존재

## Front Capability Matrix
| ID | Capability | Backend Contract | Decision | Status | Current Assessment | Evidence |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| AUTH-01 | 소셜 로그인 시작/교환 | `GET /api/auth/social/{provider}/authorize-url`, `POST /api/auth/social/{provider}/exchange` | ADOPT_NOW | DONE | 로그인 모달 + 콜백 교환 동작 | `src/App.tsx`, `src/shared/api/auth-session-client.ts` |
| AUTH-02 | 세션 조회/로그아웃 | `GET /api/auth/me`, `POST /api/auth/logout` | ADOPT_NOW | DONE | 헤더 프로필 메뉴와 연동 | `src/components/HeaderNav.tsx`, `src/App.tsx` |
| AUTH-03 | 토큰 갱신 자동화 | `POST /api/auth/token/refresh` | ADOPT_NOW | DOING | 초기 복원 시 refresh 처리만 있음. 요청 인터셉터형 자동화는 미완 | `src/App.tsx` |
| CAT-01 | 공연/회차/좌석 조회 | `/api/concerts/search`, `/{id}/options`, `/options/{optionId}/seats` | ADOPT_NOW | DOING | 조회는 구현됐으나 `search` 런타임 500 케이스 존재 | `src/shared/api/admin-concert-client.ts`, `src/shared/api/run-reservation-v7-flow.ts` |
| CAT-02 | 판매상태/버튼 제어 필드 사용 | `saleStatus`, `saleOpensAt`, `reservationButton*`, `availableSeatCount` | ADOPT_NOW | RISK | 프론트가 해당 필드를 사용하지만 백엔드 DTO 명시와 드리프트 가능성 존재 | `src/shared/api/admin-concert-client.ts`, `src/pages/ServicePage.tsx` |
| RSV-01 | v7 전이 체인 | `/api/reservations/v7/holds -> /paying -> /confirm` | ADOPT_NOW | DONE | 자동 체인 실행 구현됨 | `src/shared/api/run-reservation-v7-flow.ts`, `src/pages/ServicePage.tsx` |
| RSV-02 | confirm 결과 메타 표시 | `paymentMethod/paymentProvider/paymentStatus` | ADOPT_NOW | DONE | 카드 메시지에서 메타 노출 | `src/pages/ServicePage.tsx` |
| RSV-03 | confirm 후속 액션 분기 | `paymentAction/paymentRedirectUrl` | ADOPT_NOW | DOING | REDIRECT 처리 있음. WAIT_WEBHOOK/RETRY_CONFIRM UX는 제한적 | `src/pages/ServicePage.tsx`, `src/pages/service/ServiceCheckoutModal.tsx` |
| RSV-04 | 좌석 soft-lock | `POST|DELETE /api/reservations/v7/locks/seats/{seatId}` | ADOPT_NOW | DOING | 모달에서 hold 직전 lock 획득/실패시 해제 반영. 선택 시점 lock 유지 전략은 후속 | `src/pages/service/ServiceCheckoutModal.tsx`, `src/shared/api/run-reservation-v7-flow.ts` |
| PAY-01 | 결제수단 카탈로그 기반 UI | `GET /api/payments/methods` | ADOPT_NOW | DOING | Account/Checkout에서 조회하나 실패 시 WALLET fallback이 남아있음 | `src/shared/api/payment-methods-client.ts`, `src/pages/AccountPage.tsx`, `src/pages/service/ServiceCheckoutModal.tsx` |
| PAY-02 | wallet 잔액/원장 조회 | `/api/users/{userId}/wallet/**` | ADOPT_NOW | DONE | 계정 페이지에 분리 구현 | `src/pages/AccountPage.tsx`, `src/shared/api/wallet-client.ts` |
| PAY-03 | pg-ready 결제 흐름 | `provider=pg-ready`, `paymentAction=REDIRECT|WAIT_WEBHOOK` | ADOPT_NOW | DOING | REDIRECT 오픈은 구현. webhook 대기/재조회 UX 보강 필요 | `src/pages/ServicePage.tsx`, `src/pages/service/ServiceCheckoutModal.tsx` |
| UX-01 | 메인-계정 정보구조 분리 | 서비스 메인은 탐색/예매, 결제/내역은 프로필 메뉴 진입 | ADOPT_NOW | DOING | 프로필 메뉴 분리는 적용. 서비스 메인 자동예매 체인이 남아 개선 필요 | `src/components/HeaderNav.tsx`, `src/pages/ServicePage.tsx` |
| RT-01 | WS 구독 등록 API 연동 | `/api/push/websocket/**/subscriptions` | ADOPT_NOW | TODO | 신규 앱에서 아직 미채택 | `backend-contract-inventory.md` |
| RT-02 | STOMP seat-map 실시간 반영 | `/ws`, `/topic/seats/{optionId}` | ADOPT_NOW | TODO | 좌석 상태 push 병합 미구현 | `backend-contract-inventory.md` |
| QUEUE-01 | SSE/WS 대기열 상태 병합 | `/api/v1/waiting-queue/**` + realtime | ADOPT_LATER | TODO | 우선순위 후순위 | `frontend-implementation-blueprint.md` |
| ADMIN-01 | Admin Concert CRUD | `/api/admin/concerts/**` | ADOPT_NOW | DOING | 기본 CRUD/옵션/썸네일 반영 중 | `src/pages/AdminPage.tsx`, `src/shared/api/admin-concert-client.ts` |
| ADMIN-02 | Sales Policy 실필드 | `maxReservationsPerUser` 중심 | ADOPT_NOW | DONE | 폼 단순화 반영 | `src/pages/AdminPage.tsx` |
| AUDIT-01 | 예약 감사 조회(Admin) | `/api/reservations/v7/audit/**` | ADOPT_LATER | TODO | 운영 대시보드 후속 | `frontend-implementation-blueprint.md` |
| LEGACY-01 | v1~v6 예약 경로 | `/api/reservations/v1..v6/**` | LEGACY_SKIP | DONE | 신규 서비스 UX에서 미사용 유지 | `frontend-implementation-blueprint.md` |

## Backend-Only / System Matrix
| ID | Capability | Backend Contract | Decision | Reason |
| :--- | :--- | :--- | :--- | :--- |
| BO-01 | PG webhook 승인 처리 | `POST /api/payments/webhooks/pg-ready` | BACKEND_ONLY | PG 서버 -> 백엔드 시스템 연동 |
| BO-02 | OAuth callback 종착 | `/login/oauth2/code/{provider}` | BACKEND_ONLY | 사용자 직접 접근 화면이 아님 |
| BO-03 | mock payment provider | `app.payment.provider=mock` | BACKEND_ONLY | 개발/시뮬레이션 용도 |
| BO-04 | setup/cleanup test endpoint | `/api/concerts/setup`, `/api/concerts/cleanup/**` | BACKEND_ONLY | 운영 사용자 플로우 아님 |
| BO-05 | Kafka push fanout 내부경로 | `KafkaPushEventProducer/Consumer` | BACKEND_ONLY | 인프라 이벤트 전파 레이어 |

## Open Gaps (Must Fix)
- GAP-01: 모달 결과 상태 병합 고도화
  - 성공 결과는 반영되지만 `running/cancelled` 상태 동기화 UX는 단순 상태
- GAP-02: soft-lock 전략 고도화
  - 현재는 hold 직전 lock 방식
  - 목표는 좌석 선택 시점 lock + 모달 종료/좌석변경 해제까지 일관화
- GAP-03: payment methods 실패 시 WALLET fallback
  - `provider=pg-ready` 환경과 충돌 가능
- GAP-04: `GET /api/concerts/search` 런타임 안정성
  - 500(SQL `lower(bytea)`) 재현됨
  - 목록 API 안정화 또는 프론트 fallback 전략 필요

## Operating Rules
- 새 백엔드 기능 반영 절차:
  1. 이 문서에 항목 등록
  2. `Decision` 지정
  3. `Status` 지정
  4. 근거 파일/검증 기록 연결
- 금지:
  - 증빙 없는 DONE 마킹
  - 계약 미확인 하드코딩 fallback으로 기능 성공 처리

## Change Trigger Checklist
- 아래 변경 시 즉시 업데이트:
  - 백엔드 컨트롤러 시그니처/권한 변경
  - 결제 provider/method/status/paymentAction 계약 변경
  - 예약 상태머신/soft-lock 정책 변경
  - 프론트 IA(서비스/계정/관리자 경계) 변경
