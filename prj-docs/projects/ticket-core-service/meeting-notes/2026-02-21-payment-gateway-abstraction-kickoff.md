# Meeting Notes: Payment Gateway Abstraction Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-21 04:55:00`
> - **Updated At**: `2026-02-21 04:55:00`
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
  - URL: `https://github.com/rag-cargoo/ticket-core-service/issues/5`
- 운영결정:
  - 구현은 각 서비스 레포의 최신 `main` 동기화 후 신규 브랜치에서 진행한다.
  - 문서 PR(본 회의록) 머지 이후 backend/frontend 구현 브랜치로 분리 착수한다.
  - Redis/Kafka/락/대기열 성능개선 축은 유지하며 결제 도메인만 점진 교체한다.
