# Meeting Notes: Frontend Governance and Playwright Baseline (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 21:12:00`
> - **Updated At**: `2026-02-19 21:26:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 글로벌 프론트 규칙 스킬 분리
> - 안건 2: 프로젝트 전용 기능 문서 정착
> - 안건 3: Playwright 파트별 시연/검증 계약
> - 안건 4: 장기 공백 리마인더 자동화
> - 안건 5: 후속 TODO
<!-- DOC_TOC_END -->

## 안건 1: 글로벌 프론트 규칙 스킬 분리
- Status: DONE
- 결정사항:
  - `aki-frontend` 규칙은 특정 서비스(`ticket-web-client`)에 종속하지 않는다.
  - 전역 규칙은 `skills/aki-frontend-delivery-governance`에 고정한다.

## 안건 2: 프로젝트 전용 기능 문서 정착
- Status: DONE
- 결정사항:
  - `ticket-web-client` 기능 상세/실행 가이드는 sidecar(`prj-docs/projects/ticket-web-client`)에 기록한다.
  - 제품 코드 변경과 분리해 운영 문서 SoT를 유지한다.

## 안건 3: Playwright 파트별 시연/검증 계약
- Status: DONE
- 결정사항:
  - 실행 전 테스트 목록을 먼저 보여준다.
  - scope(`smoke/nav/contract/all`) 단위로 선택 실행한다.
  - 콘솔 로그 키를 검증 항목으로 포함한다.
  - 증빙은 로그/요약 파일 경로를 표준으로 보고한다.

## 안건 4: 장기 공백 리마인더 자동화
- Status: DONE
- 결정사항:
  - 프론트 Active Project일 때 `session_start.sh` 결과에 Frontend Quick Remind를 자동 노출한다.
  - 복귀 사용자를 위해 공개 문서 `frontend-long-gap-recall-card.md`를 유지한다.

## 안건 5: 후속 TODO
- [ ] 실시간(WS/SSE) 시나리오 e2e 스펙 추가
- [ ] auth/session 시나리오 e2e 스펙 추가
- [ ] CI 파이프라인에 e2e smoke/nightly 분리 전략 반영
