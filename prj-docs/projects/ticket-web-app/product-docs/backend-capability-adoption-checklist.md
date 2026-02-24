# Backend Capability Adoption Checklist (ticket-web-app)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-25 03:05:00`
> - **Updated At**: `2026-02-25 03:05:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Purpose
> - Decision Codes
> - Front Capability Matrix
> - Backend-Only Matrix
> - Operating Rules
> - Change Trigger Checklist
<!-- DOC_TOC_END -->

## Purpose
- 목적: 백엔드 구현 항목을 프론트에 그대로 복제하지 않고, 항목별 `채택/보류/제외` 결정을 명시해 구현 범위를 통제한다.
- 원칙:
  - `백엔드에 있음 = 프론트 구현`이 아니다.
  - 테스트/운영/내부 연동용 기능은 프론트 사용자 화면에서 제외할 수 있다.
  - 프론트 구현은 사용자 가치/운영 리스크/릴리즈 범위를 기준으로 채택한다.

## Decision Codes
- `ADOPT_NOW`: 현재 스프린트에 프론트 반영
- `ADOPT_LATER`: 백엔드 준비는 되어 있으나 프론트는 후속 반영
- `BACKEND_ONLY`: 프론트 화면 미노출(서버 내부/시스템 연동용)
- `LEGACY_SKIP`: 구버전/호환 레이어로 신규 프론트에 미적용

## Front Capability Matrix
| ID | Capability | Backend Contract | Decision | Front Scope | Status | Evidence |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| AUTH-01 | 소셜 로그인 시작/교환 | `GET /api/auth/social/{provider}/authorize-url`, `POST /api/auth/social/{provider}/exchange` | ADOPT_NOW | 로그인 모달/세션 획득 | DONE | `src/components/HeaderNav.tsx`, `src/shared/api/auth-session-client.ts` |
| AUTH-02 | 세션 조회/로그아웃 | `GET /api/auth/me`, `POST /api/auth/logout` | ADOPT_NOW | 헤더 프로필/로그아웃 | DONE | `src/components/HeaderNav.tsx` |
| AUTH-03 | Access refresh 처리 | `POST /api/auth/token/refresh` | ADOPT_LATER | 자동 재발급 인터셉터 | TODO | `backend-contract-inventory.md` |
| CAT-01 | 공연 목록/회차/좌석 조회 | `/api/concerts/search`, `/{id}/options`, `/options/{optionId}/seats` | ADOPT_NOW | Service 목록/예매 실행 | DONE | `src/shared/api/admin-concert-client.ts`, `src/shared/api/run-reservation-v7-flow.ts` |
| CAT-02 | 판매상태 분기/카운트다운 | `saleStatus`, `saleOpensAt`, `saleOpensInSeconds` | ADOPT_NOW | `예매 가능/오픈 대기/기타` 섹션 | DONE | `src/pages/ServicePage.tsx` |
| RSV-01 | 예약 상태머신(v7) | `/api/reservations/v7/holds|paying|confirm|cancel|refund|me` | ADOPT_NOW | 실예약/내예약 관리 | DONE | `src/shared/api/run-reservation-v7-flow.ts`, `src/shared/api/reservation-v7-client.ts` |
| RSV-02 | confirm 결과 결제 메타 | `paymentMethod/paymentProvider/paymentStatus/paymentTransactionId` | ADOPT_NOW | 결과 메시지/실패 복구 | DONE | `src/pages/ServicePage.tsx` |
| RSV-03 | confirm 후속 액션 | `paymentAction/paymentRedirectUrl` | ADOPT_NOW | 외부결제 진입/대기 안내 | DONE | `src/pages/ServicePage.tsx` |
| RSV-04 | 좌석 soft lock(v7) | `POST|DELETE /api/reservations/v7/locks/seats/{seatId}` | ADOPT_LATER | 좌석 선택 UX 안정화 | TODO | `frontend-implementation-blueprint.md` |
| PAY-01 | 결제수단 상태 조회 | `GET /api/payments/methods` | ADOPT_NOW | 결제수단 선택/비활성 표시 | DONE | `src/shared/api/payment-methods-client.ts`, `src/pages/ServicePage.tsx` |
| PAY-02 | 지갑 잔액/충전/거래 | `/api/users/{userId}/wallet/**` | ADOPT_NOW | 잔액 부족 복구 플로우 | DONE | `src/shared/api/wallet-client.ts`, `src/pages/ServicePage.tsx` |
| PAY-03 | 외부결제(PG) 사용자 플로우 | `provider=pg-ready`, `paymentAction=REDIRECT` | ADOPT_NOW | 자동 팝업 + 수동 링크 fallback | DONE | `src/pages/ServicePage.tsx` |
| RT-01 | WS 구독 등록 API | `/api/push/websocket/**` | ADOPT_LATER | 실시간 좌석/예약 반영 | TODO | `frontend-implementation-blueprint.md` |
| QUEUE-01 | 대기열 API(v1/v4/v5) | `/api/v1/waiting-queue/**`, `/api/reservations/v4*/v5*` | ADOPT_LATER | 비로그인 대기열/혼잡 UX | TODO | `backend-contract-inventory.md` |
| ADMIN-01 | Admin Concert CRUD | `/api/admin/concerts/**` | ADOPT_NOW | Admin 콘서트 관리 화면 | DOING | `src/pages/AdminPage.tsx` |
| ADMIN-02 | Sales Policy 실필드 | `maxReservationsPerUser` 중심 정책 필드 | ADOPT_NOW | Admin 정책 입력 단순화 | DONE | `src/pages/AdminPage.tsx` |
| AUDIT-01 | 감사 로그 조회(Admin) | `/api/reservations/v7/audit/**` | ADOPT_LATER | 운영 감사 대시보드 | TODO | `frontend-implementation-blueprint.md` |
| LEGACY-01 | 예약 v1~v6 경로 | `/api/reservations/v1..v6/**` | LEGACY_SKIP | 신규 프론트 미사용 | DONE | `frontend-implementation-blueprint.md` |

## Backend-Only Matrix
| ID | Capability | Backend Contract | Decision | Reason |
| :--- | :--- | :--- | :--- | :--- |
| BO-01 | PG webhook 수신 | `POST /api/payments/webhooks/pg-ready` | BACKEND_ONLY | PG 서버 -> 백엔드 시스템 연동용 |
| BO-02 | OAuth callback 엔드포인트 | `GET /login/oauth2/code/{provider}` | BACKEND_ONLY | 소셜 공급자 redirect 종착점(사용자 UI 아님) |
| BO-03 | 결제 provider `mock` 모드 | `app.payment.provider=mock` | BACKEND_ONLY | 개발/시뮬레이션 용도 |
| BO-04 | 샘플 setup/cleanup | `POST /api/concerts/setup`, `DELETE /api/concerts/cleanup/{concertId}` | BACKEND_ONLY | 개발/검증 편의 경로 |
| BO-05 | 운영/테스트 스크립트 경로 | `scripts/api/**`, auth-social e2e | BACKEND_ONLY | 프론트 제품기능이 아닌 운영 자동화 |

## Operating Rules
- 새 백엔드 기능 추가 시 순서:
  1. 이 문서에 항목 추가
  2. `Decision` 지정 (`ADOPT_NOW/LATER/BACKEND_ONLY/LEGACY_SKIP`)
  3. `task.md`의 관련 SC 항목에 Evidence 연결
- `ADOPT_NOW`는 프론트 PR 머지 전에 `Status=DONE` + 근거 파일 경로를 남긴다.
- `ADOPT_LATER`는 “왜 지금 안 하는지” 한 줄 근거를 남긴다.
- 분류 변경(`LATER -> NOW` 등)은 회의록에 근거를 남기고 task 상태를 갱신한다.

## Change Trigger Checklist
- 아래 변경이 있으면 이 문서를 즉시 갱신한다.
  - 백엔드 컨트롤러 엔드포인트 추가/삭제/권한 변경
  - 결제 provider/method/status 계약 변경
  - 예약 상태머신/정책 필드 변경
  - 프론트 주요 화면의 구현 범위 변경(서비스/Admin)
