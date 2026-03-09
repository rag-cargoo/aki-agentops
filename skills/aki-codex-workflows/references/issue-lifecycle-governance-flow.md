# Issue Lifecycle Governance Flow

## When
- 새 이슈를 만들기 직전
- 기존 이슈 close 이후 후속 개선/회귀 작업이 발생했을 때
- 회의록 항목을 GitHub 이슈로 동기화하기 직전

## Why
- 같은 작업 축에서 이슈 난발을 막고 추적 일관성을 유지한다.
- Reopen-first 원칙을 실행 단계에서 표준화한다.

## Order
1. 중복/연관 이슈 탐색
   - Owner Skill: `aki-codex-workflows`
   - 키워드/범위로 기존 open/closed 이슈 후보를 조회한다.
2. Lifecycle 결정
   - Owner Skill: `aki-codex-workflows`
   - 같은 범위면 `Reopen/Update`, 다른 범위면 `New`로 결정한다.
3. 이슈 업서트 실행
   - Owner Skill: `aki-mcp-github`
   - `scripts/issue-upsert.sh`로 기존 이슈 우선 갱신/재오픈을 수행한다.
4. 진행 로그 누적
   - Owner Skill: `aki-mcp-github`
   - 기존 본문은 보존하고 코멘트로 단계 로그를 누적한다.
5. PR 연결 검증
   - Owner Skill: `aki-codex-workflows`
   - PR 본문에 관련 이슈와 Lifecycle 근거가 반영됐는지 확인한다.

## Condition
- 동일 범위 판단 기준:
  - 목표/완료기준/산출물이 기존 이슈와 동일하면 `Reopen/Update`
- 예외로 새 이슈 생성:
  - 목표/종료판정/배포 타임라인이 분리된 경우
- 실패 정책:
  - 연관 이슈 탐색 실패 시 새 이슈 생성 중단 후 원인 보고

## Done
- Completion:
  - 이슈 라이프사이클 결정과 업서트 절차 수행 완료
- Verification:
  - Reopen-first 원칙 위반 없이 이슈/PR 링크가 정합함
- Evidence:
  - 검색 결과, 결정 근거, 최종 이슈/PR 링크
