# MCP Config Bootstrap Flow

## When
- 새 PC/새 사용자 환경에서 세션을 처음 시작할 때
- `runtime_flags`에서 `mcp_config_sync`가 `WARN`인 시점
- MCP 서버 추가/변경 직후

## Why
- `~/.codex/config.toml`의 MCP 서버 정의를 표준 템플릿에 맞춰 일관되게 유지한다.
- 환경마다 달라지는 수동 설정 누락을 줄이고 세션 재개성을 높인다.

## Order
1. 부트스트랩 상태 점검
   - Owner Skill: `aki-codex-session-reload`
   - `sync_mcp_config.sh --mode guide`로 누락 섹션/조치 명령을 확인한다.
2. 템플릿 반영
   - Owner Skill: `aki-codex-session-reload`
   - 필요 시 `sync_mcp_config.sh --mode apply`로 누락 MCP 섹션을 idempotent 반영한다.
3. 서버별 운영 점검
   - Owner Skill: `aki-mcp-github`, `aki-mcp-playwright`, `aki-mcp-figma`
   - 서버별 init/probe 절차를 수행한다.
4. 런타임 상태 재동기화
   - Owner Skill: `aki-codex-session-reload`
   - `runtime_flags.sh status`와 `session_start.sh`로 결과를 갱신한다.

## Condition
- 기본 정책:
  - 토큰은 템플릿/레포에 저장하지 않는다.
  - 비밀값은 환경변수 참조만 허용한다.
- `guide` 모드에서 누락이 발견되면:
  - 자동 적용 없이 액션만 제시한다.
- `apply` 모드 실행 후에도 누락이 남으면:
  - 파일 권한/경로 문제로 분류하고 중단 후 보고한다.

## Done
- Completion:
  - guide 또는 apply 절차가 실행되어 누락/반영 결과가 확정됨
- Verification:
  - `mcp_config_sync`가 `READY` 또는 허용된 경고 상태로 표기됨
  - `mcp_servers_configured`에 필수 엔트리가 반영됨
- Evidence:
  - `sync_mcp_config.sh` 출력
  - `.codex/runtime/current_status.txt`
  - `.codex/runtime/codex_session_start.md`
