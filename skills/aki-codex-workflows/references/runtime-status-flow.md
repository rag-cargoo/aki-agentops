# Runtime Status Visibility Flow

## When
- 세션 시작 직후
- 런타임 옵션 변경 직후(예: precommit mode 전환)
- 사용자가 상태 조회를 명시 요청한 시점(`상태 보여줘`)

## Why
- 현재 운영 모드/핵심 기능 ON/OFF를 즉시 확인해 오판을 줄인다.
- 세션 중 설정 변경이 실제 실행 상태에 반영됐는지 빠르게 검증한다.

## Order
1. 트리거 판정
   - Owner Skill: `aki-codex-workflows`
   - 세션 시작/옵션 변경/사용자 조회 요청 중 어떤 트리거인지 식별한다.
2. 런타임 플래그 동기화
   - Owner Skill: `aki-codex-session-reload`
   - `runtime_flags.sh sync`로 `.codex/state/runtime_flags.yaml`와 `.codex/runtime/current_status.txt`를 갱신한다.
3. 상태표 출력
   - Owner Skill: `aki-codex-session-reload`
   - `runtime_flags.sh status` 또는 세션 스냅샷의 `Runtime Status` 섹션으로 상태를 노출한다.
4. 경고 전용 출력(필요 시)
   - Owner Skill: `aki-codex-session-reload`
   - `runtime_flags.sh alerts`로 경고 항목만 빠르게 점검한다.
5. 옵션 변경 연계 확인(해당 시)
   - Owner Skill: 각 도메인 스킬(예: `aki-codex-precommit`)
   - 변경된 옵션이 도메인 실행 스크립트에 반영됐는지 확인한다.
6. workflow 실행 결과 마킹(해당 시)
   - Owner Skill: `aki-codex-workflows`
   - `workflow_mark.sh set`으로 실행한 workflow의 최신 결과를 기록한다.

## Condition
- 기본 정책:
  - 매 프롬프트 출력 금지
  - 트리거 이벤트 기반 출력만 허용
  - **기본 출력은 원문 그대로**(`runtime_flags.sh status/alerts` 출력 가공 금지)
  - **요약은 사용자 명시 요청 시에만 허용**
- 출력 실패:
  - `runtime_flags.sh sync` 재시도 후 실패 원인 보고
- 경계 규칙:
  - 상태 저장/렌더링 실행은 `aki-codex-session-reload` 소유
  - 출력 타이밍 규칙은 `aki-codex-workflows` 소유

## Done
- Completion:
  - 트리거 조건에 맞게 상태 동기화와 출력이 수행됨
- Verification:
  - `.codex/state/runtime_flags.yaml`가 최신 값으로 갱신됨
  - `.codex/runtime/current_status.txt`가 생성/갱신됨
  - 필요 시 `.codex/state/workflow_marks.tsv`가 최신 workflow 결과를 반영함
- Evidence:
  - `runtime_flags.sh` 실행 출력
  - `workflow_mark.sh list` 출력
  - 세션 스냅샷 `Runtime Status` 섹션
