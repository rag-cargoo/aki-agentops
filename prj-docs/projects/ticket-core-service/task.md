# Task Dashboard (ticket-core-service sidecar)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 05:11:38`
> - **Updated At**: `2026-02-20 05:13:19`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Current Items
<!-- DOC_TOC_END -->

## Scope
- 이 문서는 `ticket-core-service` 운영 sidecar 태스크를 관리한다.
- 구현 상세 태스크는 제품 레포 이슈/PR에서 관리한다.

## Current Items
- TCS-SC-001 외부 레포 분리 전환 운영 확인
  - Status: DONE
  - Description: code_root, docs_root, repo_remote가 `project-map.yaml`과 일치하는지 점검
  - Evidence:
    - `project-map.yaml`에 `workspace/apps/backend/ticket-core-service` + `prj-docs/projects/ticket-core-service` + `https://github.com/rag-cargoo/ticket-core-service`
    - `session_start.sh` 출력에서 Active Project `Docs Root: prj-docs/projects/ticket-core-service` 확인
    - PR `#65` merged (`2026-02-16`) 및 연계 이슈 `#66` closed

- TCS-SC-002 sidecar 분리 이후 제품 레포 문서 SoT 중복 정리
  - Status: DONE
  - Description:
    - 제품 레포(`ticket-core-service`)의 `prj-docs`를 제거하고 sidecar 문서 SoT 단일화 전환 완료
    - 제품 README/스크립트 기본 경로를 sidecar 운영 모델에 맞게 정렬
  - Evidence:
    - 회의록: `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-17-sidecar-sot-dedup-followup.md`
    - AKI AgentOps 이슈 재오픈: `https://github.com/rag-cargoo/aki-agentops/issues/66`
    - 제품 레포 이슈: `rag-cargoo/ticket-core-service#1` (cross-repo shorthand)
    - 제품 레포 PR: `rag-cargoo/ticket-core-service PR #2` (merged, cross-repo shorthand)
    - 제품 레포 머지 커밋: `f0f798b0dfee0428b1d807acd0f4c25206f3e94a`
    - 제품 레포 이슈 상태: `#1 CLOSED`
    - 동기화 코멘트(AgentOps): `https://github.com/rag-cargoo/aki-agentops/issues/66#issuecomment-3914421398`
    - 동기화 코멘트(AgentOps 최신): `https://github.com/rag-cargoo/aki-agentops/issues/66#issuecomment-3914681986`
    - 동기화 코멘트(ticket-core-service): `rag-cargoo/ticket-core-service#1 comment 3914422354`
    - 동기화 코멘트(ticket-core-service 최신): `rag-cargoo/ticket-core-service#1 comment 3914680685`
    - 비고: `doc-state-sync`가 동일 저장소 기준으로 URL 이슈 번호를 해석하므로, cross-repo 이슈는 shorthand 표기로 유지

- TCS-SC-003 Pages 문서 라벨/Source 안내 정합화
  - Status: DONE
  - Description:
    - `product-docs`가 더 이상 mirror가 아님에 따라 제목/정책/링크 라벨을 `Pages Docs` 기준으로 정렬
    - 삭제된 upstream(`ticket-core-service/prj-docs/**`) 참조를 sidecar SoT 기준으로 교체
  - Evidence:
    - sidecar docs 갱신 PR: `https://github.com/rag-cargoo/aki-agentops/pull/92` (merged)
    - `github-pages/sidebar-manifest.md`의 Ticket Core Service 라벨을 `(Pages Docs)`로 정렬
    - `prj-docs/projects/ticket-core-service/product-docs/**` 상단 정책을 `Publication Policy`로 정렬

- TCS-SC-004 실시간 전송(SSE/WS) 전환 안건 정리 및 트래킹 동기화
  - Status: DONE
  - Description:
    - SSE 유지 + WebSocket 병행 + 설정 스위칭 전략을 회의록/이슈/태스크 기준으로 정렬
    - 구현 착수 전 관리 순서(회의록 -> task -> 제품 이슈)를 확정
  - Evidence:
    - 회의록: `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-18-realtime-transport-sse-ws-switching-plan.md`
    - 제품 레포 이슈: `rag-cargoo/ticket-core-service#3` (cross-repo shorthand)

