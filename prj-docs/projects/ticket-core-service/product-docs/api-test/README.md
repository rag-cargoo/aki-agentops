# API Script Test Guide

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 17:03:13`
> - **Updated At**: `2026-02-23 06:31:07`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Source
> - Publication Policy
> - Content
> - 1. 실행 방법
> - 2. HTTP 시나리오 파일 (순차 실행)
> - 3. 산출물
> - 4. 트러블슈팅 기준
> - 5. Step 7 회귀 실행 스크립트
> - 6. k6 부하 테스트 실행
> - 7. Step 9 상태머신 검증 실행
> - 8. Step 10 취소/환불/재판매 연계 검증 실행
> - 9. Step 11 판매 정책 엔진 검증 실행
> - 10. Step 12 부정사용 방지/감사 추적 검증 실행
> - 11. Auth Track: 소셜 로그인 계약 검증 실행
> - 12. Auth Track A2 인증 세션/가드 검증 실행
> - 13. Playwright MCP로 k6 HTML 열기
> - 14. UX Track U1 통합 시나리오 검증 실행
> - 15. v13 WebSocket 전환 검증 실행
> - 16. v14 지갑/결제/환불 연계 검증 실행
> - 17. Auth-Social CI-safe 파이프라인 검증 실행
> - 18. Auth 예외코드 운영 집계 점검
> - 19. Auth-Social Real Provider E2E 선택 실행
> - 20. 프론트 릴리즈 계약 체크리스트
> - 21. v15 콘서트 판매상태 계약 검증 실행
> - 22. 포트폴리오 더미 시드 스모크 검증
<!-- DOC_TOC_END -->

## Source
- SoT: `AKI AgentOps sidecar` (`prj-docs/projects/ticket-core-service/product-docs/**`)
- Updated For Dedup: 2026-02-17 22:38:23

## Publication Policy
- 이 문서는 GitHub Pages 사용자 탐색용 공식 문서다.
- 변경은 `rag-cargoo/aki-agentops` sidecar PR에서 관리한다.

## Content



`scripts/api/*.sh`와 `scripts/perf/*` 실행 검증과 결과 기록 규칙입니다.

---

## 1. 실행 방법

```bash
cd workspace/apps/backend/ticket-core-service
make test-suite
```

- 내부적으로 `scripts/api/run-api-script-tests.sh`를 호출합니다.
- 기본 실행 세트는 `v1`~`v15` + `a*`(Track) 스크립트입니다.
- 기본 헬스체크 URL은 `http://127.0.0.1:8080/api/concerts` 입니다.
- 필요하면 `API_SCRIPT_HEALTH_URL` 환경변수로 변경할 수 있습니다.
- 기존 환경과의 호환을 위해 `TICKETRUSH_HEALTH_URL`도 별칭으로 지원합니다.
- 기본 모드가 `APP_PUSH_MODE=websocket`이므로 `v13` 검증은 별도 모드 설정 없이 실행 가능합니다.

---

## 2. HTTP 시나리오 파일 (순차 실행)

`scripts/http/*.http`는 "위에서 아래 순차 실행" 기준으로 유지합니다.

- `scripts/http/user.http`
  - 유저 생성 -> 목록/단건 조회 -> 수정 -> 지갑 조회/충전/거래 조회 -> 삭제
- `scripts/http/catalog.http`
  - 엔터테인먼트 생성/조회/수정 -> 아티스트 생성/조회/수정 -> 정리 삭제
- `scripts/http/concert.http`
  - 공연 셋업 -> 목록/검색 -> 판매정책 전환(PREOPEN/OPEN) -> 옵션/좌석 조회 -> 정리 삭제
- `scripts/http/reservation.http`
  - 유저/공연 준비 -> v1/v2/v3/v4/v6 흐름 -> SSE/WS 구독 -> 정책 검증 -> 정리
- `scripts/http/waiting-queue.http`
  - 유저/공연 준비 -> 대기열 진입/조회/SSE/WS -> 정리
- `scripts/http/auth-social.http`
  - OAuth 인가 URL -> code 교환 -> 토큰 재발급 -> 인증 API
  - `@kakaoCode`, `@naverCode`는 수동 입력이 필요
  - 로그아웃 이후 재사용 차단/무토큰 접근/refresh body 누락의 `errorCode(AUTH_*)` 검증 포함

JetBrains HTTP Client(`> {% ... %}` 스크립트 지원) 기준으로 작성되어, 응답 ID를 전역 변수로 캡처해 다음 요청에 연결합니다.

---

## 3. 산출물

- 최신 실행 리포트: `.codex/tmp/ticket-core-service/api-test/latest.md`
- 커밋 체인에서 `scripts/api/*.sh` 변경이 감지되면 위 리포트를 함께 stage해야 합니다.

---

## 4. 트러블슈팅 기준

1. 백엔드 헬스체크 실패 시 앱/인프라를 먼저 기동한다.
2. 스크립트 실패 시 `latest.md`의 실패 로그 요약을 확인한다.
3. 수정 후 테스트 재실행하여 리포트를 최신화한다.
4. 로컬 Kafka 접속 실패 시 `./gradlew bootRun --args='--spring.profiles.active=local --spring.kafka.bootstrap-servers=localhost:9092'`로 재기동한다.

---

## 5. Step 7 회귀 실행 스크립트

```bash
cd workspace/apps/backend/ticket-core-service
bash scripts/api/run-step7-regression.sh
```

- 실행 내용:
  - 인프라/앱 기동 후 `v7-sse-rank-push.sh` 회귀 검증
  - 결과 리포트(`.codex/tmp/ticket-core-service/api-test/latest.md`)와 런타임 로그(`.codex/tmp/ticket-core-service/step7/<run-id>/step7-regression.log`) 생성
- 기본 안정화 옵션:
  - `STEP7_COMPOSE_BUILD=true` (기본): app 이미지를 다시 빌드하여 로컬 코드 반영 보장
  - `STEP7_FORCE_RECREATE=true` (기본): `down -> up` 재생성으로 docker-compose 재기동 오류 회피
  - `STEP7_PUSH_MODE=sse|websocket` (기본 `sse`): Step7 회귀 시 app push 모드 강제값
  - `STEP7_KEEP_ENV=true|false` (기본 false): 검증 후 compose 환경 유지 여부
  - `STEP7_LOG_FILE=/custom/path.log`: 로그 파일 경로 강제 지정
- CI(Jenkins/GitHub Actions) 도입 시에는 위 스크립트를 그대로 호출해 동일 절차를 재사용한다.

---

## 6. k6 부하 테스트 실행

```bash
cd workspace/apps/backend/ticket-core-service
make test-k6
```

- 내부적으로 `scripts/perf/run-k6-waiting-queue.sh`를 호출합니다.
- 기본 시나리오는 `scripts/perf/k6-waiting-queue-join.js`이며, `POST /api/v1/waiting-queue/join` 부하를 측정합니다.
- 기본 파라미터:
  - `K6_VUS=60`
  - `K6_DURATION=60s`
- Step 8 권장 재현(동일 조건 before/after):
  - `K6_VUS=20 K6_DURATION=300s make test-k6`
  - `cp .codex/tmp/ticket-core-service/k6/latest/k6-latest.md .codex/tmp/ticket-core-service/k6/latest/k6-before-step8.md`
  - `cp .codex/tmp/ticket-core-service/k6/latest/k6-summary.json .codex/tmp/ticket-core-service/k6/latest/k6-summary-before-step8.json`
  - 코드 변경 후 동일 명령 재실행
- 결과 산출물:
  - `.codex/tmp/ticket-core-service/k6/latest/k6-latest.md`
  - `.codex/tmp/ticket-core-service/k6/latest/k6-before-step8.md` (baseline 보관 시)
  - `.codex/tmp/ticket-core-service/k6/<run-id>/k6-latest.log`
  - `.codex/tmp/ticket-core-service/k6/latest/k6-summary.json`
  - `.codex/tmp/ticket-core-service/k6/latest/k6-summary-before-step8.json` (baseline 보관 시)
  - `.codex/tmp/ticket-core-service/k6/<run-id>/k6-web-dashboard.html` (대시보드 활성 시)
- 실행 환경에 로컬 `k6`가 없으면 Docker(`grafana/k6`) fallback으로 자동 실행합니다.
- Docker fallback 기본 네트워크는 `host`이며, 필요 시 `K6_DOCKER_NETWORK`로 변경합니다.
- 임시 산출물 기본 루트는 `.codex/tmp/ticket-core-service/k6/`이며, 필요 시 `CODEX_TMP_DIR`로 변경합니다.
- 웹 대시보드를 함께 보고 싶으면 아래처럼 실행합니다.

```bash
cd workspace/apps/backend/ticket-core-service
make test-k6-dashboard
```

- 실행 중 대시보드 URL: `http://127.0.0.1:5665`

---

## 7. Step 9 상태머신 검증 실행

```bash
cd workspace/apps/backend/ticket-core-service
bash scripts/api/v8-reservation-lifecycle.sh
```

- 검증 흐름:
  - `HOLD` 생성
  - `PAYING` 전이
  - `CONFIRMED` 전이
  - 최종 상태 조회
- Step 9 실행 리포트:
  - `.codex/tmp/ticket-core-service/api-test/step9-lifecycle-latest.md`

---

## 8. Step 10 취소/환불/재판매 연계 검증 실행

```bash
cd workspace/apps/backend/ticket-core-service
bash scripts/api/v9-cancel-refund-resale.sh
```

- 검증 흐름:
  - 대기 유저 큐 진입(`WAITING`)
  - `HOLD -> PAYING -> CONFIRMED` 생성
  - `CANCELLED` 전이 + 대기열 상위 유저 `ACTIVE` 승격
  - `REFUNDED` 전이 + 최종 상태 확인
- Step 10 실행 리포트:
  - `.codex/tmp/ticket-core-service/api-test/step10-cancel-refund-latest.md`

---

## 9. Step 11 판매 정책 엔진 검증 실행

```bash
cd workspace/apps/backend/ticket-core-service
bash scripts/api/v10-sales-policy-engine.sh
```

- 검증 흐름:
  - `PUT /api/concerts/{concertId}/sales-policy` 정책 설정
  - BASIC 유저 선예매 차단(`409`)
  - VIP 유저 선예매 허용(`201 HOLD`)
  - VIP 유저 두 번째 HOLD 차단(`409`, 1인 제한)
  - 정책 조회 API 응답 일치 확인
- Step 11 실행 리포트:
  - `.codex/tmp/ticket-core-service/api-test/step11-sales-policy-latest.md`

---

## 10. Step 12 부정사용 방지/감사 추적 검증 실행

```bash
cd workspace/apps/backend/ticket-core-service
bash scripts/api/v11-abuse-audit.sh
```

- 검증 흐름:
  - 유저별 요청 빈도 초과 차단(`RATE_LIMIT_EXCEEDED`)
  - 중복 `requestFingerprint` 차단(`DUPLICATE_REQUEST_FINGERPRINT`)
  - 다계정 `deviceFingerprint` 차단(`DEVICE_FINGERPRINT_MULTI_ACCOUNT`)
  - 감사 조회 API(`GET /api/reservations/v6/audit/abuse`)에서 차단 사유 조회 확인
- Step 12 실행 리포트:
  - `.codex/tmp/ticket-core-service/api-test/step12-abuse-audit-latest.md`

---

## 11. Auth Track: 소셜 로그인 계약 검증 실행

```bash
cd workspace/apps/backend/ticket-core-service
bash scripts/api/v12-social-auth-contract.sh
```

- 검증 흐름:
  - 카카오 authorize-url 조회 계약 확인
  - 네이버 authorize-url + state 생성 계약 확인
  - exchange 입력값 검증(`code`/`state`) 400 응답 계약 확인
- 실행 리포트:
  - `.codex/tmp/ticket-core-service/api-test/auth-track-a1-social-auth-latest.md`

---

## 12. Auth Track A2 인증 세션/가드 검증 실행

```bash
cd workspace/apps/backend/ticket-core-service
bash scripts/api/a2-auth-track-session-guard.sh
```

- 검증 흐름:
  - `/api/auth/me` 무토큰 접근 차단(`401`, `AUTH_ACCESS_TOKEN_REQUIRED`)
  - `POST /api/auth/token/refresh` 입력 검증(`400`, `AUTH_REFRESH_TOKEN_REQUIRED`)
  - `POST /api/reservations/v7/holds` 무토큰 접근 차단(`401`, `AUTH_ACCESS_TOKEN_REQUIRED`)
- 실행 리포트:
  - `.codex/tmp/ticket-core-service/api-test/auth-track-a2-session-guard-latest.md`

---

## 13. Playwright MCP로 k6 HTML 열기

`k6-web-dashboard.html`은 로컬 파일이므로 Playwright MCP에서 `file://` 직접 열기가 실패할 수 있습니다.
표준 절차는 "로컬 HTTP 서빙 + MCP `navigate`" 입니다.

1. k6 산출물 생성

```bash
cd workspace/apps/backend/ticket-core-service
make test-k6
```

2. Chrome를 CDP 포트로 실행

```bash
setsid google-chrome --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-mcp-profile --no-first-run --no-default-browser-check about:blank >/tmp/playwright_chrome.log 2>&1 < /dev/null &
curl -sS http://127.0.0.1:9222/json/version
```

3. k6 산출물 디렉토리를 로컬 HTTP로 서빙

```bash
cd workspace/apps/backend/ticket-core-service
repo_root="$(git rev-parse --show-toplevel)"
latest_run_dir="$(ls -1dt "$repo_root"/.codex/tmp/ticket-core-service/k6/* 2>/dev/null | head -n 1)"
nohup python3 -m http.server 18080 --bind 127.0.0.1 --directory "$latest_run_dir" >/tmp/k6-http.log 2>&1 &
curl -sS -I http://127.0.0.1:18080/k6-web-dashboard.html | head -n 1
```

4. Playwright MCP에서 아래 URL로 이동

```text
http://127.0.0.1:18080/k6-web-dashboard.html
```

5. 작업 후 정리(선택)

```bash
pkill -f "http.server 18080"
pkill -f "google-chrome.*remote-debugging-port=9222"
```

---

## 14. UX Track U1 통합 시나리오 검증 실행

```bash
cd workspace/apps/backend/ticket-core-service

# local profile + infra(redis/kafka) 조합에서 OAuth 계약까지 포함해 검증할 때
KAKAO_CLIENT_ID=dummy-kakao-client \
KAKAO_CLIENT_SECRET=dummy-kakao-secret \
KAKAO_REDIRECT_URI=http://localhost:8080/login/oauth2/code/kakao \
NAVER_CLIENT_ID=dummy-naver-client \
NAVER_CLIENT_SECRET=dummy-naver-secret \
NAVER_REDIRECT_URI=http://localhost:8080/login/oauth2/code/naver \
NAVER_SERVICE_URL=http://localhost:8080 \
./gradlew bootRun

bash scripts/api/v12-social-auth-contract.sh
bash scripts/api/a2-auth-track-session-guard.sh
bash scripts/api/v5-waiting-queue.sh
bash scripts/api/v8-reservation-lifecycle.sh
```

- 확장 smoke 체크:
  - `POST /api/concerts/setup` (artist/entertainment 확장 필드 포함)
  - `GET /api/concerts/search` (`keyword`, `entertainmentName`, `sort=entertainmentName,asc`)
  - `GET /api/v1/waiting-queue/subscribe` (SSE `INIT/RANK_UPDATE/KEEPALIVE`)
- 최신 통합 검증 리포트:
  - `.codex/tmp/ticket-core-service/api-test/ux-track-u1-integration-latest.md`

실패 시 `skills/aki-mcp-playwright/references/troubleshooting.md`의 "`Local HTML Cannot Be Opened Directly by MCP`" 항목을 확인합니다.

---

## 15. v13 WebSocket 전환 검증 실행

```bash
cd workspace/apps/backend/ticket-core-service
./gradlew bootRun --args='--spring.profiles.active=local'

# 다른 터미널
bash scripts/api/v13-websocket-switching.sh
```

- 검증 흐름:
  - 대기열 WS 구독 등록/해제 API 확인
  - 예약 WS 구독 등록/해제 API 확인
  - destination 경로(`/topic/waiting-queue/...`, `/topic/reservations/...`) 계약 확인

---

## 16. v14 지갑/결제/환불 연계 검증 실행

```bash
cd workspace/apps/backend/ticket-core-service
bash scripts/api/v14-wallet-payment-flow.sh
```

- 검증 흐름:
  - 초기 지갑 잔액(200000) 확인
  - 충전 후 잔액 증가 확인
  - `HOLD -> PAYING -> CONFIRMED`에서 결제 차감 확인
  - `CANCELLED -> REFUNDED`에서 환불 복구 확인
  - 거래원장에 `PAYMENT`, `REFUND` 기록 확인

---

## 17. Auth-Social CI-safe 파이프라인 검증 실행

```bash
cd workspace/apps/backend/ticket-core-service
make test-auth-social-pipeline
```

- 검증 흐름:
  - `SocialAuthControllerIntegrationTest`
  - `SocialAuthServiceTest`
  - `AuthSecurityIntegrationTest`
  - `AuthSessionServiceTest`
- 실행 스크립트:
  - `scripts/api/run-auth-social-e2e-pipeline.sh`
- 실행 리포트:
  - `.codex/tmp/ticket-core-service/api-test/auth-social-e2e-latest.md`
- 비고:
  - 외부 OAuth 실코드/실비밀값 없이 재현 가능한 CI-safe 경로를 기본값으로 사용한다.

---

## 18. Auth 예외코드 운영 집계 점검

운영 로그(`AUTH_MONITOR`)가 수집되는 환경에서 code별 집계를 확인한다.

```bash
# 예시: 애플리케이션 로그에서 auth code별 5분 집계 확인
grep "AUTH_MONITOR" app.log | tail -n 500 | sed -n 's/.*code=\\([^ ]*\\).*/\\1/p' | sort | uniq -c | sort -nr
```

- 최소 확인 항목:
  - `AUTH_ACCESS_TOKEN_REQUIRED` (무토큰 요청)
  - `AUTH_TOKEN_EXPIRED` (만료 토큰)
  - `AUTH_TOKEN_INVALID` (파싱/서명 실패)
  - `AUTH_FORBIDDEN` (권한 부족)
- 임계치 기준은 `api-specs/auth-error-monitoring-guide.md`를 따른다.

---

## 19. Auth-Social Real Provider E2E 선택 실행

real provider(카카오/네이버) 실제 code 교환 검증은 CI-safe 파이프라인과 분리해 선택 실행한다.

### 19.1 Prepare 단계 (인가 URL 발급)

```bash
cd workspace/apps/backend/ticket-core-service
APP_AUTH_SOCIAL_REAL_E2E_ENABLED=true \
AUTH_REAL_E2E_PROVIDER=kakao \
AUTH_REAL_E2E_PREPARE_ONLY=true \
bash scripts/api/run-auth-social-real-provider-e2e.sh
```

- 출력된 authorize URL로 브라우저 로그인 후 callback `code`를 확보한다.
- 네이버는 필요 시 `AUTH_REAL_E2E_STATE`를 함께 지정한다.

### 19.2 Execute 단계 (실코드 검증)

```bash
cd workspace/apps/backend/ticket-core-service
APP_AUTH_SOCIAL_REAL_E2E_ENABLED=true \
AUTH_REAL_E2E_PROVIDER=kakao \
AUTH_REAL_E2E_CODE=<callback-code> \
bash scripts/api/run-auth-social-real-provider-e2e.sh
```

- 검증 흐름:
  - social `exchange` 성공
  - `GET /api/auth/me` 성공
  - `POST /api/auth/logout` 성공
  - access 재사용 차단(`401`, `AUTH_ACCESS_TOKEN_REVOKED`)
  - refresh 재사용 차단(`400`, `AUTH_REFRESH_TOKEN_EXPIRED_OR_REVOKED`)
- 실행 리포트:
  - `.codex/tmp/ticket-core-service/api-test/auth-social-real-provider-e2e-latest.md`

### 19.3 운영 규칙

- 기본 CI는 `make test-auth-social-pipeline`(CI-safe)만 필수로 유지한다.
- real provider E2E는 릴리즈 전 수동 점검 또는 별도 운영 창구에서만 실행한다.

---

## 20. 프론트 릴리즈 계약 체크리스트

- 릴리즈 게이트 문서:
  - `../frontend-release-contract-checklist.md`
- 사용 기준:
  - API 계약 확인은 `api-specs/*.md`를 우선 기준으로 확인
  - 실행 검증은 본 문서의 Step + Track 명령(`make test-suite`, `make test-auth-social-pipeline`) 결과 리포트로 확인
  - auth-social 상세 시나리오는 `scripts/http/auth-social.http`를 구현 계약의 실행 예시로 사용

---

## 21. v15 콘서트 판매상태 계약 검증 실행

```bash
cd workspace/apps/backend/ticket-core-service
bash scripts/api/v15-concert-sale-status-contract.sh
```

- 검증 흐름:
  - `UNSCHEDULED` -> `PREOPEN` -> `OPEN_SOON_1H` -> `OPEN_SOON_5M` -> `OPEN` -> `SOLD_OUT`
  - `reservationButtonVisible` / `reservationButtonEnabled` 계약 검증
  - `saleOpensInSeconds`, `availableSeatCount`, `totalSeatCount` 검증

---

## 22. 포트폴리오 더미 시드 스모크 검증

```bash
cd workspace/apps/backend/ticket-core-service
APP_PORTFOLIO_SEED_ENABLED=true ./gradlew bootRun --args='--spring.profiles.active=local'

# 다른 터미널
curl -s "http://127.0.0.1:8080/api/concerts/search?keyword=Portfolio&page=0&size=20&sort=id,desc"
```

- 기대 결과:
  - 응답 `items`에 포트폴리오 샘플 공연이 1건 이상 포함된다.
  - 상태 필드(`saleStatus`, `saleOpensInSeconds`, `reservationButtonVisible`, `reservationButtonEnabled`)가 함께 내려온다.
- 참고:
  - 시드는 아이템포턴시 마커 기반이므로 동일 DB에서는 중복 생성되지 않는다.
