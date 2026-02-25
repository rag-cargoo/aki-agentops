# Meeting Notes: Card-Only Checkout + Wallet Removal Alignment (ticket-web-app)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-26 07:18:00`
> - **Updated At**: `2026-02-26 07:18:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 문제 정의
> - 안건 2: 결제수단 정책 재정의
> - 안건 3: Checkout 가상카드 UX 반영
> - 안건 4: 계정 지갑 UI 제거
> - 안건 5: 검증/트래킹 동기화
<!-- DOC_TOC_END -->

## 안건 1: 문제 정의
- Status: DONE
- 요약:
  - 사용자 관점에서 월렛 결제와 무통장입금은 더 이상 제공하지 않기로 결정했다.
  - 결제는 카드만 사용하고, 로컬/개발 환경에서는 모든 사용자에게 동일한 가상 테스트카드가 보이는 흐름으로 통일한다.

## 안건 2: 결제수단 정책 재정의
- Status: DONE
- 결정:
  - 프론트 결제수단 타입에서 `WALLET`, `BANK_TRANSFER`를 제거한다.
  - 결제수단 기본 fallback은 `CARD`로 고정한다.
  - `/account` 메뉴는 `내 예약/결제` 단일 진입으로 정리하고 `/account/wallet` 전용 UX는 제거한다.

## 안건 3: Checkout 가상카드 UX 반영
- Status: DONE
- 결정:
  - checkout 결제시트에서 카드가 선택되면 `가상 테스트 카드 선택` 영역을 노출한다.
  - 결제 확정 버튼은 테스트카드가 선택된 상태에서만 활성화한다.
  - 결제 완료 메시지에 선택 카드 번호(마스킹)를 함께 표시한다.

## 안건 4: 계정 지갑 UI 제거
- Status: DONE
- 결정:
  - 계정 화면에서 지갑 원장/잔액/거래내역 패널을 제거한다.
  - 지갑 클라이언트(`wallet-client`) 및 지갑 전용 컴포넌트(`ServiceWalletSection`)를 삭제한다.
  - 헤더 프로필 메뉴의 `결제/지갑` 링크를 `내 예약/결제`로 대체한다.

## 안건 5: 검증/트래킹 동기화
- Status: DONE
- 검증:
  - `npm run lint` PASS
  - `npm run typecheck` PASS
  - `npm run build` PASS
- 트래킹:
  - frontend issue: `https://github.com/rag-cargoo/ticket-web-app/issues/3`
  - backend issue: `https://github.com/rag-cargoo/ticket-core-service/issues/50`
  - task:
    - `prj-docs/projects/ticket-web-app/task.md` `TWA-SC-012`
    - `prj-docs/projects/ticket-core-service/task.md` `TCS-SC-031`