- TCS-SC-005 실시간 전송 채널 추상화 및 WebSocket 병행 구현
  - Status: DONE
  - Description:
    - `ticket-core-service` 제품 레포에서 notifier 인터페이스 + SSE/WS 구현체 분리
    - 설정값 기반 모드 스위칭(`sse`, `websocket`)과 채널별 컨트롤러 분리 적용
    - 기존 SSE 경로 하위호환 유지 + 채널별 테스트/문서 정합화
  - Evidence:
    - Tracking Issue: `rag-cargoo/ticket-core-service#3` (closed)
    - Product PR: `rag-cargoo/ticket-core-service PR #4` (merged, cross-repo shorthand)
    - Merge Commit: `72f57d7a0dfedf08305d4d6ed73af41d97800359`
    - Included:
      - `PushNotifier` + `SsePushNotifier` + `WebSocketPushNotifier`
      - `app.push.mode` (`APP_PUSH_MODE=sse|websocket`)
      - WebSocket endpoint `/ws` + subscription APIs
      - `./gradlew clean test` pass

- TCS-SC-006 결제/환불/보유머니 원장 구현 및 예약 연동
  - Status: DONE
  - Description:
    - 지갑 잔액(wallet) + 결제 원장(ledger) 최소 구현 도입
    - 예약 `confirm/refund` 흐름에 결제 차감/환불 복구 연동
    - 지갑 충전/조회/거래내역 API 및 테스트 스크립트 추가
  - Evidence:
    - 회의록: `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-18-wallet-payment-ledger-implementation-completion.md`
    - Product Issue: `rag-cargoo/ticket-core-service#5` (closed)
    - Product PR: `rag-cargoo/ticket-core-service PR #6` (merged, cross-repo shorthand)
    - Merge Commit: `34033788d38c51ed43205856d9d6f752335e1cbb`
    - Verification: `./gradlew test` pass

- TCS-SC-007 OAuth/JWT 만료/재발급/로그아웃 무효화 고도화
  - Status: DONE
  - Description:
    - Access/Refresh 만료/재발급 계약을 API/문서 기준으로 명확화
    - 로그아웃 이후 토큰 무효화 경계와 예외 응답 규약 보강
  - Evidence:
    - 회의록: `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-19-auth-session-hardening-completion.md`
    - Product Issue: `rag-cargoo/ticket-core-service#7` (closed)
    - Product PR: `rag-cargoo/ticket-core-service PR #8` (merged, cross-repo shorthand)
    - Merge Commit: `f3cd910632bddf266bda904a382b977d20538b05`
    - Verification: `./gradlew test` pass

- TCS-SC-008 프론트 출시 계약(에러코드/시간대/권한 경계) 보강
  - Status: DONE
  - Description:
    - 예약/결제/대기열 API의 오류 응답 표준 및 시간대 규칙(UTC/KST) 정리
    - 공개/인증/관리자 권한 경계 계약을 문서/테스트 케이스로 고정
  - Evidence:
    - 공통 계약 문서 추가:
      - `prj-docs/projects/ticket-core-service/product-docs/api-specs/api-contract-conventions.md`
    - 도메인 명세 보강:
      - `wallet-payment-api.md` 신규 추가
      - `realtime-push-api.md` 신규 추가
      - `reservation-api.md` v4 경로/결제 side effect/v7 인증 경계 보강
      - `waiting-queue-api.md` WS 구독 등록/해제 계약 보강
      - `user-api.md` `walletBalanceAmount` 필드 반영
    - 테스트 가이드 보강:
      - `prj-docs/projects/ticket-core-service/product-docs/api-test/README.md`
      - `run-api-script-tests` 기본 세트(`v1~v14 + a*`) 및 `v13/v14` 검증 절차 반영

- TCS-SC-009 인증 세션 후속 회귀(로그아웃 경계/e2e) 보강
  - Status: DONE
  - Description:
    - 로그아웃 헤더 누락/토큰 재사용 실패 경계를 통합테스트로 고정
    - 프론트 연동 기준으로 auth-social 스크립트/명세 예외 케이스를 보강
  - Evidence:
    - 회의록: `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-19-auth-session-regression-followup-completion.md`
    - Product Issue: `rag-cargoo/ticket-core-service#7` (reopened -> closed)
    - Product PR: `rag-cargoo/ticket-core-service PR #9` (merged, cross-repo shorthand)
    - Merge Commit: `68c08e990f28a1e96f9f13daf29ee9a03f4f57f6`
    - Verification: `./gradlew test` pass

