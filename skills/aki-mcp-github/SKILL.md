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
> - **Updated At**: `2026-02-09 20:39:37`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 목표
> - 로컬 실행 계약
> - Subflow References
> - 결과 보고
<!-- DOC_TOC_END -->

## 목표
- GitHub MCP 작업의 초기 준비(init)와 운영 실행을 단일 스킬로 정렬한다.
- 동일 세션에서 이슈/프로젝트/PR 작업의 누락과 중복을 줄인다.
- `aki-codex-workflows`가 호출 가능한 도메인 실행 스킬 역할을 제공한다.

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

## 결과 보고
- 실행 후 반드시 아래를 보고한다.
  1. 실행한 subflow(`init` | `meeting-notes-sync` | `issue-pr-flow`)
  2. 성공/실패 항목 요약
  3. 생성/갱신/종료된 GitHub 링크
  4. 재시도 필요 작업
