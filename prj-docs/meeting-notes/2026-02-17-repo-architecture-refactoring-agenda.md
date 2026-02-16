# Meeting Notes: 2602 Repository Architecture Refactoring Agenda

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 04:24:00`
> - **Updated At**: `2026-02-17 06:22:42`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - External Sync
> - 안건 1: 문제정의 및 범위
> - 안건 2: 구조 진단 프레임
> - 안건 3: 진행 원칙
> - 안건 4: 2602 저장소 역할 정렬
> - 안건 5: 현재 Git 경계 진단 결과
> - 안건 6: 분리 운영 원칙 합의
> - 안건 7: Sidecar prj-docs 분리 전략
> - 안건 8: Project Map 및 호환 모드
> - 안건 9: 오작동 방지 가드레일
> - 안건 10: 문서 동기화 운영 규칙
> - 안건 11: 추가 개선 포인트(누락 방지)
> - 안건 12: 스킬/MCP 동작 검증 및 재클론 운영
> - 안건 13: 매 안건 필수 게이트 제도화
> - 안건 14: 준비단계 완료 정의
> - 안건 15: task.md 운영 기준
> - 안건 16: 이슈 생성 기준
<!-- DOC_TOC_END -->

## External Sync
- Source of Truth: `rag-cargoo/aki-agentops` issue/PR 기록
- Linked Issue: https://github.com/rag-cargoo/aki-agentops/issues/66
- Linked PRs:
  - https://github.com/rag-cargoo/aki-agentops/pull/65
  - https://github.com/rag-cargoo/aki-agentops/pull/67
- Sync Action: issue + pr 상태 연동 완료

## 안건 1: 문제정의 및 범위
- Created At: 2026-02-17 04:24:00
- Updated At: 2026-02-17 06:03:20
- Status: DONE
- 결정사항:
  - 본 회의록은 `workspace` 하위 프로젝트가 아니라 `2602` 루트 저장소 자체 이슈를 다룬다.
  - 하위 프로젝트 구현 상세 회의록은 기존 프로젝트별 `prj-docs/meeting-notes`에 유지한다.
  - 루트 구조/운영 규칙/문서 탐색성 문제를 우선 진단 대상으로 둔다.
- 후속작업:
  - 담당: User + Codex
  - 기한: 2026-02-18
  - 상태: DONE
  - 메모: 문제정의가 루트 저장소 구조/운영 경계로 고정되었고, 후속 안건을 P1 태스크로 분해해 추적 시작.

## 안건 2: 구조 진단 프레임
- Created At: 2026-02-17 04:24:00
- Updated At: 2026-02-17 06:03:20
- Status: DONE
- 결정사항:
  - 진단 축을 `경계(Repository vs Project)`, `문서/내비게이션`, `운영 자동화`, `실행 책임` 4개로 고정한다.
  - 결과물은 `현행 구조`, `문제 근거`, `목표 구조`, `전환 리스크` 4단 표로 정리한다.
  - 코드 리팩토링보다 구조 합의와 단계적 이행 계획을 먼저 확정한다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-02-18
  - 상태: DONE
  - 메모: `prj-docs/references/repo-architecture-gap-map.md`에 4축 갭맵 초안 반영 완료.

## 안건 3: 진행 원칙
- Created At: 2026-02-17 04:24:00
- Updated At: 2026-02-17 04:24:00
- Status: DONE
- 결정사항:
  - 구조 논의 단계에서는 기존 기능 동작 변경 없이 문서/경계 정리부터 적용한다.
  - 변경은 `작은 단위 + 즉시 검증 + 문서 동기화` 원칙으로 진행한다.
  - 결제 트랙(P1)은 본 안건 범위에서 제외하고 별도 HOLD 상태를 유지한다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-02-18
  - 상태: DONE
  - 메모: 루트 회의록 인덱스와 사이드바 링크를 동기화했다.

## 안건 4: 2602 저장소 역할 정렬
- Created At: 2026-02-17 04:32:18
- Updated At: 2026-02-17 04:32:18
- Status: DONE
- 결정사항:
  - `2602`는 운영 허브(Control Plane)로 두고 `skills/`, `mcp/`, 공통 거버넌스 문서를 관리한다.
  - 실제 제품 코드는 `workspace`에서 개발하되, 코드 소유/이슈/PR/릴리즈는 각 제품의 독립 레포에서 관리한다.
  - 루트 저장소와 제품 저장소의 책임 혼합은 지양한다.
- 후속작업:
  - 담당: User + Codex
  - 기한: 2026-02-18
  - 상태: DONE
  - 메모: 회의 중 사용자 요청으로 역할 분리 원칙에 합의했다.

## 안건 5: 현재 Git 경계 진단 결과
- Created At: 2026-02-17 04:32:18
- Updated At: 2026-02-17 04:32:18
- Status: DONE
- 결정사항:
  - 현재 `ticket-core-service`는 별도 `.git`이 없고 `2602` 루트 Git에 추적되고 있다.
  - 즉 현행은 `2602` 레포에서 제품 코드까지 함께 커밋/푸시되는 혼합 구조다.
  - 이 상태를 유지하면 제품 운영과 거버넌스 운영의 경계가 모호해질 수 있다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-02-18
  - 상태: DONE
  - 메모:
    - 확인값1: `git -C /home/aki/2602 ls-files workspace/apps/backend/ticket-core-service ...` 결과 추적 중
    - 확인값2: `workspace/apps/backend/ticket-core-service/.git` 부재(`nested_git=no`)

## 안건 6: 분리 운영 원칙 합의
- Created At: 2026-02-17 04:32:18
- Updated At: 2026-02-17 06:22:42
- Status: DONE
- 결정사항:
  - 제품 작업 시 Git/CLI 대상 레포를 명시(`git -C <project-root>`, `gh -R <owner>/<repo>`)한다.
  - `2602`는 프로젝트 코드를 직접 변경/배포하는 레포가 아니라 운영 기준과 링크 허브에 집중한다.
  - 추후 이관 시 `workspace`는 로컬 클론 작업공간 성격으로 정리한다.
- 후속작업:
  - 담당: User + Codex
  - 기한: 2026-02-18
  - 상태: DONE
  - 메모: 분리 이행(PR #65) + repo-target wrapper(`safe-git.sh`, `safe-gh.sh`) 적용으로 운영 기준 확정.

## 안건 7: Sidecar prj-docs 분리 전략
- Created At: 2026-02-17 04:41:43
- Updated At: 2026-02-17 06:03:20
- Status: DONE
- 결정사항:
  - 회사/외부 레포는 원칙적으로 `prj-docs`를 직접 주입하지 않는다.
  - 프로젝트 운영 문서는 `2602/prj-docs/projects/<project-id>/`에 sidecar 형태로 관리한다.
  - 대상 레포 반영이 필요한 내용은 Issue/PR/README로 최소 정보만 동기화한다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-02-18
  - 상태: DONE
  - 메모: `project-map.yaml` + `prj-docs/projects/ticket-core-service/*` sidecar 구조 적용 완료.

## 안건 8: Project Map 및 호환 모드
- Created At: 2026-02-17 04:41:43
- Updated At: 2026-02-17 06:03:20
- Status: DONE
- 결정사항:
  - `project-map` 기반으로 Active Project를 해석하고, `docs_root`를 분리 경로로 지정한다.
  - 1차 전환은 레거시 `<project-root>/prj-docs` fallback을 유지하는 호환 모드로 진행한다.
  - 호환 모드 기간 동안 문서/스크립트/훅은 이중경로를 허용하고 strict 검증은 opt-in으로 둔다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-02-19
  - 상태: DONE
  - 메모: `project_reload.sh`/`set_active_project.sh`/`session_start.sh`가 `docs_root` 인식하도록 패치 완료.

## 안건 9: 오작동 방지 가드레일
- Created At: 2026-02-17 04:41:43
- Updated At: 2026-02-17 06:22:42
- Status: DONE
- 결정사항:
  - GitHub 작업 커맨드는 대상 레포 명시를 기본(`git -C`, `gh -R`)으로 강제한다.
  - `2602`에서 제품 코드 변경이 발생하면 경고 또는 차단하는 pre-commit/pre-push 규칙을 도입한다.
  - 자동화 스크립트는 기본 read-only로 두고, write 동작은 명시 플래그일 때만 허용한다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-02-19
  - 상태: DONE
  - 메모: `strict-remote` 공통 스크립트, pre-push 결함 제거, `safe-git`/`safe-gh` 래퍼 적용 완료.

## 안건 10: 문서 동기화 운영 규칙
- Created At: 2026-02-17 04:41:43
- Updated At: 2026-02-17 06:03:20
- Status: DONE
- 결정사항:
  - sidecar 회의록은 제품 레포 이슈/PR 링크를 반드시 포함한다.
  - 제품팀 공유가 필요한 합의는 sidecar 단독 보관 금지, 대상 레포에 요약본을 남긴다.
  - 릴리즈/운영 영향 항목은 `source-of-truth` 위치를 문서 상단에 명시한다.
- 후속작업:
  - 담당: User + Codex
  - 기한: 2026-02-19
  - 상태: DONE
  - 메모: `prj-docs/meeting-notes/README.md` 템플릿에 `External Sync` 섹션 반영 완료.

## 안건 11: 추가 개선 포인트(누락 방지)
- Created At: 2026-02-17 04:42:28
- Updated At: 2026-02-17 06:22:42
- Status: DONE
- 결정사항:
  - 시크릿/인증 정보는 sidecar 문서에도 원문 저장 금지, 참조 키/링크만 허용한다.
  - sidecar 문서와 대상 레포 상태 간 drift를 점검하는 자동 검증(주기 배치 또는 pre-push)을 도입한다.
  - 구조 전환 과정에서 실패 시 복구할 수 있도록 rollback 절차(되돌릴 커밋/명령/검증 체크)를 표준화한다.
  - CI 파이프라인은 `2602(거버넌스 검증)`와 `제품 레포(빌드/테스트)`를 분리 운영한다.
  - 신규 참여자를 위한 운영 Runbook(작업 시작/레포 지정/문서 동기화/금지 규칙) 단일 문서를 만든다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-02-19
  - 상태: DONE
  - 메모: runbook 5개 항목 통합 + legacy 회의록 상태 드리프트 정리 후 `strict --all --strict-remote` 실패 항목 제거.

## 안건 12: 스킬/MCP 동작 검증 및 재클론 운영
- Created At: 2026-02-17 04:45:22
- Updated At: 2026-02-17 05:27:42
- Status: DONE
- 결정사항:
  - 현재 구조 기준 스모크 검증 결과:
    - `session_start.sh` 정상 동작 (`skills: 9`, `project: workspace/apps/backend/ticket-core-service`)
    - GitHub MCP toolset 상태: `context/repos/issues/projects/pull_requests/labels` enabled 확인
    - precommit 체인 스크립트 인터페이스 정상 확인(`quick/strict`, `--strict-remote`)
  - 단, sidecar `docs_root` 분리 전환 후에는 현행 스크립트가 `project-root/prj-docs`를 기본 전제하므로 호환 패치가 필요하다.
  - 본 검증은 단발성 점검이 아니라 매 안건 진행 시 공통 게이트로 적용한다.
  - 프로젝트 삭제/재클론 후에도 sidecar 문서는 유지하고, 재클론된 코드와 매핑(`project-map`)을 통해 비교/검토를 수행한다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-02-19
  - 상태: DONE
  - 메모:
    - 필수 패치 대상(`project_reload.sh`, `set_active_project.sh`, `session_start.sh`, `core-workspace.sh`) 반영 완료
    - 재클론 운영 기준: `project-id` 고정 + `code_root` 갱신 + `repo_remote` 검증 + 이전 회의록/태스크 재연결

## 안건 13: 매 안건 필수 게이트 제도화
- Created At: 2026-02-17 04:47:33
- Updated At: 2026-02-17 04:47:33
- Status: DONE
- 결정사항:
  - 모든 안건은 상태 전환 시 필수 게이트를 통과해야 한다.
  - 적용 시점:
    - `TODO -> DOING`: 착수 전 게이트 체크 1회 필수
    - `DOING -> DONE`: 종료 전 게이트 체크 1회 필수
  - 필수 체크 항목:
    - `session_start.sh` 성공 및 Active Project 로드 정상
    - GitHub MCP 기본 toolset(`context/repos/issues/projects/pull_requests/labels`) 활성 상태
    - precommit 체인(`validate-precommit-chain.sh`) 실행 가능 상태
  - 게이트 실패 시 안건 상태는 `BLOCKED`로 기록하고 원인/복구조치를 남긴다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-02-19
  - 상태: DONE
  - 메모: 회의록 인덱스 템플릿에 `Mandatory Runtime Gate` 섹션 반영 완료.

## 안건 14: 준비단계 완료 정의
- Created At: 2026-02-17 05:07:46
- Updated At: 2026-02-17 05:13:18
- Status: DONE
- 결정사항:
  - 준비단계 완료는 아래 3개 블로커 해소 시점으로 정의한다.
    - `2602`에서 `workspace/apps/backend/ticket-core-service` 추적 해제
    - 루트 문서 링크를 외부 레포 기준으로 전환
    - sidecar `project-map` 초안 + 스크립트 호환 패치 계획 확정
  - 블로커가 남아 있는 동안 회의록 상태는 `DOING`으로 유지한다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-02-19
  - 상태: DONE
  - 메모:
    - `git -C /home/aki/2602 ls-files workspace/apps/backend/ticket-core-service | wc -l` = `0`
    - `README.md`, `sidebar-manifest.md`를 외부 레포 + sidecar 링크 기준으로 전환
    - `prj-docs/projects/project-map.yaml` 및 ticket-core-service sidecar 문서 생성

## 안건 15: task.md 운영 기준
- Created At: 2026-02-17 05:07:46
- Updated At: 2026-02-17 05:07:46
- Status: DONE
- 결정사항:
  - 루트 `prj-docs/task.md`를 생성해 준비단계 작업을 실행 단위로 추적한다.
  - 모든 항목은 `TODO/DOING/DONE/BLOCKED` 상태와 검증 기준을 함께 기록한다.
  - 회의록 안건과 task 항목은 상호 링크하고 상태를 동기화한다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-02-17
  - 상태: DONE
  - 메모: 최초 버전 `prj-docs/task.md` 생성 및 P0 항목 등록.

## 안건 16: 이슈 생성 기준
- Created At: 2026-02-17 05:07:46
- Updated At: 2026-02-17 05:07:46
- Status: DONE
- 결정사항:
  - 모든 안건을 이슈로 만들지는 않는다.
  - 이슈는 아래 조건에서만 생성한다.
    - 세션 넘어가는 장기 작업
    - 외부 공유/승인/PR 연계가 필요한 작업
    - 담당자/기한/리스크 추적이 필요한 작업
  - 동일 범위 후속은 신규 이슈 남발 대신 기존 이슈 업데이트/재오픈을 원칙으로 한다.
- 후속작업:
  - 담당: User + Codex
  - 기한: 상시
  - 상태: DONE
  - 메모: 준비단계는 대표 umbrella 이슈 1개로 묶고, 세부는 task.md로 관리.