- TCS-SC-010 프론트 e2e 파이프라인 auth-social 자동 검증 연결
  - Status: DONE
  - Description:
    - auth-social 핵심 시나리오(로그인/재발급/로그아웃/재사용 차단)를 e2e 파이프라인에 자동 연결
    - CI 실행 시 필수/선택 구간 분리를 정의해 외부 OAuth 의존성 리스크를 관리
  - Evidence:
    - 회의록: `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-19-auth-social-e2e-pipeline-completion.md`
    - Product Issue: `rag-cargoo/ticket-core-service#10` (closed)
    - Product PR: `rag-cargoo/ticket-core-service PR #11` (merged, cross-repo shorthand)
    - Merge Commit: `b3343bd97b470ecbd1ee11848bc4554ad9f2c8f0`
    - Verification:
      - `./scripts/api/run-auth-social-e2e-pipeline.sh` pass
      - `make test-auth-social-pipeline` pass
      - `./gradlew test` pass

- TCS-SC-011 운영 auth 예외코드 집계/모니터링 기준 정리
  - Status: DONE
  - Description:
    - 로그아웃 실패/토큰 만료/무효 토큰 등 auth 예외코드 집계 기준 정의
    - 운영 대시보드 및 알람 임계치 기준을 문서화
  - Evidence:
    - 회의록: `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-19-auth-error-monitoring-criteria-completion.md`
    - Product Issue: `rag-cargoo/ticket-core-service#7` (reopened -> closed)
    - Product PR: `rag-cargoo/ticket-core-service PR #12` (merged, cross-repo shorthand)
    - Merge Commit: `cae3a9df6ef36e6fe0e9b41f6b5e554c7849851d`
    - Included:
      - `AUTH_*` 예외코드 표준화(`SecurityConfig`, `GlobalExceptionHandler`, `JwtAuthenticationFilter`)
      - auth 예외 응답 `errorCode` 필드 도입 + `AUTH_MONITOR` 로그 키 추가
      - `a2-auth-track-session-guard.sh`/`AuthSecurityIntegrationTest` 회귀 보강
      - API 명세/운영 임계치 문서 반영
    - Verification:
      - `./gradlew test --tests com.ticketrush.api.controller.AuthSecurityIntegrationTest` pass
      - `./scripts/api/run-auth-social-e2e-pipeline.sh` pass

- TCS-SC-012 외부 OAuth real provider E2E 경로 분리 운영
  - Status: DONE
  - Description:
    - CI-safe auth-social 파이프라인과 real provider E2E 경로를 분리해 선택 실행으로 운영
    - `application.yml` 플래그(`APP_AUTH_SOCIAL_REAL_E2E_ENABLED`) 기반으로 실운영 검증 절차를 명시
  - Evidence:
    - 회의록: `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-19-auth-social-real-provider-e2e-split-completion.md`
    - Product Issue: `rag-cargoo/ticket-core-service#10` (reopened -> closed)
    - Product PR: `rag-cargoo/ticket-core-service PR #14` (merged, cross-repo shorthand)
    - Merge Commit: `181088803826d0b235c5c15e320e21d9274594e6`
    - Included:
      - `scripts/api/run-auth-social-real-provider-e2e.sh` 신규(prepare-only + real code exchange 검증)
      - `app.social.real-e2e.enabled` 설정값 도입
      - `Makefile`/`README` real provider 선택 실행 절차 반영
    - Verification:
      - `bash -n scripts/api/run-auth-social-real-provider-e2e.sh` pass
      - `./gradlew test --tests com.ticketrush.api.controller.SocialAuthControllerIntegrationTest --tests com.ticketrush.domain.auth.service.SocialAuthServiceTest` pass

- TCS-SC-013 프론트 릴리즈 계약 체크리스트 고정 및 회의록 TODO 정합화
  - Status: DONE
  - Description:
    - 과거 완료 회의록의 잔존 `Status: TODO`를 완료 근거와 함께 정합화
    - `API Specs + API Test Guide + auth-social.http` 기준 프론트 릴리즈 계약 체크리스트 1장을 공개 문서로 고정
  - Evidence:
    - 회의록: `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-19-frontend-release-handoff-checklist-completion.md`
    - 정합화 대상:
      - `2026-02-18-realtime-transport-implementation-completion.md`
      - `2026-02-18-wallet-payment-ledger-implementation-completion.md`
      - `2026-02-19-auth-session-hardening-completion.md`
      - `2026-02-19-auth-session-regression-followup-completion.md`
      - `2026-02-19-api-spec-front-readiness-sync.md`
    - 신규 체크리스트:
      - `prj-docs/projects/ticket-core-service/product-docs/frontend-release-contract-checklist.md`
    - 이슈 동기화:
      - `rag-cargoo/aki-agentops#101` (reopened -> closed)

