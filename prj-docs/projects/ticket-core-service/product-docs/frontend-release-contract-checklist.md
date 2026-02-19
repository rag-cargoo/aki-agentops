# Frontend Release Contract Checklist (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 06:08:30`
> - **Updated At**: `2026-02-19 14:40:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Required References
> - Release Checklist
> - Sign-off (Optional for Solo Mode)
<!-- DOC_TOC_END -->

## Scope
- 이 문서는 프론트 릴리즈 직전 계약 확정본 체크리스트다.
- 기준 문서는 `API Specs` + `API Test Guide` + `scripts/http/auth-social.http` 3축으로 고정한다.

## Required References
- API 공통 계약: `./api-specs/api-contract-conventions.md`
- 인증 세션/소셜: `./api-specs/auth-session-api.md`, `./api-specs/social-auth-api.md`
- 예약/실시간/결제: `./api-specs/reservation-api.md`, `./api-specs/realtime-push-api.md`, `./api-specs/wallet-payment-api.md`
- 테스트 가이드: `./api-test/README.md`
- HTTP 시나리오: `workspace/apps/backend/ticket-core-service/scripts/http/auth-social.http`

## Release Checklist
- [x] C1 인증/세션 계약 확인
  - `social exchange -> auth/me -> logout -> 재사용 차단` 시나리오가 명세/스크립트와 일치
  - `AUTH_*` 오류코드(`401/403/400`)가 프론트 분기 로직과 일치
- [x] C2 권한/오류/시간대 계약 확인
  - `api-contract-conventions.md`의 권한 경계(공개/인증/관리자) 기준을 화면 접근 정책에 반영
  - 시간대 규칙(UTC 저장, KST 표시)을 UI 포맷터 기준으로 고정
  - 비-auth 도메인 예외도 JSON(`status`, `errorCode`, `message`) 파싱을 기본으로 적용
- [x] C3 실시간 채널 계약 확인
  - 기본 모드는 `APP_PUSH_MODE=websocket`으로 고정하고, 필요 시 `sse`로 명시 오버라이드
  - 선택 채널 기준 endpoint/topic/payload 파서 검증 완료
- [x] C4 예약/결제 연계 확인
  - 예약 상태 전이(`HOLD -> PAYING -> CONFIRMED -> CANCELLED/REFUNDED`) 화면 상태머신과 일치
  - 지갑 잔액/거래내역 화면이 `wallet-payment-api.md` 응답 필드와 일치
- [ ] C5 회귀/운영 검증 실행
  - `make test-suite` 결과 리포트 확인: `.codex/tmp/ticket-core-service/api-test/latest.md`
  - `make test-auth-social-pipeline` 결과 리포트 확인: `.codex/tmp/ticket-core-service/api-test/auth-social-e2e-latest.md`
  - 필요 시 real provider 선택 검증: `make test-auth-social-real-provider`
  - 현재 상태:
    - `make test-suite`: PENDING - `run-step7-regression.sh`에 `STEP7_PUSH_MODE`(기본 `sse`) 강제 반영 후 재실행 필요
    - `make test-auth-social-pipeline`: PASS
    - real provider: PASS (kakao real code 교환 + me/logout/reuse guard 검증 완료)

## Sign-off (Optional for Solo Mode)
- 팀 협업 릴리즈에서는 아래 승인 기록을 채운다.
- 1인 개발(솔로 모드)에서는 이 섹션 입력을 생략해도 된다.
- Front Owner: Pending (Owner assign required)
- Backend Owner: Pending (Owner assign required)
- QA Owner: Pending (Owner assign required)
- Release Date: Pending final approval
- Evidence Links:
  - API report: `workspace/apps/backend/ticket-core-service/.codex/tmp/ticket-core-service/api-test/latest.md`
  - Auth-social pipeline report: `workspace/apps/backend/ticket-core-service/.codex/tmp/ticket-core-service/api-test/auth-social-e2e-latest.md`
  - (Optional) Real provider report: `workspace/apps/backend/ticket-core-service/.codex/tmp/ticket-core-service/api-test/auth-social-real-provider-e2e-latest.md`
