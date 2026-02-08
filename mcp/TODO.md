# MCP Ops TODO

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-08 23:11:27`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Backlog
> - Done
<!-- DOC_TOC_END -->

> MCP 운영/자동화 개선 작업을 추적한다.

---

## Backlog

- [ ] `mcp/manifest/mcp-manifest.sh` 항목을 실제 사용 MCP 기준으로 정리
- [ ] Playwright MCP 스킬과 `mcp/` 런타임 운영 문서 간 역할 경계 리팩토링
- [ ] `mcp/scripts/mcp_sync.sh` 결과를 `mcp/references/experience-log.md`에 반자동 기록하는 스크립트 검토
- [ ] 정책 프로필(`dev`, `corp`, `ci`)별 기본 `MCP_INSTALL_POLICY` 가이드 확정
- [ ] 재세션 핸드오프 템플릿 표준화(필수 필드 최소셋 정의)

---

## Done

- [x] `mcp/` 루트 구조 생성(Manifest/Runtime/Scripts)
- [x] 세션 핸드오프 작성/정리 스크립트 추가
- [x] `session_start.sh`에 `Session Handoff` 자동 표시 연동
