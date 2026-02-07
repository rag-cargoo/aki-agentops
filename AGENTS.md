# AGENTS.md (Session Entry)

## 1) Active Roots
- Governance Root: `skills/workspace-governance`
- Workspace Root: `workspace`
- Sidebar Index: `sidebar-manifest.md`
- Skill Index: `skills/_manifest.md`

## 2) Required Rulebook Load Order
세션 시작 시 아래 파일을 순서대로 반드시 로드합니다.

1. `AGENTS.md`
2. `skills/_manifest.md`
3. `skills/workspace-governance/SKILL.md`
4. `skills/workspace-governance/references/WORKFLOW.md`
5. `skills/workspace-governance/references/STRUCTURE.md`
6. `skills/workspace-governance/references/CODING_STANDARD.md`
7. `skills/workspace-governance/references/ARCHITECTURE_RULES.md`
8. `skills/workspace-governance/references/OPERATIONS.md`
9. `workspace/apps/backend/ticket-core-service/prj-docs/task.md`
10. `sidebar-manifest.md`

## 3) Session Start Checklist
1. 현재 브랜치/작업 상태 확인: `git status --short`
2. 대규모 문서/스타일 작업 전 백업 포인트 생성:
`./skills/bin/create-backup-point.sh pre-change`
3. Active Target 확인:
`workspace/apps/backend/ticket-core-service/prj-docs/task.md`
4. 신규/이동 문서는 반드시 `sidebar-manifest.md`에 등록

## 4) Mandatory Safety Rules
1. 기존 문서의 상세 내용은 요약/삭제하지 않고 구조화만 수행
2. 사용자 명시 요청 없이는 파괴적 Git 명령 실행 금지
3. 단일 파일 수정 시 부분 수정 우선, 전체 덮어쓰기 지양
4. 문서 스타일 변경 시 내용 변경(diff) 없이 스타일만 변경
5. 중요 변경 전후로 `git diff --stat`로 파일 수/규모 점검

## 5) Skill Application Policy
1. 요청이 스킬 범위와 일치하면 해당 `SKILL.md`를 먼저 로드 후 작업
2. 문서 렌더링/Pages/무손실 점검은 `skills/github-pages-expert` 우선 사용
3. 워크플로우/구조/표준/운영 규칙은 `skills/workspace-governance` 기준 적용

## 6) Reload Rule (Critical)
세션 중 아래 파일이 수정되면, 다음 작업 전에 반드시 다시 로드합니다.

- `AGENTS.md`
- `skills/_manifest.md`
- `skills/*/SKILL.md`
- `skills/workspace-governance/references/*.md`
