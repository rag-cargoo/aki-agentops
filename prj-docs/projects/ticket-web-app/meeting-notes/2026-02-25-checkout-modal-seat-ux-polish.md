# Meeting Notes: Checkout Modal Seat UX Polish (ticket-web-app)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-25 12:32:00`
> - **Updated At**: `2026-02-25 12:32:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 사용자 피드백
> - 안건 2: UI 개선 결정
> - 안건 3: 구현 항목
> - 안건 4: 후속 검증
<!-- DOC_TOC_END -->

## 안건 1: 사용자 피드백
- Status: DONE
- 요약:
  - 예매/결제 모달의 좌석 선택 UI가 체크박스 수준으로 보이며 시각적 완성도와 선택 명확성이 부족하다는 피드백이 접수됨.

## 안건 2: UI 개선 결정
- Status: DONE
- 결정:
  - 좌석 선택은 리스트형 라디오 대신 카드형 타일 UI로 전환한다.
  - 선택 상태는 `border + shadow + 배경 톤`으로 즉시 식별 가능하게 만든다.
  - 실시간 동기화 상태는 배지형 안내로 분리해 정보 이해도를 높인다.
  - 모바일에서는 액션 버튼을 단일 열로 전환해 조작 실수를 줄인다.

## 안건 3: 구현 항목
- Status: DONE
- 적용 파일:
  - `workspace/apps/frontend/ticket-web-app/src/pages/service/ServiceCheckoutModal.tsx`
  - `workspace/apps/frontend/ticket-web-app/src/styles.css`
- 적용 내용:
  - 회차 선택 UI를 선택 카드형(`checkout-choice-card`)으로 변경
  - 좌석 선택 UI를 타일 그리드(`checkout-seat-grid`, `checkout-seat-tile`)로 변경
  - 좌석 상태/선택 상태 범례(`checkout-seat-legend`) 추가
  - 좌석 선점 상태/실시간 동기화 상태를 스타일 배지(`checkout-seat-lock-state`, `checkout-realtime-status`)로 분리
  - 체크아웃 모달 레이아웃/반응형(`checkout-modal-card`, `checkout-grid`, `checkout-action-bar`) 보강

## 안건 4: 후속 검증
- Status: DOING
- 검증 결과:
  - `npm run lint` pass
  - `npm run typecheck` pass
  - `npm run build` pass
- 남은 확인:
  - 실제 OAuth 로그인 후 예매 모달 진입 기준 수동 UX 점검
  - 실시간 좌석 업데이트 시 선택 타일 상태 유지/해제 회귀 확인
