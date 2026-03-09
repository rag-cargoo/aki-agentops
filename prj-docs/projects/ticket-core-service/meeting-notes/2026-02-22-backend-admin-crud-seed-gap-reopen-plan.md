# Meeting Notes: Backend Admin CRUD + Seed Gap Reopen Plan (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-22 23:59:30`
> - **Updated At**: `2026-02-23 06:31:07`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 점검 범위
> - 안건 2: 코드/계약 핵심 발견사항
> - 안건 3: 이슈 라이프사이클 적용(#16 재오픈)
> - 안건 4: task 동기화(TCS-SC-025)
> - 안건 5: 구현 우선순위(1/2/3)
<!-- DOC_TOC_END -->

## 안건 1: 점검 범위
- Status: DONE
- 범위:
  - 백엔드 `main` 기준 Admin 운영 CRUD(콘서트/회차/가격/미디어) 제공 상태 점검
  - 프론트 관리자 API 계약(`ticket-web-client`)과 런타임 매핑 정합성 대조
  - 카탈로그(Entertainment/Artist) 조회 확장성과 초기 시드 전략 점검

## 안건 2: 코드/계약 핵심 발견사항
- Status: DONE
- 발견사항:
  - `Critical`: `main` 기준 `/api/admin/concerts/**` 운영 CRUD 컨트롤러가 없음
    - 현재 `ConcertController`는 `/api/concerts/**` 공개 조회 + 테스트용 `setup/cleanup` 중심
  - `High`: 프론트 관리자 API 클라이언트/테스트는 `/api/admin/concerts/**`를 전제로 구현되어 계약 불일치 위험이 큼
  - `Medium`: `Entertainment/Artist`는 기본 CRUD(`create/getAll/getById/update/delete`)만 존재하며 Admin 보드용 `find/search/paging` 경로가 없음
  - `Medium`: `DataInitializer`는 admin 유저 1건만 생성하고 운영/데모 초기 데이터 시드 전략이 비어 있음
  - `Medium`: 과거 관리자 CRUD 구현 커밋(`eec88b0`, `732c6be`)은 `feat/admin-ops-crud-media-20260220` 브랜치에 있으나 `main`에 미반영

## 안건 3: 이슈 라이프사이클 적용(#16 재오픈)
- Status: DONE
- 처리결과:
  - 동일 범위 후속작업으로 `ticket-core-service Issue #16`을 재오픈했다.
  - 신규 이슈 생성 대신 기존 이슈에 재오픈 사유/현재 갭/재착수 범위를 코멘트로 누적했다.
- 링크:
  - Issue: `https://github.com/rag-cargoo/ticket-core-service/issues/16` (reopened)
  - Progress Comment: `https://github.com/rag-cargoo/ticket-core-service/issues/16#issuecomment-3941319649`

## 안건 4: task 동기화(TCS-SC-025)
- Status: DONE
- 처리결과:
  - sidecar task에 `TCS-SC-025`를 `TODO`로 추가해 백엔드 복구 트랙을 분리했다.
  - meeting notes index + sidebar manifest에 신규 회의록 링크를 반영한다.

## 안건 5: 구현 우선순위(1/2/3)
- Status: DONE
- 우선순위:
  - 1) Admin Concert CRUD 복구: `/api/admin/concerts/**` + 회차 가격 + 판매정책 + 썸네일 경로를 `main` 기준으로 정렬
  - 2) Catalog 조회 확장: Entertainment/Artist Admin 보드에서 쓰는 `find/search/paging` 경로 추가
  - 3) Seed 전략 확정: dev/demo profile 분리 + idempotent 초기 데이터(공연/엔터테인먼트/아티스트/주최사/회차) + 문서/스크립트 동기화

## 증빙
- 백엔드 코드:
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/api/controller/ConcertController.java`
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/api/controller/EntertainmentCatalogController.java`
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/api/controller/ArtistController.java`
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/DataInitializer.java`
- 프론트 계약:
  - `workspace/apps/frontend/ticket-web-client/src/shared/api/admin-concert-client.ts`
  - `workspace/apps/frontend/ticket-web-client/tests/e2e/landing.spec.ts`
- Git 상태:
  - `workspace/apps/backend/ticket-core-service` branch: `main`
  - 관리자 CRUD 후보 커밋: `eec88b0`, `732c6be` (`feat/admin-ops-crud-media-20260220`)
