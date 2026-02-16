# Meeting Notes: Codex Workflows Skill Planning

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 20:18:06`
> - **Updated At**: `2026-02-17 06:18:00`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 실행 담당 스킬 분리 필요성
> - 안건 2: `aki-codex-workflows` 구조 초안
> - 안건 3: 우선 적용 워크플로우 범위
> - 안건 4: 스킬 내부 워크플로우 유지 범위
> - 안건 5: 추가 후보 워크플로우 검토
> - 안건 6: 워크플로우 정의 규격(Trigger/Why/Order/Condition/Done)
> - 안건 7: 운영 가드레일(SoT/Owner Skill Gap/실패정책)
<!-- DOC_TOC_END -->

## 안건 1: 실행 담당 스킬 분리 필요성
- Created At: 2026-02-09 20:18:06
- Updated At: 2026-02-09 20:18:06
- Status: DONE
- 결정사항:
  - 현재는 코어/세션리로드/precommit/미팅/GitHub 스킬 간 실행 책임이 분산되어, 실제 작업 순서 판단이 애매할 수 있다.
  - 실행 순서와 의사결정(필수/옵션 단계를 포함)을 한 곳에서 관리하는 전담 스킬이 필요하다.
  - 전담 스킬명 후보는 `aki-codex-workflows`로 확정 검토한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/19

## 안건 2: `aki-codex-workflows` 구조 초안
- Created At: 2026-02-09 20:18:06
- Updated At: 2026-02-09 20:18:06
- Status: DONE
- 결정사항:
  - `aki-codex-workflows`는 오케스트레이션 전용으로 운영한다.
  - 실제 실행 로직(스크립트/정책)은 기존 소유 스킬(`aki-codex-session-reload`, `aki-codex-precommit`, `aki-mcp-github` 등)에 유지한다.
  - `aki-codex-workflows`는 각 플로우를 references 문서로 정의하고, 트리거 시 해당 순서대로 호출/검증한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/19

## 안건 3: 우선 적용 워크플로우 범위
- Created At: 2026-02-09 20:18:06
- Updated At: 2026-02-09 20:18:06
- Status: DOING
- 결정사항:
  - 1차(즉시 운영) 대상은 아래 3개로 제한한다.
    - 회의록 운영 플로우: 회의록 작성 -> (로컬) `task.md` 기록 -> GitHub 이슈 등록 -> PR(옵션)
    - pre-commit 플로우: quick/strict 선택 기준 + 정책 체인 실행
    - session reload 플로우: session_start/reload 트리거와 필수 체크 순서
  - 2차(확장 검토) 후보는 안건 5에서 별도 관리한다.
  - 구현 착수 전에 각 1차 플로우의 완료조건(Definition of Done)과 예외 처리 기준을 먼저 문서로 확정한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DOING
  - 비고: 현재 단계는 회의록 기록 및 개선 방향 검토이며, 실제 스킬 생성/리팩터링 작업은 후속으로 진행한다.

## 안건 4: 스킬 내부 워크플로우 유지 범위
- Created At: 2026-02-09 20:21:49
- Updated At: 2026-02-09 20:21:49
- Status: DONE
- 결정사항:
  - 각 소유 스킬의 워크플로우를 완전 제거하지 않는다.
  - 대신 각 스킬에는 "로컬 실행 계약(Local Run Contract)"만 남긴다.
    - 엔트리포인트 명령
    - 입력/출력
    - 성공/실패 판정
    - 복구 명령
  - 크로스 스킬 순서/분기/옵션 단계는 `aki-codex-workflows`로 단일화한다.
  - 결과적으로 "실행 방법(How)"은 소유 스킬, "실행 순서(When/Order)"는 워크플로우 스킬이 담당한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/19

## 안건 5: 추가 후보 워크플로우 검토
- Created At: 2026-02-09 20:21:49
- Updated At: 2026-02-09 20:21:49
- Status: DONE
- 결정사항:
  - 2차 후보 워크플로우를 아래처럼 분리 검토한다.
    - 스킬 수명주기 플로우: 생성 -> 리네이밍/분해 -> 검증 -> 폐기
    - GitHub MCP 준비 플로우: init(권한/툴셋/검증) -> 작업 가능 범위 확정
    - 이슈-브랜치-PR 플로우: 이슈 생성 -> 작업 브랜치 -> PR -> 머지/종료
    - Pages 릴리즈 플로우: develop 검증 -> main 전환 -> 배포 상태 확인
    - 사고 복구 플로우: 백업 포인트 생성 -> 장애 대응 -> 복구 검증
  - 위 후보는 1차 3개 워크플로우 안정화 후 순차 도입한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-11
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/19
  - 비고: 후보별 우선순위/도입 조건은 다음 회의에서 확정한다.

## 안건 6: 워크플로우 정의 규격(Trigger/Why/Order/Condition/Done)
- Created At: 2026-02-09 20:35:14
- Updated At: 2026-02-09 20:35:14
- Status: DONE
- 결정사항:
  - `aki-codex-workflows`의 각 플로우는 아래 5개 필드를 필수로 갖는다.
    - `When`: 실행 시점/트리거 조건
    - `Why`: 실행 목적/기대 효과
    - `Order`: 호출 순서(Owner Skill 기준)
    - `Condition`: 분기/옵션/실패 시 처리 규칙
    - `Done`: 종료 판정
  - `Done`은 아래 3분할로 고정한다.
    - `Completion`: 절차 수행 완료 여부
    - `Verification`: 검증 통과 여부
    - `Evidence`: 검증 근거(출력/링크/리포트 경로)
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/19

## 안건 7: 운영 가드레일(SoT/Owner Skill Gap/실패정책)
- Created At: 2026-02-09 20:35:14
- Updated At: 2026-02-09 20:35:14
- Status: DONE
- 결정사항:
  - 상태 충돌 시 단일 진실원천(SoT)은 GitHub Issue를 우선한다.
  - `task.md`는 로컬 실행 보드/캐시로 취급한다.
  - 각 워크플로우 단계는 `Owner Skill`을 반드시 명시한다.
  - `Owner Skill`이 없는 단계가 발견되면 에이전트는 스킬화 권고(`Gap/Risk/Proposed Skill/Boundary/Trigger`)를 보고한다.
  - 실패정책은 단계별로 `중단(Stop)` vs `재시도(Retry)`를 명시하고, 기본값은 보수적으로 `중단 후 보고`를 우선한다.
  - 트리거가 충돌하면 사용자 명시 요청을 최우선으로 하고, 명시가 없으면 안전성 우선 순서(세션 무결성 -> 품질 게이트 -> 추적 동기화)로 처리한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/19
