# GitHub MCP Init Flow

## When
- 세션 시작 후 GitHub 작업(이슈/PR/프로젝트)을 수행하기 직전
- GitHub MCP toolset 활성 상태가 불명확하거나 일부 누락된 시점

## Why
- GitHub 작업 전에 필수 toolset 준비 상태를 표준화해 실패를 줄인다.
- 이후 워크플로우에서 권한/도구 누락으로 중단되는 비용을 줄인다.

## Order
1. init 대상 확정
   - Owner Skill: `aki-codex-workflows`
   - 기본 대상을 `context,repos,issues,projects,pull_requests,labels`로 확정한다.
2. 가용 toolset 조회
   - Owner Skill: `aki-mcp-github` (`init` flow)
   - `list_available_toolsets`로 지원/활성 상태를 조회한다.
3. 미활성 toolset enable
   - Owner Skill: `aki-mcp-github` (`init` flow)
   - 미활성 항목만 enable 실행한다.
4. 재검증 및 결과 기록
   - Owner Skill: `aki-mcp-github` (`init` flow)
   - 재조회로 `enabled/failed/unsupported`를 확정한다.
5. 워크플로우 결과 보고
   - Owner Skill: `aki-codex-workflows`
   - 후속 플로우에서 사용할 init 결과를 요약한다.

## Condition
- 서버 미구성(`NOT_CONFIGURED`)이면:
  - enable을 시도하지 않고 구성 안내 후 중단한다.
- 일부 toolset 실패 시:
  - 기본 정책은 `Stop-first`이며 실패 항목 보고 후 재시도한다.
- 이미 활성 상태면:
  - 재실행 허용(idempotent), 결과는 `already enabled`로 기록한다.

## Done
- Completion:
  - init 대상 toolset에 대해 조회/enable/재검증 절차를 수행함
- Verification:
  - 세션 보고에서 `enabled/failed/unsupported`가 구분되어 확인 가능함
- Evidence:
  - `list_available_toolsets` 결과
  - enable 실행 결과
  - 최종 상태 요약(`enabled`, `failed`, `unsupported`)
