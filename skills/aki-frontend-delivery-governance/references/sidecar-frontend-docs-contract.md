# Sidecar Frontend Docs Contract

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 21:05:00`
> - **Updated At**: `2026-02-20 02:45:00`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Purpose
> - Required Files
> - Feature Spec Format
> - Playwright Runbook Format
<!-- DOC_TOC_END -->

## Purpose
- 글로벌 스킬과 프로젝트 상세 문서를 분리해 유지한다.
- 코덱스 이용자가 프로젝트별 문서만 읽어도 테스트/시연을 재현할 수 있게 한다.

## Required Files
- `prj-docs/projects/<service>/README.md`
- `prj-docs/projects/<service>/PROJECT_AGENT.md`
- `prj-docs/projects/<service>/task.md`
- `prj-docs/projects/<service>/meeting-notes/README.md`
- `prj-docs/projects/<service>/product-docs/frontend-feature-spec.md`
- `prj-docs/projects/<service>/testing/playwright-suite-catalog.md`
- `prj-docs/projects/<service>/testing/playwright-runbook.md`
- `prj-docs/projects/<service>/testing/playwright-execution-history.md`

## Feature Spec Format
1. 범위와 목표
2. 화면/기능 분해
3. API/실시간 연동 포인트
4. 실패/복구 전략
5. Playwright 검증 매핑

## Playwright Runbook Format
1. 실행 전 체크리스트(앱 기동/환경변수)
2. 파트별 테스트 목록
3. 파트별 실행 명령
4. 전체 실행 명령
5. 로그 경로/검증 판정 기준

## Execution History Format
1. 표(Table) 기반 실행 이력 누적(append-only)
2. 최소 컬럼: `Executed At`, `Scope`, `Result`, `Run ID`, `Summary`, `Log`
3. 각 row는 전역 래퍼 실행 결과와 1:1 대응
