# Session Reload Flow

## When
- 세션 시작 직후
- 세션 컨텍스트가 어긋났거나 Active Project 상태 복구가 필요한 시점

## Why
- 세션 컨텍스트, 스냅샷, 활성 프로젝트를 일관되게 복원한다.
- 재시작 비용과 누락 위험을 줄인다.

## Order
1. 워크트리 상태 점검
   - Owner Skill: `aki-codex-session-reload`
   - `git status --short`
2. 세션 시작 체인 실행
   - Owner Skill: `aki-codex-session-reload`
   - `session_start.sh` 실행
3. 스냅샷/경고 확인
   - Owner Skill: `aki-codex-session-reload`
   - `.codex/runtime/codex_session_start.md`의 Startup Checks/Active Project 확인
4. MCP config bootstrap 점검
   - Owner Skill: `aki-codex-session-reload`
   - `sync_mcp_config.sh --mode guide`로 MCP 엔트리 누락 여부를 확인한다.
5. GitHub MCP init(필요 시)
   - Owner Skill: `aki-mcp-github`
   - 서버 구성됨 상태면 init flow로 toolset 준비
6. 경고 복구
   - Owner Skill: `aki-codex-session-reload`
   - `set_active_project.sh` 또는 `init_project_docs.sh`로 복구

## Condition
- Active Project 미선택:
  - `set_active_project.sh <project-root>` 실행 후 session_start 재실행
- Runtime Integrity WARN:
  - 실행 권한/누락 스크립트 복구 후 재실행
- MCP config WARN:
  - `sync_mcp_config.sh --mode apply` 실행 후 session_start 재실행
- 실패 정책:
  - 기본 `Stop` 후 원인 보고

## Done
- Completion:
  - `session_start.sh` 실행 및 스냅샷 갱신 완료
- Verification:
  - `skills: ... (OK)`
  - `project: ... (OK)` 또는 합의된 경고 처리 완료
- Evidence:
  - `.codex/runtime/codex_session_start.md`
  - 복구 명령/결과 로그
