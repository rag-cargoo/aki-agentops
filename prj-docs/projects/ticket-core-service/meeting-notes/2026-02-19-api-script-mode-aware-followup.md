# Meeting Notes: API Script Mode-Aware Follow-up (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 17:28:28`
> - **Updated At**: `2026-02-19 17:53:50`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: API script-suite 실패 원인 분리
> - 안건 2: 모드 인식 실행 정책 정리
> - 안건 3: 후속 TODO
> - 안건 4: 이슈/태스크 동기화
<!-- DOC_TOC_END -->

## 안건 1: API script-suite 실패 원인 분리
- Created At: 2026-02-19 17:28:28
- Updated At: 2026-02-19 17:28:28
- Status: DONE
- 확인사항:
  - 동일 코드 기준 재검증에서 `13/15` pass 확인
  - `v11-abuse-audit.sh` 실패는 최신 옵션 좌석 수 조건(최소 8석) 미충족 데이터 상태 영향
  - `v7-sse-rank-push.sh` 실패는 기본 `APP_PUSH_MODE=websocket` 환경에서 SSE 전용 검증을 직접 실행한 모드 불일치 영향
  - 로컬 환경에서 샌드박스 네트워크 제약이 겹치면 `127.0.0.1:8080` 헬스체크가 false negative를 낼 수 있음을 확인

## 안건 2: 모드 인식 실행 정책 정리
- Created At: 2026-02-19 17:28:28
- Updated At: 2026-02-19 17:34:39
- Status: DONE
- 결정사항:
  - `run-api-script-tests.sh`는 실행 전 `APP_PUSH_MODE`를 기준으로 모드 불일치 스크립트를 `SKIP` 처리한다.
  - `v7`은 SSE 전용 검증으로 간주하고, 기본 `websocket` 모드에서는 `run-step7-regression.sh`로 별도 검증한다.
  - `v13`은 WebSocket 전용 검증으로 간주하고, `sse` 고정 모드 실행에서는 `SKIP` 또는 별도 트랙으로 분리한다.
  - 실제 반영 파일:
    - `workspace/apps/backend/ticket-core-service/scripts/api/run-api-script-tests.sh`
    - `workspace/apps/backend/ticket-core-service/scripts/api/v11-abuse-audit.sh`

## 안건 3: 후속 TODO
- Created At: 2026-02-19 17:28:28
- Updated At: 2026-02-19 17:53:50
- Status: DONE
- TODO:
  - [x] `scripts/api/run-api-script-tests.sh`에 모드 인식(`APP_PUSH_MODE`) + `SKIP` 리포트 로직 반영
  - [x] `scripts/api/v11-abuse-audit.sh` 좌석 8개 미만일 때 `setup-test-data.sh` fallback 후 재평가 로직 반영
  - [x] 증빙 재실행: `make test-suite` (기본 `websocket` 모드) -> `PASS(14)`, `SKIP(1=v7)`
  - [x] 증빙 재실행: `bash scripts/api/run-step7-regression.sh` (`STEP7_PUSH_MODE=sse`) -> `PASS(1), SKIP(0)`
  - [x] `frontend-release-contract-checklist.md`의 C5 상태/증빙 링크 최신화

## 안건 4: 이슈/태스크 동기화
- Created At: 2026-02-19 17:28:28
- Updated At: 2026-02-19 17:35:34
- Status: DONE
- 처리사항:
  - Tracking Issue: `https://github.com/rag-cargoo/aki-agentops/issues/118`
  - Issue Comment: `https://github.com/rag-cargoo/aki-agentops/issues/118#issuecomment-3925573862`
  - Task: `prj-docs/projects/ticket-core-service/task.md` (`TCS-SC-015`)
