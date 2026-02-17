---
name: aki-codex-workflows
description: |
  코덱스 실행 오케스트레이션 스킬.
  여러 스킬을 조합해 표준 실행 순서(Trigger/Why/Order/Condition/Done)를 적용하고, 단계별 Owner Skill을 명시해 누락 없는 작업 흐름을 보장한다.
  회의록 처리, pre-commit 실행, 세션 리로드 같은 크로스 스킬 절차를 일관된 규격으로 실행해야 할 때 사용한다.
---

# Aki Codex Workflows

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-10 01:48:58`
> - **Updated At**: `2026-02-17 17:28:03`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 목표
> - 오케스트레이션 원칙
> - 공통 실행 규격
> - 소유권 분리 규칙
> - 1차 Workflow References
> - 2차 Workflow References
> - SoT Drift Rule
> - 운영 스크립트
> - 결과 보고
<!-- DOC_TOC_END -->

## 목표
- 크로스 스킬 작업을 동일한 순서/판정 규격으로 실행한다.
- 단계별 Owner Skill을 명시해 책임 공백을 방지한다.
- 실패 시 중단/재시도 기준을 통일해 운영 예측성을 높인다.

## 오케스트레이션 원칙
1. 이 스킬은 "순서/분기/종료판정"만 담당한다.
2. 실제 실행 로직은 소유 스킬에 유지한다.
3. 단계마다 `Owner Skill`을 명시한다.
4. `Owner Skill` 없는 단계가 나오면 스킬화 권고를 보고한다.
   - `Gap`
   - `Risk`
   - `Proposed Skill`
   - `Boundary`
   - `Trigger`
5. 상태 충돌 시 SoT는 GitHub Issue를 우선한다.
6. `task.md`는 로컬 실행 보드/캐시로 취급한다.

## 공통 실행 규격
- `When`: 언제 실행하는지(트리거)
- `Why`: 왜 실행하는지(목적/효과)
- `Order`: 어떤 순서로 호출하는지(Owner Skill 기준)
- `Condition`: 분기/옵션/실패 처리
- `Done`: 종료 판정
  - `Completion`: 절차 수행 완료 여부
  - `Verification`: 검증 통과 여부
  - `Evidence`: 근거(출력/링크/리포트 경로)

## 소유권 분리 규칙
1. 이 스킬은 사용자 작업 오케스트레이션 문서 규격(When/Why/Order/Condition/Done)만 소유한다.
2. `run-skill-hooks.sh`/`engine.yaml` 같은 세션 부트스트랩 훅 실행기는 `aki-codex-session-reload` 소유로 취급한다.
3. 스크립트 기반 훅 실행기와 사용자 작업 오케스트레이션을 동일 개념으로 혼용하지 않는다.

## 1차 Workflow References
1. Meeting Notes Flow:
   - `references/meeting-notes-flow.md`
2. Pre-commit Flow:
   - `references/precommit-flow.md`
3. Session Reload Flow:
   - `references/session-reload-flow.md`

## 2차 Workflow References
1. GitHub MCP Init Flow:
   - `references/github-mcp-init-flow.md`
2. Pages Release Verification Flow:
   - `references/pages-release-verification-flow.md`
3. PR Merge Readiness Flow:
   - `references/pr-merge-readiness-flow.md`
4. Issue Lifecycle Governance Flow:
   - `references/issue-lifecycle-governance-flow.md`
5. Runtime Status Visibility Flow:
   - `references/runtime-status-flow.md`

## SoT Drift Rule
1. 상태 충돌 시 SoT는 GitHub Issue를 우선한다.
2. `task.md`는 실행 보드/캐시로 유지하고 원격 상태에 정렬한다.
3. 드리프트 점검/조치 절차는 아래 문서를 따른다.
   - `references/sot-drift-check-rule.md`

## 운영 스크립트
1. Owner Skill 링크 점검:
   - `scripts/check-owner-skill-links.sh`
   - 목적: workflows references의 `Owner Skill` 표기 누락/오타를 사전 차단
2. Workflow 실행 결과 마킹:
   - `scripts/workflow_mark.sh`
   - 목적: workflow별 최신 실행 결과(`PASS/FAIL/NOT_RUN/UNVERIFIED`)를 `.codex/state/workflow_marks.tsv`에 기록/조회

## 결과 보고
- 실행 후 아래를 반드시 보고한다.
  1. 실행한 workflow
  2. 단계별 Owner Skill 및 수행 결과
  3. `Done(Completion/Verification/Evidence)` 판정
  4. 실패/보류 단계와 다음 조치
