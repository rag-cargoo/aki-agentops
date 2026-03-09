# Figma MCP Init

## 목표
- 새 환경에서도 Figma MCP 서버 엔트리를 일관되게 맞춘다.
- 토큰/인증정보는 로컬 환경변수로만 관리한다.

## 표준 순서
1. 세션 공통 bootstrap 실행
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/sync_mcp_config.sh --mode apply`
2. endpoint 가용성 점검
   - `./skills/aki-mcp-figma/scripts/probe_figma_mcp.sh --server all`
3. 세션 상태 재동기화
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`

## 기준 endpoint
1. remote:
   - `https://mcp.figma.com/mcp`
2. desktop:
   - `http://127.0.0.1:3845/mcp`

## 보안 규칙
1. 토큰 값은 `~/.codex/config.toml`에 평문으로 저장하지 않는다.
2. 환경변수 참조(`$FIGMA_API_TOKEN` 등)만 허용한다.
3. 레포 파일(`skills/`, `.agents/`, `mcp/`)에 토큰을 기록하지 않는다.
