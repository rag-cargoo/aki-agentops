# SoT Drift Check Rule

## When
- 회의록/`task.md`를 갱신한 직후
- PR 머지 직전 최종 점검 시점
- 이슈 상태 변경(DOING/DONE/CLOSED) 후 동기화가 필요한 시점

## Why
- 상태 충돌 시 단일 진실원천(SoT)을 GitHub Issue로 유지한다.
- 로컬 보드(`task.md`)와 원격 상태 간 드리프트를 조기에 감지/수정한다.

## SoT Rule
1. 상태 충돌 시 GitHub Issue 상태를 우선한다.
2. `task.md`는 실행 보드/캐시이며, 원격 상태를 반영해 정렬한다.
3. 닫힌 Issue가 `task.md`에서 TODO/DOING이면 드리프트로 판정한다.
4. `task.md` DONE 항목이 Issue OPEN이면 드리프트로 판정한다.

## Drift Check Order
1. 기준 데이터 수집
   - Owner Skill: `aki-codex-workflows`
   - `task.md` 작업 항목과 연결된 Issue 번호를 수집한다.
2. 원격 상태 조회
   - Owner Skill: `aki-mcp-github` (`issues`)
   - 각 Issue의 실제 상태(OPEN/CLOSED)를 조회한다.
3. 드리프트 분류
   - Owner Skill: `aki-codex-workflows`
   - `Local Ahead`, `Remote Ahead`, `Link Missing`으로 분류한다.
4. 정렬 조치
   - Owner Skill: `aki-meeting-notes-task-sync` + `aki-codex-workflows`
   - SoT 기준으로 `task.md` 상태를 갱신하고 필요한 링크를 보강한다.
5. 결과 보고
   - Owner Skill: `aki-codex-workflows`
   - 발견/수정/보류 건수를 보고한다.

## Drift Decision Table
- `Issue CLOSED` + `task.md TODO/DOING`:
  - `task.md`를 DONE으로 정렬
- `Issue OPEN` + `task.md DONE`:
  - 작업 상태를 TODO/DOING으로 되돌리거나 Issue를 종료할 근거를 보강
- `task.md` 항목에 Issue 링크 없음:
  - `Link Missing`으로 보고 후 생성/연결 작업 수행

## Done
- Completion:
  - 드리프트 점검 및 정렬 절차 수행 완료
- Verification:
  - 점검 대상 항목에서 SoT 충돌이 해소됨
- Evidence:
  - 점검 대상 목록
  - 드리프트 분류 결과
  - 수정된 `task.md`와 Issue 링크
