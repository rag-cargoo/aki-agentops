# Meeting Notes: Aki Skill Governance Scope & Boundary

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-10 03:40:47`
> - **Updated At**: `2026-02-10 07:33:55`
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
> - 안건 15: 세션 환경 부트스트랩/검증 자동화(.codex/.githooks)
> - 안건 16: Runtime Flags 상태표/옵션 즉시 동기화
> - 안건 17: Runtime Status 표 분리(User Controls/Agent Checks)
> - 안건 18: Runtime Status Pages/품질 가드 항목 확장
> - 안건 19: Runtime Status 전체 Skill Inventory 표시
> - 안건 20: Runtime Status MCP Inventory 표시
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

## 안건 15: 세션 환경 부트스트랩/검증 자동화(.codex/.githooks)
- Created At: 2026-02-10 05:53:55
- Updated At: 2026-02-10 05:53:55
- Status: DONE
- 결정사항:
  - 새 PC/세션에서 동일 동작 재현을 위해 `bootstrap_env.sh`/`validate_env.sh`를 추가한다.
  - `session_start.sh`는 세션 시작 시 환경 검증 결과를 Startup Checks에 반영한다.
  - pre-commit `strict`는 이벤트 기반 트리거(중요 커밋/머지 직전/릴리즈 직전/대규모 리팩터링 완료)로 운영한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/35

## 안건 16: Runtime Flags 상태표/옵션 즉시 동기화
- Created At: 2026-02-10 06:54:11
- Updated At: 2026-02-10 06:54:11
- Status: DONE
- 결정사항:
  - `aki-codex-session-reload`가 runtime flags 저장/상태표 출력의 단일 소유 스킬로 관리한다.
  - 세션 시작 시 `runtime_flags.sh sync`를 자동 실행해 `.codex/state/runtime_flags.yaml`와 `.codex/runtime/current_status.txt`를 갱신한다.
  - `precommit_mode.sh` 모드 전환 시 runtime flags를 즉시 재동기화해 세션 중 변경 반영성을 확보한다.
  - 출력 타이밍은 `aki-codex-workflows`의 Runtime Status Visibility Flow로 규정한다(세션 시작 1회/옵션 변경 직후/사용자 요청 시).
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/36

## 안건 17: Runtime Status 표 분리(User Controls/Agent Checks)
- Created At: 2026-02-10 07:14:16
- Updated At: 2026-02-10 07:14:16
- Status: DONE
- 결정사항:
  - Runtime Status는 `User Controls`와 `Agent Checks` 2개 섹션으로 분리한다.
  - `session_handoff`처럼 사용자 제어 대상이 아닌 항목은 ON/OFF 대신 존재 여부(`PRESENT/ABSENT`)로 표시한다.
  - 사용자 요청이 없으면 상태표는 기본 숨김으로 두고, 세션 시작/옵션 변경/요청 시점에만 노출한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/37

## 안건 18: Runtime Status Pages/품질 가드 항목 확장
- Created At: 2026-02-10 07:22:38
- Updated At: 2026-02-10 07:22:38
- Status: DONE
- 결정사항:
  - Agent Checks에 Pages 상태 항목(`pages_skill`, `pages_docsify_validator`, `pages_release_flow`)을 추가한다.
  - Agent Checks에 품질 가드 항목(`docsify_precommit_guard`, `owner_skill_lint_guard`, `skill_naming_guard`)을 추가한다.
  - 상태 항목은 로컬 소스/정책 스크립트 기준으로 계산해 네트워크 의존 없이 빠르게 확인 가능하도록 유지한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/38

## 안건 19: Runtime Status 전체 Skill Inventory 표시
- Created At: 2026-02-10 07:27:53
- Updated At: 2026-02-10 07:27:53
- Status: DONE
- 결정사항:
  - Runtime Status에 `Skill Inventory` 섹션을 추가해 전체 스킬을 행 단위로 표시한다.
  - managed/delegated 카운트와 목록을 함께 기록해 누락 여부를 즉시 점검 가능하게 한다.
  - 상태 스냅샷(`runtime_flags.yaml`)에도 동일 집계 값을 저장한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/39

## 안건 20: Runtime Status MCP Inventory 표시
- Created At: 2026-02-10 07:33:55
- Updated At: 2026-02-10 07:33:55
- Status: DONE
- 결정사항:
  - Runtime Status에 `MCP Inventory` 섹션을 추가해 서버별 runtime/status/detail을 표시한다.
  - GitHub MCP Docker 서버는 컨테이너/프로세스 기반으로 기동 상태를 판정하고, daemon 조회 제한 시 `probe=RESTRICTED` detail을 기록한다.
  - 상태 스냅샷(`runtime_flags.yaml`)에도 MCP 집계 및 서버별 상세 키를 저장한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/40
