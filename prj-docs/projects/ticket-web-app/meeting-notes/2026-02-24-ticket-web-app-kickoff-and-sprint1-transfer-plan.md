# Meeting Notes: Ticket Web App Kickoff and Sprint-1 Transfer Plan

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-24 08:27:00`
> - **Updated At**: `2026-02-24 08:27:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 킥오프 배경
> - 안건 2: 신규 레포/문서 기준선
> - 안건 3: Sprint-1 이관 범위
> - 안건 4: 다음 작업
<!-- DOC_TOC_END -->

## 안건 1: 킥오프 배경
- Status: DONE
- 배경:
  - 기존 `ticket-web-client`는 아카이브/참조로 유지하고, 프론트 구현은 신규 레포로 재시작하기로 결정했다.
  - 신규 레포명은 `ticket-web-app`으로 확정했다.

## 안건 2: 신규 레포/문서 기준선
- Status: DONE
- 결정:
  - 코드 저장소: `https://github.com/rag-cargoo/ticket-web-app`
  - 로컬 코드 루트: `workspace/apps/frontend/ticket-web-app`
  - sidecar 문서 루트: `prj-docs/projects/ticket-web-app`
  - project map 등록 및 active project 전환 준비를 완료한다.

## 안건 3: Sprint-1 이관 범위
- Status: DONE
- 결정:
  - 기존 `SC019` 이관 항목을 신규 프로젝트 Sprint-1 초기 범위로 고정한다.
  - 범위:
    - OAuth 세션 기반 인증 단일화
    - 예약/취소/환불 API v7 경로 정합
    - non-mock 실백엔드 smoke 검증
    - 예약 실시간 구독 seat snapshot 갱신 전략 보강

## 안건 4: 다음 작업
- Status: TODO
- 후속작업:
  - `TWA-SC-002` 앱 부트스트랩(Vite/React/TS + lint/typecheck/build + CI)
  - `TWA-SC-003` Sprint-1 계약 정렬 착수
