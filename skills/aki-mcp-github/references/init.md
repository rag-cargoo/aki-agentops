# GitHub MCP Init Flow

## 목표
- GitHub MCP 연결 직후 기본 작업 toolset을 즉시 사용 가능한 상태로 만든다.
- 최소 권한 원칙을 유지하면서 세션 초반 재시도 비용을 줄인다.

## 기본 프로필
- 기본 대상 toolset: `context`, `repos`, `issues`, `projects`, `pull_requests`, `labels`
- 오버라이드: `GITHUB_MCP_DEFAULT_TOOLSETS` 값이 있으면 해당 CSV 순서를 우선한다.
- 원칙: 이미 활성화된 toolset은 재활성화해도 무방하다(idempotent).

## 실행 절차
1. `mcp__github__list_available_toolsets` 호출로 서버 응답과 전체 상태를 수집한다.
2. 대상 toolset 목록을 결정한다.
3. 각 대상 toolset을 순회한다.
4. `can_enable=true`이고 `currently_enabled=false`인 경우에만 `mcp__github__enable_toolset`를 호출한다.
5. `mcp__github__list_available_toolsets`를 다시 호출해 최종 상태를 재검증한다.
6. 대상별 결과(활성/이미활성/실패/미지원)를 사용자에게 보고한다.

## 검증 기준
- 성공: 대상 toolset 전부 `currently_enabled=true`
- 부분 성공: 일부 실패가 있어도 실패 항목과 영향 범위를 분리 보고
- 차단: `list_available_toolsets` 실패 시 GitHub 변경 작업 보류

## 재시도 정책 (표준)
1. 재시도 대상:
   - `429` (rate limit)
   - `500/502/503/504` (서버 일시 오류)
   - 네트워크 연결 오류(`error connecting to api.github.com` 등)
2. 재시도 횟수:
   - 최대 3회 재시도(초기 1회 + 재시도 3회, 총 4회 시도)
3. backoff:
   - 2초 -> 4초 -> 8초 순서로 대기 후 재시도
4. 즉시 중단 대상:
   - `401/403` (권한/토큰 문제)
   - `404/422` (요청/대상 불일치)
5. 부분 성공 처리:
   - 일부 toolset만 활성화된 경우 성공/실패/미지원을 분리 보고하고, 후속 작업은 성공 범위 내에서만 진행한다.

## 실패 대응
1. `list_available_toolsets` 실패:
   - 재시도 정책을 적용한 뒤, 지속 실패 시 서버/토큰/세션 상태를 점검한다.
2. 개별 toolset enable 실패:
   - 재시도 정책을 적용하고, 실패 항목을 기록한 뒤 성공 범위 내 작업만 진행한다.
3. 대상 toolset 미노출:
   - 서버 버전 또는 권한 스코프 차이로 간주하고 "미지원"으로 보고한다.
