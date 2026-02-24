# Frontend Implementation Blueprint (ticket-web-app)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-25 01:18:00`
> - **Updated At**: `2026-02-25 01:18:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Goal
> - UX Flow (Real User)
> - Contract Rules
> - Delivery Phases
> - Verification Plan
<!-- DOC_TOC_END -->

## Goal
- 백엔드 DDD/상태머신 계약을 우선으로 프론트를 구현한다.
- 개발자 편의 UI가 아니라 실제 사용자 관점의 예약/결제/복구 흐름을 제공한다.
- 구현 순서는 `문서 고정 -> 계약 정렬 -> 검증`으로 강제한다.

## UX Flow (Real User)
- 서비스 사용자
  - 공연 목록 확인: `예매 가능`, `오픈 대기`, `기타` 섹션 분리
  - 로그인: 카카오/네이버 OAuth -> 세션 복원 -> 헤더 프로필 메뉴
  - 예매: 회차/좌석/홀드/결제/확정 상태를 화면에서 단계별 피드백
  - 내 예약 관리: 상태별 가능 액션만 노출(`CONFIRMED->취소`, `CANCELLED->환불`)
  - 결제 실패 복구: `Insufficient wallet balance` 시 잔액/충전 UI로 유도
- 운영자(Admin)
  - Concert/Option CRUD
  - Sales Policy는 백엔드 실필드만 편집(`maxReservationsPerUser`)
  - 미디어(썸네일) 업로드/삭제

## Contract Rules
- 인증/권한
  - 서비스 페이지는 비로그인 조회 가능, 예약 액션은 로그인 세션 필수
  - 관리자 액션은 OAuth 세션 + role guard + 실제 API 401/403 처리
- 예약/결제
  - 프론트는 v7 계약만 사용
  - 상태머신 외 전이를 UI에서 차단
  - 결제 게이트웨이 provider별 차이를 고려하되 기본값(`wallet`)을 우선 UX로 제공
- 정책/제약
  - 사용자당 제한은 콘서트 단위 `maxReservationsPerUser` 기준
  - 프론트 하드코딩 제한(예: global 3건)은 금지
- 필드 드리프트 대응
  - `entertainment*`/`agency*` 동시 파싱

## Delivery Phases
- Phase 1: Contract Alignment (Now)
  - 목록 파서 드리프트 대응
  - Admin 정책 폼 단순화(`maxReservationsPerUser`)
  - 잔액 부족 에러 문구 개선 + 지갑 액션 연결
- Phase 2: User Recovery UX
  - 서비스 페이지 지갑 카드(잔액/충전/최근 거래)
  - 예약 실패 유형별 가이드(재시도, 오픈대기, 잔액부족, 권한오류)
- Phase 3: Realtime/Queue Hardening
  - SSE/WS 구독 모듈 분리 및 재연결 전략 고도화
  - 좌석/예약 상태 push 기반 동기화 강화
- Phase 4: Release Readiness
  - non-mock smoke 및 계약 회귀 체크리스트 완료
  - 사이드카 task/meeting-notes/테스트 이력 동기화

## Verification Plan
- 정적 검증
  - `npm run typecheck`
  - `npm run build`
- 계약 검증
  - `18080`(LB) 기준 OAuth->예약->취소/환불->지갑 흐름 수동 점검
  - `8080`(direct) 기동 시 동일 시나리오 재검증
- 실패 시 기록
  - 실패 엔드포인트/상태코드/메시지/재현 조건을 sidecar 회의록에 누적
