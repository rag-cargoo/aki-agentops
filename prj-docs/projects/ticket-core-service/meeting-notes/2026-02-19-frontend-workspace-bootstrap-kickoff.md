# Meeting Notes: Frontend Workspace Bootstrap Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 18:46:48`
> - **Updated At**: `2026-02-19 18:46:48`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 프론트 앱 워크스페이스 경로 확정
> - 안건 2: 최소 시작 골격 생성 범위 확정
> - 안건 3: 후속 TODO
> - 안건 4: 이슈/태스크 동기화
<!-- DOC_TOC_END -->

## 안건 1: 프론트 앱 워크스페이스 경로 확정
- Created At: 2026-02-19 18:46:48
- Updated At: 2026-02-19 18:46:48
- Status: DONE
- 결정사항:
  - 서비스명은 `ticket-web-client`로 고정한다.
  - 경로는 `workspace/apps/frontend/ticket-web-client`를 표준으로 사용한다.
  - sidecar 루트 레포는 외부 앱 워크스페이스를 추적하지 않도록 `.gitignore`에 경로를 등록한다.

## 안건 2: 최소 시작 골격 생성 범위 확정
- Created At: 2026-02-19 18:46:48
- Updated At: 2026-02-19 18:46:48
- Status: DONE
- 처리사항:
  - 아래 파일을 기반으로 프론트 시작 골격을 생성했다.
    - `workspace/apps/frontend/ticket-web-client/package.json`
    - `workspace/apps/frontend/ticket-web-client/src/shared/api/normalize-api-error.ts`
    - `workspace/apps/frontend/ticket-web-client/src/shared/time/parse-server-date-time.ts`
    - `workspace/apps/frontend/ticket-web-client/src/shared/realtime/create-realtime-client.ts`
  - 최소 골격 목적:
    - 오류 파서: `status/errorCode/message` 고정
    - 시간 파서: `LocalDateTime` + `Instant(UTC)` 혼재 대응
    - 실시간 어댑터: `websocket` 우선 + `sse` fallback

## 안건 3: 후속 TODO
- Created At: 2026-02-19 18:46:48
- Updated At: 2026-02-19 18:46:48
- Status: DOING
- TODO:
  - [x] `workspace/apps/frontend/ticket-web-client` 경로 생성
  - [x] 최소 부트스트랩(에러/시간/실시간 어댑터) 파일 생성
  - [ ] 프론트 원격 저장소 URL 확정 및 초기 푸시 기준 정리
  - [ ] 실제 화면 레이어(API client/auth/session/realtime state) 작업 분할

## 안건 4: 이슈/태스크 동기화
- Created At: 2026-02-19 18:46:48
- Updated At: 2026-02-19 18:46:48
- Status: DONE
- 처리사항:
  - Tracking Issue: `https://github.com/rag-cargoo/aki-agentops/issues/118` (reopened)
  - Issue Comment: `https://github.com/rag-cargoo/aki-agentops/issues/118#issuecomment-3925996197`
  - Task: `prj-docs/projects/ticket-core-service/task.md` (`TCS-SC-016`)
