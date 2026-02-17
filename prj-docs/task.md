# Task Dashboard (AKI AgentOps Repository)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 05:07:46`
> - **Updated At**: `2026-02-17 09:38:52`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - P0: 분리 준비 단계 (Blockers)
> - P1: 구조 고도화 단계
> - P2: 리네이밍/README 재정의 단계
> - Governance Rules
<!-- DOC_TOC_END -->

## Scope
- 본 문서는 `AKI AgentOps` 루트 구조/거버넌스 작업만 관리한다.
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

## P1: 구조 고도화 단계

### TSK-2602-005 구조 진단 프레임 4축 갭맵 문서화
- Status: DONE
- Owner: Codex
- Due: 2026-02-19
- Description:
  - 안건 2 기준 4축(`경계/문서/자동화/실행책임`) 갭맵을 단일 문서로 확정한다.
- Done Criteria:
  - `현행 구조/문제 근거/목표 구조/전환 리스크` 4단 표 완성
  - 루트 내비게이션에서 문서 진입 가능
- Evidence:
  - `prj-docs/references/repo-architecture-gap-map.md` 생성
  - `README.md`, `sidebar-manifest.md`에 링크 반영

### TSK-2602-006 project-map 호환 모드 완료 판정
- Status: DONE
- Owner: Codex
- Due: 2026-02-19
- Description:
  - sidecar `docs_root` 기반 active project 로딩/표시를 완료 상태로 고정한다.
- Done Criteria:
  - session/project reload 출력에서 `docs_root` 기준 문서 경로가 일관되게 표출됨
  - 분리 전환 PR이 머지됨
- Evidence:
  - PR `#65` merged
  - `.codex/runtime/codex_session_start.md` Active Project `Docs Root` 출력 확인

### TSK-2602-007 strict-remote 가드레일 복구
- Status: DONE
- Owner: Codex
- Due: 2026-02-19
- Description:
  - `--strict-remote` 옵션이 실제 원격 상태 대조를 수행하도록 precommit/prepush 경로를 복구한다.
- Done Criteria:
  - 공통 원격 대조 스크립트가 존재하고 strict 체인에 연결됨
  - pre-push 훅이 삭제된 구 경로를 참조하지 않음
- Evidence:
  - `skills/aki-codex-precommit/scripts/check-doc-remote-sync.sh` 추가
  - `skills/aki-codex-precommit/policies/core-workspace.sh` strict-remote 연결
  - `.githooks/pre-push` 경로 결함 제거

### TSK-2602-008 문서 External Sync 템플릿 반영
- Status: DONE
- Owner: Codex
- Due: 2026-02-19
- Description:
  - 회의록 인덱스 템플릿에 외부 동기화 계약(`External Sync`)을 추가한다.
- Done Criteria:
  - 템플릿에 Source of Truth/Sync Action/Last Synced At 필드 포함
  - 운영 규칙 섹션에 외부 동기화 원칙이 반영됨
- Evidence:
  - `prj-docs/meeting-notes/README.md` 업데이트

### TSK-2602-009 sidecar 운영 Runbook 통합
- Status: DONE
- Owner: Codex
- Due: 2026-02-20
- Description:
  - 안건 11 항목(시크릿/드리프트/복구/CI 분리/온보딩)을 단일 운영 런북으로 통합한다.
- Done Criteria:
  - 단일 문서에 5개 항목 체크리스트 완성
  - 회의록 안건 11 상태와 동기화
- Evidence:
  - `prj-docs/references/sidecar-operations-runbook.md` 반영 완료
  - legacy 회의록 상태 드리프트 정리 후 `strict --all --strict-remote` 재검증 통과

### TSK-2602-010 repo-target wrapper 도입(`safe-git`/`safe-gh`)
- Status: DONE
- Owner: Codex
- Due: 2026-02-20
- Description:
  - 안건 9 기준으로 대상 레포 명시 실행을 표준화하는 wrapper를 도입한다.
- Done Criteria:
  - Git/gh wrapper 스크립트가 추가되고 실행 예시가 운영 런북에 반영됨
  - 스크립트 소유 맵에 신규 엔트리가 등록됨
