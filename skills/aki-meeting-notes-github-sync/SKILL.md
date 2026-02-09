---
name: aki-meeting-notes-github-sync
description: |
  회의록 Markdown 파일을 GitHub 운영 항목으로 동기화하는 MCP 전용 스킬.
  회의 후 안건/결정/후속작업을 이슈, 프로젝트 카드, PR 추적 항목으로 즉시 반영해야 할 때 사용한다.
  local fallback 없이 GitHub MCP toolset(context, repos, issues, projects, pull_requests, labels)만 사용한다.
---

# Meeting Notes GitHub Sync

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 07:07:52`
> - **Updated At**: `2026-02-09 07:07:52`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 목표
> - 입력 형식
> - 사전 조건
> - 실행 절차
> - 매핑 규칙
> - 결과 보고
<!-- DOC_TOC_END -->

## 목표
- 회의록의 실행 항목을 GitHub 이슈/프로젝트/PR 추적으로 일관되게 반영한다.
- 팀 커뮤니케이션 단위를 "회의록 문장"에서 "추적 가능한 GitHub 객체"로 변환한다.
- 세션마다 동일한 절차로 동작해 누락/중복을 줄인다.

## 입력 형식
- 입력 파일: `workspace/**/prj-docs/meeting-notes/*.md`
- 최소 필드:
  1. 안건 제목
  2. 상태(`TODO|DOING|DONE`)
  3. 결정사항
  4. 후속작업(담당/기한/상태)
- 여러 파일이 있으면 최신 날짜 파일을 기본 대상으로 선택한다.

## 사전 조건
1. GitHub MCP 서버가 연결되어 있어야 한다.
2. 아래 toolset이 enable 상태여야 한다.
   - `context`
   - `repos`
   - `issues`
   - `projects`
   - `pull_requests`
   - `labels`
3. 대상 저장소(owner/repo)와 기본 프로젝트(필요 시)를 먼저 확정한다.

## 실행 절차
1. 회의록 파일에서 안건 단위를 파싱하고, 각 안건의 실행 가능한 후속작업만 추출한다.
2. 각 항목에 대해 기존 GitHub 이슈/PR 중복 여부를 먼저 검색한다.
3. 중복이 없으면 이슈를 생성하고, 중복이 있으면 기존 이슈를 업데이트한다.
4. 라벨 정책에 맞춰 라벨을 보정한다(없으면 생성, 있으면 재사용).
5. 프로젝트를 사용하는 팀이면 생성/갱신된 이슈를 프로젝트에 연결하고 상태를 반영한다.
6. PR 링크가 회의록에 이미 있으면 해당 PR과 이슈를 상호 참조로 정리한다.
7. 회의록 원문에 `Issue/PR` 링크를 역기록해 문서-트래킹 왕복 링크를 완성한다.

## 매핑 규칙
1. `TODO`:
   - 기본 동작: Issue 생성(open)
   - 프로젝트 사용 시: Backlog/Todo 컬럼으로 배치
2. `DOING`:
   - 기본 동작: Issue 유지(open) + 진행 코멘트 동기화
   - PR 존재 시: PR을 연결하고 상태를 In Progress로 정렬
3. `DONE`:
   - PR merge 완료 시: Issue close
   - PR 미완료 시: close하지 않고 검증 대기 라벨을 추가
4. 제목 규칙:
   - `[Meeting:<YYYY-MM-DD>] <안건 요약>`
5. 라벨 기본셋:
   - `meeting`
   - `action-item`
   - 상태 라벨(`status:todo|status:doing|status:done`)

## 결과 보고
- 스킬 실행 후 반드시 아래를 사용자에게 보고한다.
  1. 입력 회의록 파일 경로
  2. 생성/갱신/종료된 Issue 목록
  3. 연결/갱신된 PR 목록
  4. 프로젝트 반영 결과
  5. 실패 항목과 재시도 필요 작업
