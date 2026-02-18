# Meeting Notes: Playwright OAuth HITL + Callback Preflight Governance Completion (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 06:53:46`
> - **Updated At**: `2026-02-19 06:53:46`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 재발 원인 확정
> - 안건 2: 규칙/스킬 고정 반영
> - 안건 3: 운영 적용 결론
<!-- DOC_TOC_END -->

## 안건 1: 재발 원인 확정
- Created At: 2026-02-19 06:53:46
- Updated At: 2026-02-19 06:53:46
- Status: DONE
- 결정사항:
  - OAuth 로그인 자체는 성공해도 callback redirect 시점에 로컬 백엔드가 미기동이면 `ERR_CONNECTION_REFUSED`가 재발한다.
  - 인증/인가 요청에서 Playwright 페이지 오픈보다 callback preflight를 먼저 수행해야 한다.

## 안건 2: 규칙/스킬 고정 반영
- Created At: 2026-02-19 06:53:46
- Updated At: 2026-02-19 06:53:46
- Status: DONE
- 반영사항:
  - 전역 규칙:
    - `AGENTS.md`에 OAuth/SSO 요청 시 `aki-mcp-playwright` 우선 로드 + callback preflight 강제 규칙 추가
  - Playwright 스킬:
    - `skills/aki-mcp-playwright/SKILL.md`에 HITL 운영 절차 및 preflight 단계 추가
    - `skills/aki-mcp-playwright/scripts/preflight_callback_health.sh` 신규 추가
  - 레퍼런스:
    - `skills/aki-mcp-playwright/references/troubleshooting.md`에 `ERR_CONNECTION_REFUSED` 대응 항목 추가
    - `skills/aki-mcp-playwright/references/setup-linux-wsl.md`에 callback preflight 절차 추가

## 안건 3: 운영 적용 결론
- Created At: 2026-02-19 06:53:46
- Updated At: 2026-02-19 06:53:46
- Status: DONE
- 결론:
  - 인증 필요 요청에서 기본 순서를 `preflight -> Playwright open -> user login/consent -> execute`로 고정한다.
  - 관련 이슈/PR:
    - Issue: `rag-cargoo/aki-agentops#114` (closed)
    - PR: `https://github.com/rag-cargoo/aki-agentops/pull/115` (merged)
