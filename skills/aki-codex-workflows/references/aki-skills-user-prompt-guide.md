# Aki Skills User Prompt Guide

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-10 10:03:18`
> - **Updated At**: `2026-02-17 17:28:03`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Owner
> - 빠른 시작 프롬프트
> - 작업별 프롬프트
> - 운영 확장 프롬프트
> - 기대 결과 형식
> - 운영 팁
<!-- DOC_TOC_END -->

이 문서는 사용자 관점에서 Aki 스킬을 프롬프트로 호출할 때, 어떤 요청을 하면 어떤 결과를 받는지 빠르게 확인하기 위한 가이드다.

## Owner

- Owner Skill: `aki-codex-workflows`

## 빠른 시작 프롬프트

- 상태 확인: `상태정보 보여줘`
- 경고만 확인: `런타임 경고만 보여줘`
- MCP만 확인: `MCP 인벤토리 보여줘`
- 문서 최신화: `문서 최신화해줘`
- 세션 기준선 재동기화: `세션 리로드해줘`
- 회의록 작성: `회의록 작성해줘`
- 회의록 후속 반영: `이 회의록 기준으로 task.md랑 GitHub 이슈까지 동기화해줘`
- 커밋 전 점검: `프리커밋 quick 실행해줘` 또는 `프리커밋 strict 실행해줘`

## 작업별 프롬프트

### 1) Runtime 상태 점검

- 프롬프트:
  - `상태정보`
  - `런타임 상태 보여줘`
  - `MCP 인벤토리 보여줘`
- 기대 결과:
  - `[User Controls]`, `[Agent Checks]`, `[Workflow Health]`, `[Skill Inventory]`, `[MCP Inventory]` 섹션을 출력한다.
  - WARN/MISSING 항목이 있으면 `[Alerts]`에 함께 표시된다.

### 2) 회의록 -> TODO -> GitHub 이슈 동기화

- 프롬프트:
  - `회의록 작성해줘`
  - `이 회의록으로 task.md 업데이트하고 이슈도 올려줘`
  - `PR은 생략하고 이슈까지만 반영해줘`
- 기대 결과:
  - 회의록 파일 생성 또는 업데이트
  - Active Project의 `prj-docs/task.md` 동기화
  - GitHub 이슈 생성/재오픈/코멘트 반영
  - 회의록과 이슈 링크의 상호 참조 정리

### 3) GitHub MCP 준비/점검

- 프롬프트:
  - `GitHub MCP init 진행해줘`
  - `GitHub MCP 상태 확인해줘`
- 기대 결과:
  - 기본 toolset(`context,repos,issues,projects,pull_requests,labels`) 준비 여부를 확인한다.
  - 미설정 시 필요한 후속 액션을 안내한다.

### 4) Pre-commit 모드 제어

- 프롬프트:
  - `프리커밋 모드 상태 보여줘`
  - `프리커밋 quick로 바꿔줘`
  - `프리커밋 strict로 바꿔줘`
- 기대 결과:
  - 현재 모드와 strict 여부를 표시한다.
  - 모드 변경 시 런타임 상태에도 반영된다.

### 5) GitHub Pages 문서 검증

- 프롬프트:
  - `Pages 문서 검증해줘`
  - `사이드바 링크 깨짐 확인해줘`
- 기대 결과:
  - Docsify 스타일/링크/무결성 검증 결과를 보고한다.
  - 필요 시 `sidebar-manifest.md` 보정 포인트를 함께 제시한다.

## 운영 확장 프롬프트

### 6) 이슈 라이프사이클(Reopen-first)

- 프롬프트:
  - `연관 이슈 찾아서 reopen-first로 처리해줘`
  - `기존 이슈 재사용해서 업데이트해줘`
- 기대 결과:
  - 동일 범위 이슈가 있으면 재오픈/코멘트 누적을 우선 수행한다.
  - 동일 범위가 없을 때만 신규 이슈를 만든다.
  - 이슈 난발 없이 추적 축을 유지한다.

### 7) PR 머지 준비도 점검(Go/No-Go)

- 프롬프트:
  - `이 PR 머지 준비도 점검해줘`
  - `머지 Go/No-Go 판정해줘`
- 기대 결과:
  - pre-commit, 세션 무결성, 추적 동기화(드리프트) 기준으로 판정한다.
  - 머지 가능/보류 사유를 근거와 함께 보고한다.

### 8) Pages 릴리즈 최종 검증

- 프롬프트:
  - `main 머지 전에 Pages 릴리즈 체크해줘`
  - `Pages source branch/path 점검해줘`
- 기대 결과:
  - Pages 상태(`built` 여부), 사이드바/링크, 핵심 문서 접근성을 점검한다.
  - 실패 시 보류 사유와 수정 포인트를 보고한다.

### 9) SoT 드리프트 점검(task.md vs GitHub)

- 프롬프트:
  - `task.md와 GitHub 이슈 상태 드리프트 점검해줘`
  - `SoT 기준으로 상태 정렬해줘`
- 기대 결과:
  - 충돌 시 GitHub Issue를 SoT로 삼아 `task.md`를 정렬한다.
  - `Local Ahead`, `Remote Ahead`, `Link Missing` 분류로 보고한다.

### 10) Active Project 전환/목록

- 프롬프트:
  - `활성 프로젝트 목록 보여줘`
  - `활성 프로젝트를 workspace/... 로 바꿔줘`
- 기대 결과:
  - 프로젝트 목록을 조회하고 활성 프로젝트를 전환한다.
  - 전환 후 project snapshot/task 경로를 함께 재동기화한다.

### 11) Session Handoff 작성/정리

- 프롬프트:
  - `세션 핸드오프 작성해줘`
  - `이어받기 끝났으니 핸드오프 정리해줘`
- 기대 결과:
  - `mcp/runtime/SESSION_HANDOFF.md` 작성(+ archive 사본) 또는 정리를 수행한다.
  - 다음 세션 첫 프롬프트와 후속 액션을 명시한다.

### 12) 문서 최신화/동기화

- 프롬프트:
  - `문서 최신화해줘`
  - `문서 메타랑 목차 동기화해줘`
  - `문서 스타일 검증까지 해줘`
- 기대 결과:
  - 관리 문서의 DOC_META/DOC_TOC가 최신 상태로 동기화된다.
  - Docsify 스타일/규칙 검증을 함께 수행한다.
  - 필요 시 누락 항목(메타/목차/링크) 보정 포인트를 보고한다.

## 기대 결과 형식

- 상태 보고는 기본적으로 요약 + 핵심 경로 + 필요한 다음 액션 순으로 제공된다.
- 파일 변경이 발생하면 변경 파일 경로를 함께 제시한다.
- GitHub 반영이 있으면 이슈/PR URL 또는 번호를 함께 제시한다.

## 운영 팁

- 회의 직후에는 한 번에 요청:
  - `회의록 작성하고 task.md랑 이슈까지 동기화해줘`
- 커밋 직전에는 반드시 요청:
  - `프리커밋 strict 실행해줘`
- 설정/상태 혼선이 생기면 먼저 요청:
  - `상태정보 보여줘`
