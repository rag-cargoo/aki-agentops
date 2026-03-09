# Ticket Core Service Sidecar Docs

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 05:11:38`
> - **Updated At**: `2026-02-23 20:30:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Source of Truth
> - Sidecar Docs
> - External Product Docs
> - Operation Rule
<!-- DOC_TOC_END -->

## Source of Truth
- Code Repository: [rag-cargoo/ticket-core-service](https://github.com/rag-cargoo/ticket-core-service)
- Local Clone Root: `workspace/apps/backend/ticket-core-service`

## Sidecar Docs
- [Task Dashboard](./task.md)
- [Meeting Notes Index](./meeting-notes/README.md)
- [Project Agent](./PROJECT_AGENT.md)
- [Architecture Rule](./rules/architecture.md)

## External Product Docs
- Service README (Pages Docs):
  - [product-docs/README.md](./product-docs/README.md)
- Architecture Knowledge (Pages Docs):
  - [Knowledge Index](./product-docs/knowledge/README.md)
  - [DDD + Hexagonal Guide (Glossary)](./product-docs/knowledge/ddd-hexagonal-guide.md)
- API Specs (Pages Docs):
  - [API Specs Index](./product-docs/api-specs/README.md)
  - [API Contract Conventions](./product-docs/api-specs/api-contract-conventions.md)
  - [Auth Session API](./product-docs/api-specs/auth-session-api.md)
  - [User API](./product-docs/api-specs/user-api.md)
  - [Wallet/Payment API](./product-docs/api-specs/wallet-payment-api.md)
  - [Concert API](./product-docs/api-specs/concert-api.md)
  - [Reservation API](./product-docs/api-specs/reservation-api.md)
  - [Waiting Queue API](./product-docs/api-specs/waiting-queue-api.md)
  - [Realtime Push API (SSE/WebSocket)](./product-docs/api-specs/realtime-push-api.md)
  - [Social Auth API](./product-docs/api-specs/social-auth-api.md)
- API Test Guide (Pages Docs):
  - [product-docs/api-test/README.md](./product-docs/api-test/README.md)
- Frontend Release Contract Checklist (Pages Docs):
  - [product-docs/frontend-release-contract-checklist.md](./product-docs/frontend-release-contract-checklist.md)
- Upstream Repository:
  - [rag-cargoo/ticket-core-service](https://github.com/rag-cargoo/ticket-core-service)

## Operation Rule
- 제품 코드/테스트 변경은 `ticket-core-service` 레포에서만 커밋/PR 처리한다.
- 본 sidecar는 운영 메모/체크리스트/회의록을 관리한다.
