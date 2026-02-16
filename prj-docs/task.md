# Task Dashboard (2602 Repository)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 05:07:46`
> - **Updated At**: `2026-02-17 05:27:42`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - P0: 분리 준비 단계 (Blockers)
> - Governance Rules
<!-- DOC_TOC_END -->

## Scope
- 본 문서는 `2602` 루트 구조/거버넌스 작업만 관리한다.
- 제품 구현 상세는 각 제품 레포에서 관리한다.

## P0: 분리 준비 단계 (Blockers)

### TSK-2602-001 2602에서 ticket-core-service 추적 해제
- Status: DONE
- Owner: Codex
- Due: 2026-02-19
- Description:
  - `workspace/apps/backend/ticket-core-service`를 `2602` Git 추적 대상에서 제거한다.
  - 로컬 작업공간으로만 유지되도록 ignore 정책을 적용한다.
- Done Criteria:
  - `git -C /home/aki/2602 ls-files workspace/apps/backend/ticket-core-service` 결과가 비어 있음
  - `2602` 커밋에 해당 경로 파일이 신규로 포함되지 않음
- Evidence:
  - `git -C /home/aki/2602 ls-files workspace/apps/backend/ticket-core-service | wc -l` = `0`
  - `.gitignore`에 `workspace/apps/backend/ticket-core-service/` 등록 완료

### TSK-2602-002 루트 문서 링크 외부 레포 기준 전환
- Status: DONE
- Owner: Codex
- Due: 2026-02-19
- Description:
  - `README.md`, `sidebar-manifest.md`의 ticket-core-service 링크를 외부 레포 기준으로 정리한다.
  - 로컬 경로 중심 링크는 sidecar 문서 경로로 치환한다.
- Done Criteria:
  - 루트 문서에서 ticket-core-service 핵심 진입 링크가 `https://github.com/rag-cargoo/ticket-core-service` 기반으로 정렬됨
  - broken link 없음
- Evidence:
  - `README.md`, `sidebar-manifest.md`의 ticket-core-service 진입 링크를 외부 레포 + sidecar 링크로 전환
  - `README.md` 내 `/workspace/apps/backend/ticket-core-service` 링크 제거

### TSK-2602-003 sidecar project-map 도입 초안
- Status: DONE
- Owner: Codex
- Due: 2026-02-19
- Description:
  - `project-id`, `code_root`, `docs_root`, `repo_remote` 매핑 파일을 정의한다.
  - 재클론 시 `code_root`만 갱신해 문서 연속성을 유지하도록 설계한다.
- Done Criteria:
  - 매핑 스키마 문서화 완료
  - ticket-core-service 1건 샘플 엔트리 등록
- Evidence:
  - `prj-docs/projects/project-map.yaml` 생성
  - `prj-docs/projects/ticket-core-service/README.md` 생성
  - `prj-docs/projects/ticket-core-service/task.md` 생성
  - `prj-docs/projects/ticket-core-service/meeting-notes/README.md` 생성

### TSK-2602-004 session-reload/precommit sidecar 호환 패치
- Status: DONE
- Owner: Codex
- Due: 2026-02-19
- Description:
  - session-reload 스크립트가 `project-map`의 `docs_root`를 인식하도록 확장한다.
  - precommit strict reload 트리거에 sidecar 경로(`prj-docs/projects/**`)를 추가한다.
- Done Criteria:
  - `set_active_project.sh --list` 결과에 map 기반 docs 경로가 노출됨
  - `project_reload.sh` 출력에서 Active Project `Docs Root`가 sidecar 경로로 표시됨
  - `session_start.sh` 출력에서 `Task/Project Agent/Meeting Notes`가 sidecar 경로로 출력됨
- Evidence:
  - `skills/aki-codex-session-reload/scripts/codex_skills_reload/project_reload.sh` 패치 완료
  - `skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh` 패치 완료
  - `skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh` 패치 완료
  - `skills/aki-codex-precommit/policies/core-workspace.sh` 패치 완료

## Governance Rules
- 안건 착수/종료 시 Mandatory Runtime Gate를 필수 체크한다.
- 상태값은 `TODO | DOING | DONE | BLOCKED`만 사용한다.
- 이슈는 대표 umbrella 중심으로 운영하고, 세부 진행은 본 task.md에 누적한다.