- Evidence:
  - `skills/aki-codex-core/scripts/safe-git.sh` 추가
  - `skills/aki-codex-core/scripts/safe-gh.sh` 추가
  - `prj-docs/references/sidecar-operations-runbook.md`에 Repo Target Guard 섹션 반영
  - `skills/aki-codex-core/references/bin-script-ownership-map.md` 업데이트

## P2: 리네이밍/README 재정의 단계

### TSK-2602-011 레포/프로젝트 명칭 리네임 전략 확정
- Status: DONE
- Owner: User + Codex
- Due: 2026-02-20
- Description:
  - 프로젝트 표시명과 레포 slug 처리 방식을 확정한다.
- Done Criteria:
  - 표시명 `AKI AgentOps` 확정
  - `display-name only` 1차 적용 + `repo slug rename` 2차 검토 전략 문서화
- Evidence:
  - `prj-docs/meeting-notes/2026-02-17-repo-rename-readme-governance-planning.md`
  - `https://github.com/rag-cargoo/aki-agentops/issues/70`

### TSK-2602-012 루트 README 자체 프로젝트 소개/사용방법 재구성
- Status: DONE
- Owner: Codex
- Due: 2026-02-17
- Description:
  - 루트 README 상단에 프로젝트 목적/사용 시나리오/Quick Start를 명시한다.
- Done Criteria:
  - Overview + Quick Start + Boundary 섹션이 상단에 배치됨
  - 기존 링크형 문서는 보존하면서 탐색 경로가 유지됨
- Evidence:
  - `README.md` 상단 정보구조 재편 반영
  - `prj-docs/meeting-notes/2026-02-17-repo-rename-readme-governance-planning.md` 안건 2 `DONE`

### TSK-2602-013 `AKI AgentOps` 표시명 1차 반영 (문서/내비게이션)
- Status: DONE
- Owner: Codex
- Due: 2026-02-17
- Description:
  - 루트 문서에서 프로젝트 표시명을 `AKI AgentOps`로 정렬한다.
  - 1차 단계에서는 링크 경로/slug는 유지하고 표기명만 교체한다.
- Done Criteria:
  - `README.md`, `sidebar-manifest.md`, `prj-docs/meeting-notes/README.md`에 `AKI AgentOps` 표기가 반영됨
  - 기존 `2602` 표기는 호환 맥락(구 명칭)으로만 남음
- Evidence:
  - `README.md` 표기명/호환 주석 반영
  - `sidebar-manifest.md` repository 표시명 반영
  - `prj-docs/meeting-notes/README.md` 제목/목적 문구 반영

### TSK-2602-014 레포 slug rename 실행 및 링크 동기화
- Status: DONE
- Owner: User + Codex
- Due: 2026-02-17
- Description:
  - 사용자 GO 이후 레포 slug를 `2602`에서 `aki-agentops`로 변경한다.
  - GitHub Pages 경로 및 루트 문서/설정의 레포 URL을 신규 slug로 동기화한다.
- Done Criteria:
  - `gh repo view` 기준 `nameWithOwner`가 `rag-cargoo/aki-agentops`로 확인됨
  - Pages URL `https://rag-cargoo.github.io/aki-agentops/` 응답이 정상임
  - `README.md`, `index.html`, `.github/ISSUE_TEMPLATE/config.yml` 핵심 URL이 신규 slug로 반영됨
- Evidence:
  - `gh repo view --json name,nameWithOwner,url`
  - `curl -I https://rag-cargoo.github.io/aki-agentops/`
  - 문서 반영 PR 링크(추후)

### TSK-2602-015 레거시 로컬 경로(`/home/aki/2602`) 잔여 정리
- Status: DONE
- Owner: Codex
- Due: 2026-02-17
- Description:
  - 레거시 로컬 경로(`/home/aki/2602`) 예시가 남아 있는 운영 문서/스크립트를 현재 저장소 경로(`/home/aki/aki-agentops`) 기준으로 정렬한다.
  - 기존 회의록/증빙 원문은 보존하고, 실행 예시성 문서/스크립트만 갱신한다.
