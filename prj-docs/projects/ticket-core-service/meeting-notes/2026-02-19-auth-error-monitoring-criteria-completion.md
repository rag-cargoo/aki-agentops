# Meeting Notes: Auth Error Monitoring Criteria Completion (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 04:05:21`
> - **Updated At**: `2026-02-19 04:05:21`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 운영 auth 예외코드 기준 완료
> - 안건 2: 구현/검증 상세
> - 안건 3: 문서/운영 기준 동기화
<!-- DOC_TOC_END -->

## 안건 1: 운영 auth 예외코드 기준 완료
- Created At: 2026-02-19 04:05:21
- Updated At: 2026-02-19 04:05:21
- Status: DONE
- 결정사항:
  - 제품 이슈 `rag-cargoo/ticket-core-service#7` 재오픈 후 완료(CLOSED)
  - 구현 PR `rag-cargoo/ticket-core-service PR #12` 머지 완료
  - 머지 커밋 `cae3a9df6ef36e6fe0e9b41f6b5e554c7849851d`

## 안건 2: 구현/검증 상세
- Created At: 2026-02-19 04:05:21
- Updated At: 2026-02-19 04:05:21
- Status: DONE
- Checklist:
  - [x] 보안 계층(401/403) 응답에 `errorCode` 표준 필드 추가
  - [x] auth path(400) 예외 응답을 `errorCode` 포함 JSON으로 표준화
  - [x] 운영 로그 키 `AUTH_MONITOR` 추가(code/status/method/path/detail)
  - [x] `a2-auth-track-session-guard.sh`에서 auth errorCode 회귀 검증 추가
  - [x] `AuthSecurityIntegrationTest`에 errorCode 계약 검증 추가
  - [x] 로컬 검증:
    - `./gradlew test --tests com.ticketrush.api.controller.AuthSecurityIntegrationTest`
    - `./scripts/api/run-auth-social-e2e-pipeline.sh`

## 안건 3: 문서/운영 기준 동기화
- Created At: 2026-02-19 04:05:21
- Updated At: 2026-02-19 04:05:21
- Status: DONE
- 반영사항:
  - `API Contract Conventions`에 auth 오류 응답(`errorCode`) 및 코드 테이블 반영
  - `Auth Session API`에 운영 집계 코드/임계치 기준 반영
  - `Auth Error Monitoring Guide` 신규 추가(대시보드/알람 기준)
  - `API Test Guide`에 auth 예외코드 확인 및 집계 점검 절차 반영
