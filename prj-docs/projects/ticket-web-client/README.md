# Ticket Web Client Sidecar Docs

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 20:36:00`
> - **Updated At**: `2026-02-19 22:15:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Source of Truth
> - Sidecar Docs
> - Operation Rule
> - Playwright Verification
<!-- DOC_TOC_END -->

## Source of Truth
- Code Repository: [rag-cargoo/ticket-web-client](https://github.com/rag-cargoo/ticket-web-client)
- Local Clone Root: `workspace/apps/frontend/ticket-web-client`

## Sidecar Docs
- [Task Dashboard](./task.md)
- [Meeting Notes Index](./meeting-notes/README.md)
- [Project Agent](./PROJECT_AGENT.md)
- [Architecture Rule](./rules/architecture.md)
- [Frontend Feature Spec](./product-docs/frontend-feature-spec.md)
- [Playwright Suite Catalog](./testing/playwright-suite-catalog.md)
- [Playwright Runbook](./testing/playwright-runbook.md)
- [Frontend Long-Gap Recall Card](/prj-docs/references/frontend-long-gap-recall-card.md)

## Operation Rule
- 제품 코드/테스트 변경은 `ticket-web-client` 레포에서 커밋/PR 처리한다.
- 본 sidecar는 운영 회의록/태스크/연결 규칙을 관리한다.

## Playwright Verification
- 실행 전 목록 제시(list-first) 후 사용자 선택 scope를 실행한다.
- 파트별 실행: `smoke`, `nav`, `contract`, `realtime`
- 전체 실행: `all`
