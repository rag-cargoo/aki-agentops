# Meeting Notes: Wallet/Payment Ledger Implementation Completion (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-18 23:54:21`
> - **Updated At**: `2026-02-18 23:54:21`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 결제/원장 구현 완료 확인
> - 안건 2: 구현 체크리스트 상태
> - 안건 3: 다음 이월 범위
<!-- DOC_TOC_END -->

## 안건 1: 결제/원장 구현 완료 확인
- Created At: 2026-02-18 23:54:21
- Updated At: 2026-02-18 23:54:21
- Status: DONE
- 결정사항:
  - 제품 레포 결제/원장 구현 이슈 `rag-cargoo/ticket-core-service#5` 완료(CLOSED)
  - 구현 PR `rag-cargoo/ticket-core-service PR #6` 머지 완료

## 안건 2: 구현 체크리스트 상태
- Created At: 2026-02-18 23:54:21
- Updated At: 2026-02-18 23:54:21
- Status: DONE
- Checklist:
  - [x] `users.wallet_balance_amount` 필드 도입 (기본 200000)
  - [x] `payment_transactions` 원장 엔티티/리포지토리/서비스 도입
  - [x] 예약 `confirm/refund` 결제 연동
  - [x] 지갑 충전/잔액/거래내역 API 추가
  - [x] 설정값 `app.payment.default-ticket-price-amount` 도입
  - [x] 통합 테스트(`./gradlew test`) 통과

## 안건 3: 다음 이월 범위
- Created At: 2026-02-18 23:54:21
- Updated At: 2026-02-18 23:54:21
- Status: TODO
- 이월 범위:
  - OAuth/JWT 만료/재발급/로그아웃 무효화 정책 고도화
  - 프론트 출시 계약(에러코드/시간대/권한 경계) 보강
