# MCP Manifest

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-08 23:11:27`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - (목차 대상 섹션 없음)
<!-- DOC_TOC_END -->

운영/검토용 문서 페이지입니다. 실제 소스 파일은 아래 경로입니다.

- source: `mcp/manifest/mcp-manifest.sh`

```bash
# shellcheck shell=bash
#
# mcp_register "<name>" "<enabled:yes|no>" "<check_cmd>" "<install_cmd|->" "<restart_required:yes|no>" "<note>"
#
# - check_cmd: 설치/가용 여부를 0/1로 반환해야 한다.
# - install_cmd: 자동 설치를 원하지 않으면 "-" 사용.
# - restart_required: 설치 후 새 세션 재시작 권장 여부.

mcp_register "playwright-mcp-browser" "yes" \
  'command -v google-chrome >/dev/null 2>&1 || command -v chromium >/dev/null 2>&1 || command -v microsoft-edge-stable >/dev/null 2>&1' \
  'sudo apt-get update && sudo apt-get install -y chromium || sudo apt-get install -y chromium-browser' \
  "no" \
  "Playwright MCP GUI 경로에 필요한 브라우저 바이너리. 배포판별 설치 명령은 필요 시 교체."

mcp_register "github-cli-prereq" "no" \
  'command -v gh >/dev/null 2>&1' \
  'sudo apt-get update && sudo apt-get install -y gh' \
  "no" \
  "GitHub 연동 MCP/워크플로우 보조 도구. 필요 시 enable=yes 전환."

mcp_register "custom-mcp-server-template" "no" \
  'command -v my-mcp-server >/dev/null 2>&1' \
  '-' \
  "yes" \
  "조직/개인 MCP 서버 항목 템플릿. check/install 명령을 실제 값으로 교체 후 enable=yes 전환."
```
