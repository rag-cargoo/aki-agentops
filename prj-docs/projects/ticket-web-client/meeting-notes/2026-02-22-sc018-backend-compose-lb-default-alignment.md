# Meeting Notes: SC018 Backend Compose LB Default Alignment (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-22 22:57:35`
> - **Updated At**: `2026-02-22 23:00:52`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 백엔드 분산 기본 진입점 정렬
> - 안건 2: 이슈 라이프사이클 적용(#5 재오픈)
> - 안건 3: task 동기화
> - 안건 4: 구현/검증
<!-- DOC_TOC_END -->

## 안건 1: 백엔드 분산 기본 진입점 정렬
- Status: DONE
- 결정사항:
  - backend compose 기본 진입점이 LB `http://127.0.0.1:18080`로 통합됐으므로 프론트 dev proxy 기본 타깃도 `:18080`으로 정렬한다.
  - `VITE_API_BASE_URL=/api` 기본값은 유지하고, `VITE_DEV_PROXY_TARGET` 기본값만 LB 기준으로 상향한다.
  - backend `bootRun` 직결 개발은 `VITE_DEV_PROXY_TARGET=http://127.0.0.1:8080` override로 처리한다.

## 안건 2: 이슈 라이프사이클 적용(#5 재오픈)
- Status: DONE
- 처리결과:
  - 같은 실시간/런타임 연결 범위 후속으로 `ticket-web-client#5`를 재오픈했다.
  - 신규 이슈 생성 없이 기존 이슈에 SC018 후속 범위를 코멘트로 누적했다.
  - 제품 PR `#13` 머지 완료 후 이슈 `#5`는 `CLOSED`로 종료됐다.
- 링크:
  - 이슈: `ticket-web-client Issue #5`
  - 코멘트: `ticket-web-client Issue #5 comment 3940970608`
  - PR: `rag-cargoo/ticket-web-client PR #13`

## 안건 3: task 동기화
- Status: DONE
- 처리결과:
  - sidecar task에 `TWC-SC-018` 항목을 추가하고 구현/검증 완료 기준으로 `DONE` 처리한다.
  - meeting notes index + sidebar manifest에 신규 노트 링크를 반영한다.

## 안건 4: 구현/검증
- Status: DONE
- 구현 결과:
  - `vite.config.ts`의 `VITE_DEV_PROXY_TARGET` 기본값을 `http://127.0.0.1:18080`으로 변경했다.
  - `.env.example`의 split-domain/WS 예시와 dev proxy 기본값을 LB 기준으로 갱신했다.
  - `README.md`의 compose 실행 예시와 환경변수 가이드를 backend compose 기본 운영에 맞게 정렬했다.
- 검증 결과:
  - `npm run typecheck` PASS
- 증빙:
  - `workspace/apps/frontend/ticket-web-client/vite.config.ts`
  - `workspace/apps/frontend/ticket-web-client/.env.example`
  - `workspace/apps/frontend/ticket-web-client/README.md`
  - `rag-cargoo/ticket-web-client PR #13`
