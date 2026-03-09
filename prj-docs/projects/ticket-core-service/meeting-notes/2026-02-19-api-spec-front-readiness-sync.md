# Meeting Notes: API Spec Frontend Readiness Sync (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 00:20:00`
> - **Updated At**: `2026-02-19 06:08:30`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: API 명세 단독 프론트 개발 가능 기준 점검
> - 안건 2: 누락 계약 보강 결과
> - 안건 3: 후속 이월 항목
<!-- DOC_TOC_END -->

## 안건 1: API 명세 단독 프론트 개발 가능 기준 점검
- Created At: 2026-02-19 00:20:00
- Updated At: 2026-02-19 00:20:00
- Status: DONE
- 결정사항:
  - 기존 명세는 `wallet/payment`, `websocket push`, `공통 오류/시간/권한 규약`이 분산되어 있어 프론트 단독 구현 기준에 미달했다.
  - 코드 기준 엔드포인트와 문서 경로를 재정렬해 명세 단독 개발 기준으로 보강한다.

## 안건 2: 누락 계약 보강 결과
- Created At: 2026-02-19 00:20:00
- Updated At: 2026-02-19 00:20:00
- Status: DONE
- 반영 내용:
  - `api-contract-conventions.md` 신설(오류/시간/권한/멱등/실시간 모드 규약)
  - `wallet-payment-api.md` 신설(지갑/충전/원장 + 예약 결제/환불 연동)
  - `realtime-push-api.md` 신설(SSE/WS endpoint + topic + payload)
  - `reservation-api.md`, `waiting-queue-api.md`, `user-api.md` 코드 기준 동기화
  - `api-test/README.md`를 `v1~v14 + a*` 및 `v13/v14` 시나리오 기준으로 업데이트

## 안건 3: 후속 이월 항목
- Created At: 2026-02-19 00:20:00
- Updated At: 2026-02-19 06:08:30
- Status: DONE
- 이월 처리:
  - [x] OAuth/JWT 만료/재발급/로그아웃 무효화 고도화 완료 (`TCS-SC-007`, `2026-02-19-auth-session-hardening-completion.md`)
  - [x] 오류 응답 계약 정리 완료 (`api-contract-conventions.md`: auth 영역 `errorCode` JSON, 비-auth 도메인 예외는 plain text 유지로 계약 고정)
  - [x] 프론트 릴리즈 계약 확정 체크리스트 1장 고정 (`../product-docs/frontend-release-contract-checklist.md`)
