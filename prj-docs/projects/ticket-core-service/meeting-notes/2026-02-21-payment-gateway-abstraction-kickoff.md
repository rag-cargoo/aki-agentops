# Meeting Notes: Payment Gateway Abstraction Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-21 04:55:00`
> - **Updated At**: `2026-02-21 06:30:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 전환 배경
> - 안건 2: 결제/예약 책임 경계
> - 안건 3: 상태전이 표준안
> - 안건 4: 단계별 이행 계획
> - 안건 5: 이슈/브랜치 운영 규칙
> - 기준 로직 처리 흐름
> - 진행현황: 완료/남은 항목
> - 결정 대기 항목
<!-- DOC_TOC_END -->

## 안건 1: 전환 배경
- Status: AGREED
- 문제정의:
  - 현재 구현은 wallet(선충전) 모델에 결합되어 있어, 일반 PG 체크아웃 중심 UX(좌석 홀드 후 결제)와 정책이 충돌한다.
  - 프론트/예약 서비스가 결제 수단 내부 구현을 알 필요가 없는 구조로 분리되어야 한다.
- 결정사항:
  - 예약 도메인은 결제 제공자 세부 구현에서 분리한다.
  - 결제 수단은 adapter 교체 가능 구조로 재구성한다.

## 안건 2: 결제/예약 책임 경계
- Status: AGREED
- 결정사항:
  - 예약 서비스는 `PaymentGateway` 포트에만 의존한다.
  - 구현체는 `WalletGateway`, `MockGateway`, `PgGateway`를 교체 가능하게 둔다.
  - 좌석 만료/해제 권한은 백엔드만 가진다.
  - 프론트는 `holdExpiresAt`를 받아 카운트다운을 표시만 하고, 만료 확정은 백엔드 이벤트/응답으로 반영한다.

## 안건 3: 상태전이 표준안
- Status: AGREED
- 표준 흐름:
  - `HOLD` 생성(좌석 TEMP_RESERVED, holdExpiresAt 발급)
  - 결제 승인 성공 시 `CONFIRMED` + 좌석 `RESERVED`
  - 결제 실패 시 `PAYING/HOLD` 유지(재시도 가능)
  - TTL 만료 시 백엔드가 `EXPIRED` + 좌석 `AVAILABLE`
  - 사용자 취소 시 `CANCELLED` + 좌석 `AVAILABLE`
- 정책 규칙:
  - 결제 실패 즉시 자동 만료는 기본 정책에서 제외한다.
  - 환불은 시간 기반 cutoff 정책을 명시적으로 도입한다.

## 안건 4: 단계별 이행 계획
- Status: PLANNED
- Workstream:
  1. `PaymentGateway` 포트 및 도메인 계약 정의
  2. 기존 wallet 결제 로직을 gateway adapter로 이관
  3. mock gateway 도입(개발/테스트용)
  4. pg-ready adapter 및 webhook 계약 골격 추가
  5. API 계약 갱신 + 프론트 카운트다운/상태 메시지 정렬
  6. 마이그레이션 테스트/롤백 전략 정착

## 안건 5: 이슈/브랜치 운영 규칙
- Status: IN_PROGRESS
- 이슈:
  - 기존 결제 이슈 재오픈: `rag-cargoo/ticket-core-service#5`
  - 외부 이슈 추적: `rag-cargoo/ticket-core-service issue 5`
- 운영결정:
  - 구현은 각 서비스 레포의 최신 `main` 동기화 후 신규 브랜치에서 진행한다.
  - 문서 PR(본 회의록) 머지 이후 backend/frontend 구현 브랜치로 분리 착수한다.
  - Redis/Kafka/락/대기열 성능개선 축은 유지하며 결제 도메인만 점진 교체한다.

## 기준 로직 처리 흐름
- Status: AGREED
- 결제/예약 기준 흐름:
  1. 사용자 좌석 선택 후 `예매하기` 클릭
  2. 백엔드가 좌석 `HOLD` 생성(`holdExpiresAt` 발급, 좌석 `TEMP_RESERVED`)
  3. 프론트는 `holdExpiresAt` 기반 카운트다운 표시(표시 전용)
  4. 결제 승인 성공 시 `CONFIRMED` + 좌석 `RESERVED`
  5. 결제 실패 시 `PAYING/HOLD` 유지(제한시간 내 재시도 허용)
  6. TTL 만료 시 백엔드가 `EXPIRED` + 좌석 `AVAILABLE` 자동 해제
  7. 사용자 취소 시 `CANCELLED` + 좌석 해제
  8. 환불은 cutoff 정책 충족 시만 허용
- 책임 경계:
  - 프론트: 카운트다운/상태 표시
  - 백엔드: 만료 판정, 상태 전이, 좌석 해제, 환불 정책 강제

