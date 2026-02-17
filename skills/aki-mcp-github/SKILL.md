---
name: aki-mcp-github
description: |
  GitHub MCP 통합 운영 스킬.
  GitHub MCP init(기본 toolset 활성/검증), 회의록 기반 이슈/프로젝트/PR 동기화, 이슈-브랜치-PR 운영 흐름을 단일 진입점으로 제공한다.
  GitHub 관련 작업을 시작하거나, 회의록 실행 항목을 GitHub 트래킹 객체로 반영해야 할 때 사용한다.
---

# Aki MCP GitHub

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 20:39:37`
> - **Updated At**: `2026-02-17 17:28:03`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 목표
> - 오케스트레이션 경계
> - 로컬 실행 계약
> - Subflow References
> - Issue Lifecycle Policy
> - 운영 스크립트
> - 결과 보고
<!-- DOC_TOC_END -->

## 목표
- GitHub MCP 작업의 초기 준비(init)와 운영 실행을 단일 스킬로 정렬한다.
- 동일 세션에서 이슈/프로젝트/PR 작업의 누락과 중복을 줄인다.
- `aki-codex-workflows`가 호출 가능한 도메인 실행 스킬 역할을 제공한다.

## 오케스트레이션 경계
- 이 스킬은 GitHub MCP 도메인 실행(init/meeting-notes-sync/issue-pr-flow)만 담당한다.
- 크로스 스킬 호출 순서와 조건 분기는 `aki-codex-workflows` 문서를 권위 소스로 사용한다.

## 로컬 실행 계약
- Entry Points:
  - `mcp__github__list_available_toolsets`
  - `mcp__github__enable_toolset`
  - GitHub 관련 MCP 호출(`issues`, `projects`, `pull_requests`, `labels`, `repos`, `context`)
- Input:
  - 대상 저장소(owner/repo), 회의록 파일 경로(선택), 운영 목적(init/sync/issue-pr)
- Output:
  - 활성화 결과(Enabled/Already/Failed/Unsupported)
  - 생성/갱신된 GitHub 객체 링크(issue/pr/project)
- Success:
  - init 경로: 대상 toolset 준비 상태가 확인됨
  - 운영 경로: 요청된 이슈/PR/프로젝트 반영이 완료됨
- Failure:
  - MCP 서버/권한/연결 실패 시 GitHub 변경 작업 중단 후 원인 보고

## Subflow References
1. Init Flow:
   - `references/init.md`
2. Meeting Notes Sync Flow:
   - `references/meeting-notes-sync.md`
3. Issue-PR Flow:
   - `references/issue-pr-flow.md`
4. Issue Lifecycle Policy:
   - `references/issue-lifecycle-policy.md`

## Issue Lifecycle Policy
1. 같은 범위의 후속작업은 기존 이슈 갱신/재오픈을 기본값으로 처리한다.
2. 새 이슈 생성은 범위가 달라진 경우에만 허용한다.
3. 새 이슈 생성 시 "왜 재오픈이 아닌지" 근거를 남긴다.
4. 정책 상세는 `references/issue-lifecycle-policy.md`를 따른다.

## 운영 스크립트
1. 이슈 업서트(재오픈 우선):
   - `scripts/issue-upsert.sh`
   - 기능: 검색 -> 기존 open 갱신 / closed reopen / 없으면 신규 생성
2. GitHub MCP init 마크 동기화:
   - `scripts/github-init-mark.sh`
   - 기능: init 결과를 `github_mcp_init` workflow mark(`PASS`/`FAIL`/`NOT_RUN`)로 기록

## 결과 보고
- 실행 후 반드시 아래를 보고한다.
  1. 실행한 subflow(`init` | `meeting-notes-sync` | `issue-pr-flow`)
  2. 성공/실패 항목 요약
  3. 생성/갱신/종료된 GitHub 링크
  4. 재시도 필요 작업
  5. `init` 실행 시 workflow mark 동기화 결과(`github_mcp_init`) 포함
