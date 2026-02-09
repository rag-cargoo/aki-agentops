# Meeting Notes: Aki Skill Governance Scope & Boundary

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-10 03:40:47`
> - **Updated At**: `2026-02-10 05:30:04`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 전역 관리 범위 고정(`aki-*` only)
> - 안건 2: 비-`aki` 스킬 프로젝트 위임 원칙
> - 안건 3: 역할 경계 충돌 정리(`session-reload` vs `workflows`)
> - 안건 4: GitHub MCP init 계약-구현 정합성
> - 안건 5: 스킬 문서 스키마/메타 통일
> - 안건 6: `aki-codex-workflows` 2차 플로우 확장
> - 안건 7: SoT 드리프트 점검 규칙 문서화
> - 안건 8: `develop -> main` 병합 전 Pages 최종 릴리즈 체크
> - 안건 9: precommit 정책 스크립트 안전옵션 정합화
> - 안건 10: docsify 검증 pre-commit 체인 자동 연동
> - 안건 11: docsify_validator CLI 개선
> - 안건 12: GitHub MCP init 재시도/백오프 규칙 명문화
> - 안건 13: workflows Owner Skill lint 스크립트 추가
> - 안건 14: Issue Reopen-First 강제(템플릿/PR 게이트/upsert)
<!-- DOC_TOC_END -->

## 안건 1: 전역 관리 범위 고정(`aki-*` only)
- Created At: 2026-02-10 03:40:47
- Updated At: 2026-02-10 03:59:33
- Status: DONE
- 결정사항:
  - 코어 운영 관점의 기본 관리 대상은 `aki-*` 스킬로 고정한다.
  - 전역 정책/검증/리로드/워크플로우 기준은 `aki-*` 스킬 세트에 우선 적용한다.
  - `java-spring-boot` 같은 비-`aki` 스킬은 코어 거버넌스 대상이 아니라 프로젝트 선택형으로 취급한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-11
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/22

## 안건 2: 비-`aki` 스킬 프로젝트 위임 원칙
- Created At: 2026-02-10 03:40:47
- Updated At: 2026-02-10 03:59:33
- Status: DONE
- 결정사항:
  - 비-`aki` 스킬은 Active Project 요구가 있을 때만 로드/사용한다.
  - 예: Terraform 프로젝트에서는 `java-spring-boot`를 기본 관리 대상으로 보지 않는다.
  - 프로젝트별 `PROJECT_AGENT.md`와 `task.md`가 비-`aki` 스킬 사용 여부를 결정한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-11
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/22

## 안건 3: 역할 경계 충돌 정리(`session-reload` vs `workflows`)
- Created At: 2026-02-10 03:40:47
- Updated At: 2026-02-10 04:06:43
- Status: DONE
- 결정사항:
  - [AGENT-PROPOSAL] 현재 문서 원칙상 오케스트레이션은 `aki-codex-workflows` 소유인데, `runtime_orchestrator` 자산이 `aki-codex-session-reload`에 위치해 경계가 일부 겹친다.
  - 소유권 정렬 방식은 "명시 재정의"로 확정한다.
    - 세션 부트스트랩 훅 실행기(`run-skill-hooks.sh`, `engine.yaml`)는 `aki-codex-session-reload` 소유
    - 사용자 작업 오케스트레이션 권위 소스(When/Why/Order/Condition/Done)는 `aki-codex-workflows` 소유
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-11
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/24

## 안건 4: GitHub MCP init 계약-구현 정합성
- Created At: 2026-02-10 03:40:47
- Updated At: 2026-02-10 04:10:14
- Status: DONE
- 결정사항:
  - [AGENT-PROPOSAL] `AGENTS.md`의 "init 결과 보고" 요구와 `session_start.sh`의 "가이드 출력" 동작을 일치시켜야 한다.
  - 계약 모드는 `guide_only`로 명시하고 `init_mode`/`execution_status` 필드를 세션 시작 보고에 고정 출력한다.
  - 실제 enable 실행은 `aki-mcp-github` init flow에서 수행하며 결과(`enabled`/`failed`/`unsupported`)를 후속 보고에 포함한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-11
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/23

## 안건 5: 스킬 문서 스키마/메타 통일
- Created At: 2026-02-10 03:40:47
- Updated At: 2026-02-10 04:14:19
- Status: DONE
- 결정사항:
  - [AGENT-PROPOSAL] `aki-*` 스킬 문서는 최소 공통 섹션(목표/경계/입출력/Done/참고)을 통일한다.
  - `aki-*` 스킬은 `agents/openai.yaml` 메타를 기본으로 갖추고 누락 시 보완한다.
  - 비-`aki` 스킬은 프로젝트/외부 스킬 정책에 따라 별도 관리한다.
  - `skill-schema-policy.md`를 코어 기준 문서로 추가하고 AGENTS/사이드바에 연결한다.
  - `aki-github-pages-expert`의 `agents/openai.yaml` 누락을 보완한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-11
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/25

## 안건 6: `aki-codex-workflows` 2차 플로우 확장
- Created At: 2026-02-10 04:14:19
- Updated At: 2026-02-10 04:14:19
- Status: DONE
- 결정사항:
  - `aki-codex-workflows` 2차 플로우 3종을 references로 추가한다.
    - GitHub MCP init 단독 실행
    - Pages 배포 검증
    - PR 머지 전 최종 점검
  - `SKILL.md`와 사이드바에 신규 레퍼런스 링크를 동기화한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/26

## 안건 7: SoT 드리프트 점검 규칙 문서화
- Created At: 2026-02-10 04:14:19
- Updated At: 2026-02-10 04:14:19
- Status: DONE
- 결정사항:
  - `task.md`와 GitHub Issue 상태 충돌 시 GitHub Issue를 SoT로 우선한다.
  - 드리프트 분류/조치/보고 규칙을 `sot-drift-check-rule.md`로 고정한다.
  - PR 머지 전 점검 플로우에 SoT 드리프트 점검 단계를 포함한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/27

## 안건 8: `develop -> main` 병합 전 Pages 최종 릴리즈 체크
- Created At: 2026-02-10 04:28:10
- Updated At: 2026-02-10 04:28:10
- Status: TODO
- 결정사항:
  - 메인 병합 직전 Pages source branch를 `main`으로 복귀하고 배포 상태를 재확인한다.
  - 결과를 `task.md`와 이슈에 동기화한 뒤 최종 머지 Go/No-Go를 판정한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: TODO
  - 이슈: https://github.com/rag-cargoo/2602/issues/28

## 안건 9: precommit 정책 스크립트 안전옵션 정합화
- Created At: 2026-02-10 05:10:31
- Updated At: 2026-02-10 05:15:39
- Status: DONE
- 결정사항:
  - `core-workspace.sh`에 `set -euo pipefail`을 적용해 코어 운영 규칙과 정합화한다.
  - quick/strict 실행 회귀를 함께 검증한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/29

## 안건 10: docsify 검증 pre-commit 체인 자동 연동
- Created At: 2026-02-10 05:10:31
- Updated At: 2026-02-10 05:15:39
- Status: DONE
- 결정사항:
  - 문서 변경 시 docsify 검증을 pre-commit 체인에서 자동 수행하도록 연결한다.
  - 실패 시 커밋을 차단하고 실패 로그를 그대로 보고한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/30

## 안건 11: docsify_validator CLI 개선
- Created At: 2026-02-10 05:10:31
- Updated At: 2026-02-10 05:15:39
- Status: DONE
- 결정사항:
  - `argparse` 기반으로 다중 파일과 `--all-managed` 옵션을 지원한다.
  - 기존 단일 파일 실행 방식과 호환성을 유지한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/31

## 안건 12: GitHub MCP init 재시도/백오프 규칙 명문화
- Created At: 2026-02-10 05:10:31
- Updated At: 2026-02-10 05:15:39
- Status: DONE
- 결정사항:
  - `429/5xx/연결 오류` 재시도 횟수와 backoff(대기시간) 기준을 고정한다.
  - 중단 기준과 부분 성공 보고 기준을 함께 명시한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/32

## 안건 13: workflows Owner Skill lint 스크립트 추가
- Created At: 2026-02-10 05:10:31
- Updated At: 2026-02-10 05:15:39
- Status: DONE
- 결정사항:
  - workflows references의 Owner Skill 표기를 자동 검증하는 스크립트를 추가한다.
  - 미존재 스킬 참조를 실패로 처리한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/33

## 안건 14: Issue Reopen-First 강제(템플릿/PR 게이트/upsert)
- Created At: 2026-02-10 05:30:04
- Updated At: 2026-02-10 05:30:04
- Status: DONE
- 결정사항:
  - 같은 범위 작업은 기존 이슈 갱신/재오픈을 기본값으로 강제한다.
  - GitHub 이슈 폼/PR 템플릿/PR 검증 워크플로우를 추가해 누락을 차단한다.
  - `aki-mcp-github`에 `issue-upsert.sh`를 추가해 검색->기존 이슈 우선 처리 흐름을 실행 표준으로 고정한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/34
