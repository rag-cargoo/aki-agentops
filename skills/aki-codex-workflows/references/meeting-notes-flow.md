# Meeting Notes Flow

## When
- 회의록 작성 직후
- 회의 안건이 실행 항목으로 확정된 시점

## Why
- 회의 문장을 실행/추적 가능한 항목으로 즉시 변환해 누락을 방지한다.
- 문서와 GitHub 추적 객체 간 왕복 링크를 유지한다.

## Order
1. 회의록 상태 확인
   - Owner Skill: `aki-codex-workflows`
   - 입력 회의록 파일과 안건 상태(`TODO|DOING|DONE`)를 확정한다.
2. 로컬 TODO 반영
   - Owner Skill: `aki-meeting-notes-task-sync`
   - 회의록 후속작업을 `task.md`에 반영한다.
3. GitHub 추적 반영
   - Owner Skill: `aki-mcp-github` (`meeting-notes-sync` flow)
   - 이슈/라벨/프로젝트/PR 링크를 갱신한다.
4. 링크 역기록/정합성 확인
   - Owner Skill: `aki-codex-workflows`
   - 회의록/이슈/PR 간 링크 일관성을 확인한다.

## Condition
- PR은 옵션 단계다.
  - 구현 미착수면 PR 생략 가능.
- GitHub MCP 준비 미완료 시:
  - 먼저 `aki-mcp-github`의 `init` flow 실행.
- 실패 정책 기본값:
  - 중단 후 보고(Stop-first)

## Done
- Completion:
  - 회의록 -> `task.md` -> GitHub 이슈 반영이 완료됨
- Verification:
  - 이슈 링크가 회의록에 기록되고 상태가 일치함
- Evidence:
  - 회의록 경로
  - 생성/갱신된 Issue/PR 링크
  - 필요 시 코멘트 링크/프로젝트 반영 결과