- TCS-SC-014 Playwright OAuth HITL + callback preflight 운영 규칙 고정
  - Status: DONE
  - Description:
    - 사용자 로그인/동의가 필요한 OAuth 요청에서 Playwright HITL을 기본으로 사용하도록 규칙을 고정
    - callback redirect 대상이 로컬 백엔드인 경우 인증 페이지 오픈 전 포트/헬스 preflight를 필수화
  - Evidence:
    - 회의록:
      - `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-19-playwright-oauth-hitl-preflight-governance-completion.md`
    - 반영 문서:
      - `AGENTS.md`
      - `skills/aki-mcp-playwright/SKILL.md`
      - `skills/aki-mcp-playwright/references/troubleshooting.md`
      - `skills/aki-mcp-playwright/references/setup-linux-wsl.md`
    - 신규 스크립트:
      - `skills/aki-mcp-playwright/scripts/preflight_callback_health.sh`
    - 이슈/PR 동기화:
      - `rag-cargoo/aki-agentops#114` (closed)
      - `https://github.com/rag-cargoo/aki-agentops/pull/115` (merged)

- TCS-SC-015 프론트 구현 사전준비 패키지 고정(오류/시간/실시간/핸드오프 증빙)
  - Status: DONE
  - Description:
    - 프론트 오류 파서를 `status/errorCode/message` 고정 스키마로 확정하고 에러코드 매핑 상수 테이블을 고정
    - `LocalDateTime` + `Instant(UTC)` 혼재 응답을 공통 시간 파싱 유틸 1개로 정리
    - 실시간 클라이언트 전략을 `WS 기본 + SSE 폴백`으로 확정(재연결/백오프/구독복구 포함)
    - 프론트 핸드오프 직전 `make test-suite` 1회 실행 + 리포트 최신화로 계약 증빙 고정
  - Evidence:
    - 회의록:
      - `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-19-frontend-preflight-preparation-plan.md`
      - `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-19-api-script-mode-aware-followup.md`
    - Tracking Issue:
      - `https://github.com/rag-cargoo/aki-agentops/issues/118`
      - `https://github.com/rag-cargoo/aki-agentops/issues/118#issuecomment-3925573862`
    - Baseline PR:
      - `https://github.com/rag-cargoo/aki-agentops/pull/119` (merged)
    - Baseline Product Commit:
      - `rag-cargoo/ticket-core-service@1988f2c`
    - Latest Verification:
      - `workspace/apps/backend/ticket-core-service/.codex/tmp/ticket-core-service/api-test/latest.md` (`Result: PASS`, `Push Mode: websocket`, `Skipped: v7-sse`)
      - `workspace/apps/backend/ticket-core-service/.codex/tmp/ticket-core-service/step7/20260219T084701Z/step7-regression.log` (`run-step7-regression.sh` completed, `PASS`)

- TCS-SC-016 프론트 앱 워크스페이스 생성 및 부트스트랩 시작
  - Status: DONE
  - Description:
    - 프론트 앱 서비스명을 `ticket-web-client`로 확정하고 작업 경로를 `workspace/apps/frontend/ticket-web-client`로 고정
    - 프론트 시작용 최소 골격(에러 파서/시간 유틸/실시간 어댑터) 생성으로 구현 착수 기반 확보
    - sidecar 문서/트래킹(회의록, task, issue)을 동기화하여 후속 화면 구현 단위를 이어서 진행 가능하도록 정리
  - Evidence:
    - 회의록:
      - `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-19-frontend-workspace-bootstrap-kickoff.md`
    - Tracking Issue:
      - `https://github.com/rag-cargoo/aki-agentops/issues/118` (closed)
      - `https://github.com/rag-cargoo/aki-agentops/issues/118#issuecomment-3925996197`
    - Workspace Path:
      - `workspace/apps/frontend/ticket-web-client`
      - `.gitignore`에 `workspace/apps/frontend/ticket-web-client/` 등록

