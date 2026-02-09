# Task Board (Codex Runtime Engine)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 04:27:20`
> - **Updated At**: `2026-02-10 04:06:43`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Active Target
> - Notes
<!-- DOC_TOC_END -->

## Active Target
- Status: In Progress
- Goal: `workspace/**` 범위의 프로젝트 탐색 + 기준선 검증 + 활성 프로젝트 스냅샷 체인을 확립한다.

## Notes
- 현재 완료:
  - `init_project_docs.sh`가 `workspace/` 하위 경로를 허용하도록 확장됨.
  - `set_active_project.sh`, `project_reload.sh`가 `workspace/apps` 고정 탐색에서 `workspace/**` 탐색으로 확장됨.
  - 신규 프로젝트 기준선(`README.md`, `PROJECT_AGENT.md`, `task.md`, `meeting-notes/README.md`, `prj-docs/rules/`) 강제 검증이 적용됨.
  - 회의록 인덱스 문서가 추가됨: `prj-docs/meeting-notes/README.md`
  - 세션 시작 체인에 GitHub MCP init 표준이 추가됨(`skills/aki-mcp-github/SKILL.md`, `AGENTS.md`, `session_start.sh`).
  - GitHub MCP 기본 toolset이 6개(`context,repos,issues,projects,pull_requests,labels`)로 확장됨.
  - 회의록 기반 GitHub 운영이 통합됨: `skills/aki-mcp-github/SKILL.md`
  - 코어 스킬 리팩터링 실행 이슈가 생성됨:
    - #1 https://github.com/rag-cargoo/2602/issues/1
    - #2 https://github.com/rag-cargoo/2602/issues/2
    - #3 https://github.com/rag-cargoo/2602/issues/3
    - #4 https://github.com/rag-cargoo/2602/issues/4
  - 코어 스킬 분해 1차 스캐폴딩 추가:
    - `skills/aki-codex-core`
    - `skills/aki-codex-session-reload`
    - `skills/aki-codex-precommit`
  - precommit 전역 정책 경로 이관 완료:
    - `skills/precommit/policies` -> `skills/aki-codex-precommit/policies`
    - `[legacy] skills/bin/validate-precommit-chain.sh` -> `skills/aki-codex-precommit/scripts/validate-precommit-chain.sh`
    - quick/strict 체인 검증 재확인 완료
  - 이슈 #1 완료:
    - 코어 스킬 공존/이관 계획을 `core-responsibility-matrix.md`에 명시
    - 코어 참조 링크를 `sidebar-manifest.md`에 동기화
  - 이슈 #2 완료:
    - `aki-` 네이밍 정책 문서(`skill-naming-policy.md`) 추가
    - `[legacy] ./skills/bin/check-skill-naming.sh` -> `./skills/aki-codex-core/scripts/check-skill-naming.sh`
    - pre-commit 정책에서 스킬 변경 시 네이밍 점검 자동 호출 연결
  - 이슈 #3 완료:
    - 브랜치 안전 체크포인트 문서 추가: `CORE_SKILLS_REFACTOR_BRANCH_CHECKPOINT.md`
    - 중첩 스킬 구조 미채택 원칙 및 `skill-creator` 생성 규칙 문서화
    - 워크플로우/운영 문서/사이드바에 체크포인트 링크 동기화
  - [AGENT-PROPOSAL] runtime orchestrator 제안 안건 등록:
    - 회의록 안건 6에 제안 배경/방향/후속작업 등록
  - [AGENT-PROPOSAL] runtime orchestrator 초안 구현 완료:
    - `skills/aki-codex-session-reload/scripts/runtime_orchestrator/engine.yaml`
    - `skills/aki-codex-session-reload/scripts/run-skill-hooks.sh`
    - `skills/aki-codex-session-reload/scripts/runtime_orchestrator/README.md`
    - `skills/aki-codex-session-reload/scripts/runtime_orchestrator/skill-hooks-report.sample.json`
    - `skills/aki-codex-session-reload/SKILL.md` + `references/session-reload-runbook.md` 공존 원칙 반영
  - 이슈 #10 완료:
    - `skills/bin` 래퍼/링크 제거 완료
    - 세션 리로드/프리커밋/백업/런타임 오케스트레이터 경로를 source-only로 전환
  - `workspace-governance` 제거 진행:
    - 문서/템플릿/스크립트를 소유 스킬로 이관
      - 코어 규칙 문서: `skills/aki-codex-core/references/*`
      - 세션 리로드 가이드/템플릿: `skills/aki-codex-session-reload/references/*`
      - pre-commit 가이드/API 테스트 실행기: `skills/aki-codex-precommit/*`
      - Pages 가이드: `skills/aki-github-pages-expert/references/docsify-setup.md`
    - `skills/workspace-governance` 디렉토리 삭제
    - `AGENTS.md`, `sidebar-manifest.md`, CI/스크립트 경로를 새 구조로 전환
- 상태 갱신(2026-02-10):
  - 이슈 #17, #19 완료/종료 확인(오픈 이슈 0건)
  - 이슈 #22 완료:
    - 전역 관리 범위 고정: `aki-*` 전역 / 비-`aki` 프로젝트 위임 규칙 반영
    - 반영 경로: `AGENTS.md`, `core-responsibility-matrix.md`, `session_start.sh`
    - 세션 보고에 `Managed(aki-*)` / `Delegated(non-aki)` 구분 추가
  - 이슈 #24 완료:
    - `session-reload` vs `workflows` 소유권 경계를 명시 재정의 방식으로 정합화
    - 반영 경로: `aki-codex-session-reload/SKILL.md`, `session-reload-runbook.md`, `runtime_orchestrator/README.md`, `aki-codex-workflows/SKILL.md`, `core-responsibility-matrix.md`
  - 역할/책임 분리 보강 완료:
    - `skills/aki-codex-core/references/core-responsibility-matrix.md`
    - `skills/aki-codex-core/references/WORKFLOW.md`
    - `skills/aki-codex-core/references/OPERATIONS.md`
    - `skills/aki-codex-session-reload/SKILL.md`
    - `skills/aki-codex-precommit/SKILL.md`
    - `skills/aki-mcp-github/SKILL.md`
    - `skills/aki-meeting-notes-task-sync/SKILL.md`
  - 원칙 확정:
    - 오케스트레이션 권위 소스: `aki-codex-workflows`
    - 도메인 실행 권위 소스: 각 Owner Skill
- 다음 작업:
  - GitHub MCP init 계약-구현 정합성 개선:
    - 세션 시작 보고에서 `enabled/failed` 판단 가능 상태로 정리
    - 이슈: #23 https://github.com/rag-cargoo/2602/issues/23
  - `aki-*` 스킬 문서/메타 스키마 통일:
    - 공통 SKILL 스키마 + `agents/openai.yaml` 누락 보강
    - 이슈: #25 https://github.com/rag-cargoo/2602/issues/25
  - `aki-codex-workflows` 2차 플로우 확장 검토:
    - 후보: GitHub MCP init 단독 실행, Pages 배포 검증, PR 머지 전 최종 점검
  - `task.md`-GitHub Issue 상태 드리프트 점검 규칙(SoT 운영) 문서화
  - GitHub Pages 최종 릴리즈 체크: `develop -> main` 병합 직전에 Pages source를 `main`으로 복귀하고 배포 상태를 재확인
