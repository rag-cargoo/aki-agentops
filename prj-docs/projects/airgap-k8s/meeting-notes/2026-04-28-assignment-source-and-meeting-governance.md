# Meeting Notes: Assignment Source and Meeting Governance

## 안건 1: 과제 원문 단일 파일 분리
- Created At: 2026-04-28 00:20:07
- Updated At: 2026-04-28 00:20:07
- Status: DONE
- 결정사항:
  - 과제 원문은 루트 `workspace/infra/airgap/kubernetes/airgap-k8s/ASSIGNMENT.md`를 단일 기준 파일로 유지한다.
  - `README.md`에는 과제 전문을 반복하지 않고 `ASSIGNMENT.md` 경로와 확인 순서만 둔다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-04-28
  - 상태: DONE

## 안건 2: 에이전트 확인 순서와 회의록 우선 운영
- Created At: 2026-04-28 00:20:07
- Updated At: 2026-04-28 00:20:07
- Status: DONE
- 결정사항:
  - 에이전트는 시작 시 `ASSIGNMENT.md -> README.md -> PROJECT_AGENT.md -> task.md -> latest meeting note` 순서로 확인한다.
  - 과제 해석, 작업 순서, 방식 결정은 먼저 `meeting-notes/*.md`에 기록한 뒤 실제 실행으로 이어간다.
  - 실제 작업이 시작되기 전까지 `task.md`는 과제 원문 체크리스트 중심으로 유지한다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-04-28
  - 상태: DONE
