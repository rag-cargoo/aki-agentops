# Meeting Notes: Aki Skill Governance Scope & Boundary

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-10 03:40:47`
> - **Updated At**: `2026-02-10 04:28:10`
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
