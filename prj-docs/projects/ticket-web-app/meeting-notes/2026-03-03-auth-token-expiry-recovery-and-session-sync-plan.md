# Meeting Notes: Auth Token Expiry Recovery and Session Sync Plan

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-03-03 06:20:00`
> - **Updated At**: `2026-03-03 06:20:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 증상/원인 확정
> - 안건 2: 실무 처리 원칙
> - 안건 3: 다음 세션 구현 TODO
> - 안건 4: 완료 체크/기록 규칙
> - 안건 5: External Sync
<!-- DOC_TOC_END -->

## 안건 1: 증상/원인 확정
- Status: CONFIRMED
- 사용자 재현 증상:
  - `기존 예약 조회 실패: unauthorized`
  - `좌석 실시간 구독 등록 실패: {"status":401,"errorCode":"AUTH_TOKEN_EXPIRED","message":"unauthorized"}`
  - `좌석 선점 실패: unauthorized`
- 확정 원인:
  - 백엔드 access token 만료 시 `AUTH_TOKEN_EXPIRED + 401` 응답
  - 프론트 서비스/체크아웃 경로에는 401 만료에 대한 자동 refresh 재시도 공통계층이 없음
- 참고 근거:
  - `ticket-core-service/src/main/resources/application.yml` (`access-token-seconds=1800`, `refresh-token-seconds=1209600`)
  - `ticket-core-service/src/main/java/com/ticketrush/application/auth/service/JwtTokenProvider.java`
  - `ticket-web-app/src/pages/service/ServiceCheckoutModal.tsx`
  - `ticket-web-app/src/App.tsx` (앱 부팅 시에만 refresh 복구 시도)

## 안건 2: 실무 처리 원칙
- Status: AGREED
- 원칙:
  - access token 만료는 정상 이벤트로 처리하고, 먼저 refresh token으로 무중단 복구한다.
  - refresh 실패 시에만 세션을 unauthenticated로 전환하고 재로그인을 유도한다.
  - 소셜 로그인창 강제 오픈(`prompt=login`)은 일반 만료 복구 경로가 아니라 고위험 액션 재인증/계정전환 명시 요청 시에 사용한다.
  - UI의 로그인 상태와 실제 API 인증 상태를 즉시 동기화한다(불일치 금지).
  - refresh는 single-flight(동시 1회)로 수행하고, 원요청 재시도는 1회로 제한한다.
- 실무 참고:
  - RFC 6749 (OAuth 2.0), Section 6 Refreshing an Access Token: https://www.rfc-editor.org/rfc/rfc6749
  - RFC 7009 (OAuth 2.0 Token Revocation): https://www.rfc-editor.org/rfc/rfc7009
  - RFC 9700 (OAuth 2.0 Security BCP, Refresh Token Protection): https://www.rfc-editor.org/rfc/rfc9700
  - OpenID Connect Core 1.0 (`prompt` 파라미터 `login/none/...`): https://openid.net/specs/openid-connect-core-1_0.html

## 안건 3: 다음 세션 구현 TODO
- Status: TODO
- MUST TODO:
  - [ ] 공통 auth fetch wrapper 도입(401 + `AUTH_TOKEN_EXPIRED` -> refresh -> 원요청 1회 재시도)
  - [ ] refresh single-flight(동시 요청 대기열) 적용
  - [ ] refresh 성공 시 토큰/만료시각/profile 상태 즉시 동기화
  - [ ] refresh 실패 시 세션 clear + 로그인 유도 메시지/모달 노출
  - [ ] 체크아웃 WS 구독 등록 API도 refresh 재시도 경로 적용
  - [ ] 서비스/계정/체크아웃 API 클라이언트 공통 적용
  - [ ] 수동 QA 시나리오(30분 만료/refresh 만료) 실행 후 로그 기록

## 안건 4: 완료 체크/기록 규칙
- Status: AGREED
- 규칙:
  - 구현 항목은 작업 중 `TODO -> DOING`, 끝나면 반드시 `DONE`으로 바꾸고 체크박스를 `[x]`로 갱신한다.
  - 완료 시 Evidence를 반드시 남긴다:
    - 코드 경로
    - 검증 명령(`lint/typecheck/build`)
    - 재현/복구 시나리오 결과
  - 체크만 하고 증빙이 없으면 `DONE`으로 인정하지 않는다.

## 안건 5: External Sync
- Status: DONE
- Source of Truth (Issue):
  - `https://github.com/rag-cargoo/ticket-web-app/issues/15`
- Sync Action:
  - 신규 이슈 생성 + sidecar meeting/task 동기화
