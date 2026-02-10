# Aki Skills User Prompt Guide

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-10 10:03:18`
> - **Updated At**: `2026-02-10 10:04:12`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 빠른 시작 프롬프트
> - 작업별 프롬프트
> - 기대 결과 형식
> - 운영 팁
<!-- DOC_TOC_END -->

이 문서는 사용자 관점에서 Aki 스킬을 프롬프트로 호출할 때, 어떤 요청을 하면 어떤 결과를 받는지 빠르게 확인하기 위한 가이드다.

## Owner

- Owner Skill: `aki-codex-workflows`

## 빠른 시작 프롬프트

- 상태 확인: `상태정보 보여줘`
- 세션 기준선 재동기화: `세션 리로드해줘`
- 회의록 작성: `회의록 작성해줘`
- 회의록 후속 반영: `이 회의록 기준으로 task.md랑 GitHub 이슈까지 동기화해줘`
- 커밋 전 점검: `프리커밋 quick 실행해줘` 또는 `프리커밋 strict 실행해줘`

## 작업별 프롬프트

### 1) Runtime 상태 점검

- 프롬프트:
  - `상태정보`
  - `런타임 상태 보여줘`
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
