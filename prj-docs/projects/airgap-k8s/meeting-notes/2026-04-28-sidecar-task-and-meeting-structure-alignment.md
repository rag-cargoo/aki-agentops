# Meeting Notes: Sidecar Task and Meeting Structure Alignment

## 안건 1: sidecar TODO를 매뉴얼 장 순서에 맞는 파일 구조로 분리할지 결정
- Created At: 2026-04-28 01:50:00
- Updated At: 2026-04-28 01:50:00
- Status: DONE
- 검토사항:
  - `task.md` 하나에 모든 항목을 계속 누적하면 과제 체크리스트, 현재 작업, 장별 세부 작업이 한 곳에 섞인다.
  - 제출 매뉴얼은 장 순서로 읽히므로 TODO도 같은 순서로 정리되는 편이 낫다.
- 결정사항:
  - `task.md`는 대시보드 역할만 유지한다.
  - sidecar 상세 TODO는 `prj-docs/projects/airgap-k8s/tasks/*.md`로 분리한다.
  - 파일명은 제출 매뉴얼 장 순서와 동일한 번호형 한글 파일을 사용한다.
  - 실제 항목이 확정되고 그 장의 작업이 시작된 뒤에만 task 파일을 생성한다.

## 안건 2: 회의록을 매뉴얼에 맞게 구조화할지 결정
- Created At: 2026-04-28 01:50:00
- Updated At: 2026-04-28 01:50:00
- Status: DONE
- 검토사항:
  - 회의록은 날짜 기반 이력이 중요하므로 파일 자체를 장별 폴더로 옮기면 시간 흐름 파악이 어려워진다.
  - 대신 index에서 매뉴얼 장 기준으로 다시 묶어주면 탐색성과 이력성이 둘 다 유지된다.
- 결정사항:
  - 회의록 파일은 계속 `YYYY-MM-DD-topic.md` 규칙을 유지한다.
  - `meeting-notes/README.md`에서 실제 제출 매뉴얼 장 기준 index를 추가해 장별로 참조한다.
  - 공통 거버넌스 회의록과 장별 회의록을 구분해서 보여준다.

## 안건 3: task와 매뉴얼 정렬 기준
- Created At: 2026-04-28 01:50:00
- Updated At: 2026-04-28 01:50:00
- Status: DONE
- 결정사항:
  - 매뉴얼은 설명/제출 원본이다.
  - `task.md`는 현재 상태 요약이다.
  - `tasks/*.md`는 장별 실행 TODO와 완료 이력을 관리한다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-04-28
  - 상태: DONE
  - 내용:
    - `tasks/` 디렉터리 생성
    - `task.md` 대시보드 정리
    - `meeting-notes/README.md` 장별 index 추가