- Done Criteria:
  - `prj-docs/references/sidecar-operations-runbook.md`의 `safe-git` 예시가 `/home/aki/aki-agentops`를 사용함
  - `skills/aki-codex-core/scripts/safe-git.sh`의 usage example이 `/home/aki/aki-agentops`를 사용함
  - quick/strict precommit 체인이 통과함
- Evidence:
  - `prj-docs/references/sidecar-operations-runbook.md` Repo Target Guard 예시 경로 갱신
  - `skills/aki-codex-core/scripts/safe-git.sh` usage 예시 경로 갱신
  - PR 링크(추후)

### TSK-2602-016 레거시 표기 2차 정리 범위 정의
- Status: DONE
- Owner: User + Codex
- Due: 2026-02-17
- Description:
  - 레거시 표기(`2602`, 이전 로컬 경로) 잔여를 전수 스캔해 `보존 대상(증빙/역사)`과 `치환 대상(실행 예시/운영 가이드)`으로 분류한다.
  - 분류 결과를 기준으로 2차 정리 실행 목록을 확정한다.
- Done Criteria:
  - `rg` 기반 잔여 목록 리포트가 문서로 정리됨
  - 각 항목에 `보존/치환` 판단 근거가 기록됨
  - 후속 실행용 태스크 필요 여부(`TSK-2602-017+`)가 판정됨
- Evidence:
  - 분류 리포트: `prj-docs/references/legacy-label-cleanup-report-2026-02-17.md`
  - 치환 반영: `prj-docs/projects/README.md`, `prj-docs/projects/ticket-core-service/rules/architecture.md`, `prj-docs/references/repo-architecture-gap-map.md`
  - 당시 판정: `TSK-2602-017+` 추가 불필요(레거시 표기 2차 정리 범위 기준)
  - 연계 PR 링크(추후)

## P3: 문서 대상/노출 거버넌스 단계

### TSK-2602-017 문서 메타 스키마(Target/Surface) 규정 수립
- Status: DONE
- Owner: Codex
- Due: 2026-02-17
- Description:
  - 문서 메타에 `Target`/`Surface` 필드를 도입하기 위한 enum과 의미를 표준화한다.
  - `Surface`가 메뉴 노출 정책이며 접근 제어와 별개임을 명시한다.
- Done Criteria:
  - 표준 문서에 `Target`/`Surface` 스키마가 기록됨
  - 허용값(`HUMAN|AGENT|BOTH|FUTURE:*`, `PUBLIC_NAV|AGENT_NAV|HIDDEN`)이 확정됨
- Evidence:
  - `prj-docs/references/document-target-surface-governance.md`
  - `prj-docs/meeting-notes/2026-02-17-doc-target-surface-governance-kickoff.md`

### TSK-2602-018 문서 인벤토리 분류 및 Pages 노출 분리 설계
- Status: DOING
- Owner: User + Codex
- Due: 2026-02-20
- Description:
  - 전 문서를 `Target`/`Surface` 기준으로 분류한 인벤토리를 작성한다.
  - GitHub Pages에서 `PUBLIC_NAV`(사용자용)와 `AGENT_NAV`(에이전트용) 분리 구조를 설계한다.
- Done Criteria:
  - 분류 인벤토리 문서가 생성되고 분류 근거가 기록됨
  - `sidebar-manifest.md` 분리 전략(또는 보조 manifest)이 문서화됨
  - 외부 트래킹 이슈/PR 링크가 task와 회의록에 동기화됨
- Evidence:
  - `prj-docs/meeting-notes/2026-02-17-doc-target-surface-governance-kickoff.md`
  - `prj-docs/references/document-target-surface-governance.md`
  - `https://github.com/rag-cargoo/aki-agentops/issues/79`

## Governance Rules
- 안건 착수/종료 시 Mandatory Runtime Gate를 필수 체크한다.
- 상태값은 `TODO | DOING | DONE | BLOCKED`만 사용한다.
- 이슈는 대표 umbrella 중심으로 운영하고, 세부 진행은 본 task.md에 누적한다.
