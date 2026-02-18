# Ticket Core Service API Specs

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 17:03:13`
> - **Updated At**: `2026-02-19 06:08:30`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - API Specs
> - Notes
<!-- DOC_TOC_END -->

## API Specs
- [API Contract Conventions](./api-contract-conventions.md)
- [Auth Session API](./auth-session-api.md)
- [Auth Error Monitoring Guide](./auth-error-monitoring-guide.md)
- [User API](./user-api.md)
- [Wallet/Payment API](./wallet-payment-api.md)
- [Catalog API (Agency/Artist)](./catalog-api.md)
- [Concert API](./concert-api.md)
- [Reservation API](./reservation-api.md)
- [Waiting Queue API](./waiting-queue-api.md)
- [Realtime Push API (SSE/WebSocket)](./realtime-push-api.md)
- [Social Auth API](./social-auth-api.md)
- [Frontend Release Contract Checklist](../frontend-release-contract-checklist.md)

## Notes
- 본 문서는 `AKI AgentOps` sidecar가 관리하는 공개 API 명세 인덱스다.
- API 명세 변경은 `rag-cargoo/aki-agentops`의 sidecar 문서 PR에서 반영한다.
- 프론트 구현 계약 기준 문서는 `API Contract Conventions` + 각 도메인 API 문서를 함께 기준으로 본다.
- 프론트 핸드오프는 `Frontend Release Contract Checklist`를 릴리즈 게이트로 사용한다.
