# Task Dashboard (ticket-web-app sidecar)

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
> - Scope
> - Checklist
> - Current Items
> - Next Items
<!-- DOC_TOC_END -->

## Scope
- 이 문서는 `ticket-web-app` 운영 sidecar 태스크를 관리한다.
- 구현 상세 태스크는 제품 레포 이슈/PR에서 관리한다.

## Checklist
- [x] TWA-SC-001 신규 프론트 레포 생성 + sidecar 등록 + active project 전환
- [ ] TWA-SC-002 앱 부트스트랩(Vite/React/TS + lint/typecheck/build + CI)
- [ ] TWA-SC-003 SC019 이관 Sprint-1(토큰 정책/예약 API 경로/non-mock smoke)

## Current Items
- TWA-SC-001 신규 프론트 레포 생성 + sidecar 등록 + active project 전환
  - Status: DONE
  - Description:
    - 신규 제품 레포 `ticket-web-app`을 생성하고 로컬 클론을 `workspace/apps/frontend/ticket-web-app`으로 고정한다.
    - `project-map.yaml`에 새 프로젝트를 등록한다.
    - sidecar 기본 문서(`README`, `PROJECT_AGENT`, `task`, `meeting-notes/README`, `rules/`)를 생성한다.
  - Evidence:
    - `https://github.com/rag-cargoo/ticket-web-app`
    - `workspace/apps/frontend/ticket-web-app`
    - `prj-docs/projects/project-map.yaml`
    - `prj-docs/projects/ticket-web-app/README.md`
    - `prj-docs/projects/ticket-web-app/PROJECT_AGENT.md`
    - `prj-docs/projects/ticket-web-app/task.md`
    - `prj-docs/projects/ticket-web-app/meeting-notes/README.md`
    - `prj-docs/projects/ticket-web-app/rules/architecture.md`

- TWA-SC-002 앱 부트스트랩(Vite/React/TS + lint/typecheck/build + CI)
  - Status: TODO
  - Description:
    - 프론트 앱 런타임 골격(Vite + React + TypeScript)을 구축한다.
    - 최소 품질 게이트(`lint`, `typecheck`, `build`)와 GitHub Actions CI를 연결한다.
    - 개발 기본값(`.env.example`, API base, WS base)을 문서와 함께 고정한다.

- TWA-SC-003 SC019 이관 Sprint-1(토큰 정책/예약 API 경로/non-mock smoke)
  - Status: TODO
  - Description:
    - 기존 `ticket-web-client`의 SC019 이관 범위를 신규 프로젝트 코드베이스에 적용한다.
    - 서비스 화면 인증 정책을 OAuth 세션 단일화로 고정한다.
    - 예약/취소/환불 API를 백엔드 단건 v7 계약으로 정렬하고 non-mock smoke 검증을 추가한다.

## Next Items
- `TWA-SC-002` 우선 착수(앱 부트스트랩 + CI 기본 게이트)
