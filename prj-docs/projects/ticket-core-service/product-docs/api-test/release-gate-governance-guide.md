# Release Gate Governance Guide

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-24 04:23:00`
> - **Updated At**: `2026-02-24 04:23:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 1) 로컬 게이트 실행
> - 2) CI 게이트
> - 3) 머지 기준
> - 4) 산출물
<!-- DOC_TOC_END -->

릴리즈 전 검증 게이트와 증빙 규칙을 정의합니다.

## 1) 로컬 게이트 실행

```bash
cd workspace/apps/backend/ticket-core-service
make test-release-gate
```

선택적으로 API 스크립트까지 포함하려면:

```bash
RELEASE_GATE_WITH_API_SCRIPTS=true make test-release-gate
```

## 2) CI 게이트

- `.github/workflows/verify.yml`
  - compile
  - ArchUnit + 핵심 회귀 테스트
- `.github/workflows/runtime-integration-smoke.yml`
  - 런타임 의존 통합 테스트(수동/대상 변경 PR)

## 3) 머지 기준

1. verify workflow 통과
2. 필요 시 runtime integration smoke 증빙 확보
3. release gate 리포트를 이슈/회의록에 링크

## 4) 산출물

- `.codex/tmp/ticket-core-service/release-gate/latest/release-gate-latest.md`
- `.codex/tmp/ticket-core-service/release-gate/<run-id>/release-gate.log`