- TCS-SC-017 콘서트 목록 판매상태/카운트다운 계약 + API probe 커버리지 보강
  - Status: DONE
  - Description:
    - 콘서트 목록/검색 응답에 `saleStatus` + 카운트다운 + 예매 CTA 제어 필드를 추가해 프론트 즉시 반응 기반을 제공
    - API 수동 검증(`scripts/http/concert.http`)과 자동 검증(`scripts/api/v15-concert-sale-status-contract.sh`) 커버리지를 보강
    - API 명세/테스트 가이드 문서를 새 계약 기준으로 동기화
  - Evidence:
    - 회의록:
      - `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-20-concert-sale-status-contract-and-probe-coverage.md`
    - Product Issue:
      - `https://github.com/rag-cargoo/ticket-core-service/issues/15`
      - `https://github.com/rag-cargoo/ticket-core-service/issues/15#issuecomment-3929234804`
    - Backend Contract:
      - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/api/dto/ConcertResponse.java`
      - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/domain/concert/service/ConcertServiceImpl.java`
      - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/domain/concert/repository/ConcertRepository.java`
    - Probe Coverage:
      - `workspace/apps/backend/ticket-core-service/scripts/http/concert.http`
      - `workspace/apps/backend/ticket-core-service/scripts/api/v15-concert-sale-status-contract.sh`
    - Verification:
      - `./gradlew test --tests com.ticketrush.domain.concert.service.ConcertExplorerIntegrationTest` PASS
      - `API_HOST=http://127.0.0.1:18081 bash scripts/api/v15-concert-sale-status-contract.sh` PASS

- TCS-SC-018 샘플 더미 시드 + 프론트 개발 연결 기본값 정렬
  - Status: DONE
  - Description:
    - `DataInitializer`에 샘플 더미 시드 토글(`APP_PORTFOLIO_SEED_ENABLED`)을 추가
    - CORS/WS 기본 허용 오리진에 `5173`, `4173`을 포함해 프론트 개발 연결 기본값을 정렬
    - 문서(`concert-api.md`, `api-test/README.md`, `social-auth-api.md`)를 새 런타임 기준으로 동기화
  - Evidence:
    - Backend Runtime:
      - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/DataInitializer.java`
      - `workspace/apps/backend/ticket-core-service/src/main/resources/application.yml`
      - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/global/config/SecurityConfig.java`
      - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/global/config/WebSocketConfig.java`
      - `workspace/apps/backend/ticket-core-service/docker-compose.yml`
    - Sidecar Docs:
    - `prj-docs/projects/ticket-core-service/product-docs/api-specs/concert-api.md`
    - `prj-docs/projects/ticket-core-service/product-docs/api-specs/social-auth-api.md`
    - `prj-docs/projects/ticket-core-service/product-docs/api-test/README.md`

- TCS-SC-019 관리자 운영 CRUD(콘서트/세션/가격/미디어) 구현 착수
  - Status: DOING
  - Description:
    - 운영 관리자 기준의 콘서트/세션/가격 정책 CRUD API를 추가해 프론트 서비스 화면 구현 기반을 마련한다.
    - 미디어는 YouTube URL 입력 + 이미지 multipart 업로드/썸네일 생성 파이프라인으로 분리한다.
    - 기존 테스트 중심 `setup/cleanup` 경로는 운영 API와 권한 경계를 분리해 정리한다.
  - Evidence:
    - 회의록:
      - `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-20-admin-ops-crud-and-media-pipeline-kickoff.md`
    - Product Issue:
      - `https://github.com/rag-cargoo/ticket-core-service/issues/16`
    - 구현 반영:
      - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/api/controller/AdminConcertController.java`
      - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/domain/concert/service/ConcertServiceImpl.java`
      - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/domain/reservation/service/ReservationLifecycleServiceImpl.java`
    - 검증:
      - `workspace/apps/backend/ticket-core-service/src/test/java/com/ticketrush/api/controller/AdminConcertControllerIntegrationTest.java` PASS
      - `workspace/apps/backend/ticket-core-service/src/test/java/com/ticketrush/domain/reservation/service/ReservationLifecyclePricingIntegrationTest.java` PASS
      - `./gradlew test` PASS
    - 범위 분리 근거:
      - `https://github.com/rag-cargoo/ticket-core-service/issues/15`는 목록 판매상태 계약 전용 범위
