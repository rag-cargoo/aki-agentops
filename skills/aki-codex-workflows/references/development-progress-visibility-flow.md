# Development Progress Visibility Flow

## When
- 개발 작업 시작 직후(착수 기준선 확인)
- 개발 작업 중간(중간 점검 요청)
- 개발 작업 완료 직전(남은 TODO 확인)
- 사용자가 진행 상태를 명시 요청한 시점
- 진행상태 트리거 키워드:
  - `진행상태`
  - `진행상태 보여줘`
  - `개발 진행상태 보여줘`
  - `체크 진행상태`
  - `체크리스트 보여줘`
  - `할일 체크 보여줘`

## Why
- 작업 중 남은 항목을 즉시 확인해 누락 없이 진행한다.
- `task.md`의 상태(`TODO/DOING/DONE/BLOCKED`)와 실제 진행을 동기화한다.

## Order
1. 트리거 판정
   - Owner Skill: `aki-codex-workflows`
   - 상태조회인지, 진행체크 조회인지 요청 의도를 구분한다.
2. 활성 프로젝트 태스크 문서 결정
   - Owner Skill: `aki-codex-session-reload`
   - `.codex/runtime/codex_project_reload.md`의 `Task Doc`를 기준으로 대상 `task.md`를 결정한다.
3. 진행 체크표 출력
   - Owner Skill: `aki-codex-session-reload`
   - `show_dev_progress.sh`를 실행해 체크표(`[ ]/[~]/[x]/[!]`)를 원문 출력한다.
4. 런타임 상태 동시 확인(선택)
   - Owner Skill: `aki-codex-session-reload`
   - 필요 시 `show_runtime_status.sh --with-progress`를 사용해 런타임 상태 + 진행 체크를 함께 출력한다.
5. workflow 실행 결과 마킹(해당 시)
   - Owner Skill: `aki-codex-workflows`
   - 필요 시 `workflow_mark.sh set --workflow development_progress_visibility ...`로 최신 결과를 기록한다.

## Condition
- 진행상태 요청에서는 요약 없이 체크표 원문을 우선 출력한다.
- 태스크 문서가 없으면 경로와 복구 액션(`set_active_project.sh`, `init_project_docs.sh`)을 즉시 안내한다.
- 상태조회 요청(`상태정보`)과 진행체크 요청(`진행상태`)이 함께 오면 `show_runtime_status.sh --with-progress`를 우선 사용한다.

## Done
- Completion:
  - 트리거 조건에 맞게 진행 체크표를 출력했다.
- Verification:
  - Active Project의 `task.md` 경로를 올바르게 해석했다.
  - 최소 1회 이상 `Current Items` 상태를 체크표로 표기했다.
- Evidence:
  - `show_dev_progress.sh` 출력 결과
  - (선택) `show_runtime_status.sh --with-progress` 출력 결과
  - (선택) `.codex/state/workflow_marks.tsv`의 `development_progress_visibility` 마크
