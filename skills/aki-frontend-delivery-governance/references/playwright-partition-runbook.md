# Playwright Partition Runbook (Frontend)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 21:05:00`
> - **Updated At**: `2026-02-20 02:20:00`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope Matrix
> - List First Contract
> - Run Contract
> - Evidence Contract
<!-- DOC_TOC_END -->

## Scope Matrix
- `smoke`: 페이지 부팅/핵심 레이아웃
- `nav`: 메뉴/앵커/탭 전환
- `contract`: API/시간/에러 파서 노출값
- `auth`: 인증/세션 상태 전이 및 보호 API 결과 검증
- `realtime`: WS/SSE fallback 상태/로그 검증
- `all`: 전체 시나리오

## List First Contract
1. 실행 전 목록을 먼저 보여준다.
2. 실행 대상이 불명확하면 사용자 선택을 받는다.
3. 기본 명령:
```bash
./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root <path> --list
```

## Run Contract
- Scope 지정 실행:
```bash
./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root <path> --scope smoke
./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root <path> --scope nav
./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root <path> --scope contract
./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root <path> --scope auth
./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root <path> --scope realtime
./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root <path> --scope all
```

## Evidence Contract
- 기본 경로:
  - `.codex/tmp/frontend-playwright/<service>/<run-id>/run.log`
  - `.codex/tmp/frontend-playwright/<service>/<run-id>/summary.txt`
- 이력 문서:
  - `prj-docs/projects/<service>/testing/playwright-execution-history.md`
- 필수 보고:
  - 실행 scope
  - pass/fail
  - console log 포함 여부
  - 실패 시 재실행 명령