## 진행현황: 완료/남은 항목
- Status: IN_PROGRESS
- 완료된 것:
  - 결제/예약 도메인 분리 전환 안건 합의
  - backend 결제 이슈 재오픈 및 후속 범위 코멘트 등록
  - 회의록 PR 생성/머지: `rag-cargoo/aki-agentops PR 131`
  - 구현용 분리 브랜치(worktree) 준비
    - backend: `feat/payment-gateway-abstraction-20260221`
    - frontend: `feat/payment-checkout-flow-contract-20260221`
  - backend Workstream 1 구현/PR:
    - `PaymentGateway` 추상화 + `ReservationPaymentPort` 분리
    - PR: `rag-cargoo/ticket-core-service PR 17`
  - frontend 카운트다운 표시 구현/PR:
    - `holdExpiresAt` 기반 예약카드 실시간 결제 제한시간 표시
    - PR: `rag-cargoo/ticket-web-client PR 8`
  - backend 환불 cutoff 정책 1차 반영:
    - 기준: `공연 시작 24시간 전`
    - 일반 사용자 환불: cutoff 이후 차단
    - 관리자 override 환불 API 추가: `POST /api/reservations/v7/admin/{reservationId}/refund`
    - 관련 테스트 추가/통과: `ReservationLifecycleServiceIntegrationTest`
  - backend 만료 실시간 반영 1차 반영:
    - HOLD/PAYING 만료 시 `RESERVATION_STATUS=EXPIRED` push 전송(WS/SSE)
  - backend Workstream 3/4 1차 반영:
    - `app.payment.provider` 기반 게이트웨이 선택(`wallet`/`mock`/`pg-ready`)
    - `MockPaymentGateway`, `PgReadyPaymentGateway` 구현 추가
    - PG webhook 계약 스켈레톤 API 추가: `POST /api/payments/webhooks/pg-ready`
    - 관련 테스트 추가/통과:
      - `MockPaymentGatewayIntegrationTest`
      - `PgReadyPaymentGatewayIntegrationTest`
      - `PgReadyWebhookServiceTest`
  - backend Workstream 3/4 2차 반영(실상태 전이):
    - `PaymentTransaction.status` 확장: `PENDING/SUCCESS/FAILED`
    - `ReservationPaymentPort`가 결제 결과(`PaymentTransaction`)를 반환하도록 계약 확장
    - `pg-ready` 결제 요청 시 즉시 `PENDING` 기록 후 webhook 승인/실패로 최종 상태 전이
    - webhook `APPROVED` 수신 시 `PAYING -> CONFIRMED`, 좌석 `TEMP_RESERVED -> RESERVED`, 캐시 무효화/실시간 상태 푸시 반영
    - webhook `FAILED` 수신 시 예약은 `PAYING` 유지, 결제원장만 `FAILED`로 기록
  - backend 관리자 override 감사로그 반영:
    - 감사 테이블 추가: `admin_refund_audit_logs`
    - 기록 결과: `SUCCESS / DENIED / FAILED`
    - 조회 API 추가: `GET /api/reservations/v7/audit/admin-refunds`
    - 관리자 강제환불 경로에서 성공/거부/실패 로그를 `REQUIRES_NEW`로 보존
  - frontend 결제 승인 대기 UX 보정:
    - `confirm` 응답이 `PAYING`이면 "결제 승인 대기중"으로 표시(확정 완료 오인 방지)
    - 실시간 예약 상태 병합 시 `PAYING/HOLD`는 진행중, `CONFIRMED/REFUNDED`만 성공 상태로 반영
  - admin 콘솔 최소 권한 설정화:
    - 설정 키: `app.admin-console.minimum-role` (`USER`/`ADMIN`)
    - 현재값: `USER` (포트폴리오 모드)
    - 실서비스 전환 시 `ADMIN`으로 값만 변경
- 남은 것:
  - frontend: 만료 이벤트 수신 실패 시 polling fallback 주기/UX 튜닝
  - 문서/API 계약 최종 동기화(결제 상태 enum `PENDING/FAILED` 및 webhook 상태전이 설명 추가)

## 결정 대기 항목
- Status: DONE
- 확정된 결정:
  - 환불 cutoff 기준: `공연 시작 기준`
  - cutoff 기준값: `24시간`
  - cutoff 이후 기본 정책: `환불 차단`, 단 `관리자 override` 허용
  - cutoff 이후 수수료 환불(부분 환불): `미도입`
  - 만료 판정 권한: `백엔드 단일 권한`, 프론트는 표시 전용
  - 관리자 override UI 노출 범위: `포트폴리오 모드 공개`, 실서비스 전환 시 `백오피스 전용` 전환
  - admin 콘솔 최소 권한 제어 방식: `application.yml`의 `app.admin-console.minimum-role`로 운영 전환
