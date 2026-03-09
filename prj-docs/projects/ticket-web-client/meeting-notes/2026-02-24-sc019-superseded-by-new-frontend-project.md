# Meeting Notes: SC019 Superseded by New Frontend Project (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-24 06:59:00`
> - **Updated At**: `2026-02-24 06:59:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: SC019 종료 결정
> - 안건 3: 이관 범위
> - 안건 4: task 동기화
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - `TWC-SC-019`는 기존 프론트에서 서비스 계약 정렬을 수행하기 위한 후속 항목으로 생성됐다.
  - 사용자 결정에 따라 프론트는 기존 코드 연장이 아니라 신규 프로젝트 신설로 전환한다.

## 안건 2: SC019 종료 결정
- Status: DONE
- 결정:
  - `TWC-SC-019`는 기존 `ticket-web-client` 기준으로 `DONE(대체 종료)` 처리한다.
  - 종료 사유:
    - 구현 중단이 아니라 실행 컨텍스트를 신규 프론트 프로젝트로 이전한다.
    - 기존 리포는 아카이브/참조 용도로 유지한다.

## 안건 3: 이관 범위
- Status: DONE
- 신규 프론트 Sprint-1 인수 항목:
  - OAuth 세션 기반 인증 단일화(수동 토큰 입력 제거)
  - 예약/취소/환불 API 경로를 백엔드 단건 v7 계약에 정렬
  - non-mock 실백엔드 smoke 검증 추가
  - 예약 실시간 구독 seat snapshot 갱신 전략 보강

## 안건 4: task 동기화
- Status: DONE
- 반영:
  - `prj-docs/projects/ticket-web-client/task.md`
    - `TWC-SC-019` Status: `TODO` -> `DONE`
    - `Next Items`를 신규 프론트 프로젝트 착수 기준으로 갱신
