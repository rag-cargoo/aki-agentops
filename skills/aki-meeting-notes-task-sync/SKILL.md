---
name: aki-meeting-notes-task-sync
description: |
  회의록 문서를 Active Project의 `prj-docs/task.md` 실행 TODO로 동기화하는 도메인 실행 스킬.
  회의 직후 안건/결정/후속작업을 task 보드의 실행 항목으로 내려야 할 때 사용한다.
  특히 `meeting-notes/*.md`를 근거로 `task.md`의 Next Tasks, 체크리스트, 담당/기한 상태를 갱신해야 하는 상황에서 사용한다.
---

# Aki Meeting Notes Task Sync

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 08:00:53`
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
> - 입력/출력
> - 실행 절차
> - 매핑 규칙
> - 작성 규칙
> - 결과 보고
> - 참고 문서
<!-- DOC_TOC_END -->

## 목표
- 회의록의 합의사항을 실행 가능한 TODO로 표준 변환한다.
- `task.md`에 남는 작업 누락과 중복을 줄인다.
- 회의 문맥과 실행 보드 사이 추적성을 확보한다.

## 오케스트레이션 경계
- 이 스킬은 회의록->`task.md` 동기화 실행만 담당한다.
- 크로스 스킬 순서/분기/종료판정은 `aki-codex-workflows`를 권위 소스로 따른다.

## 입력/출력
- 입력:
  - Active Project의 회의록 파일 1개 이상
  - 기본 경로: `workspace/**/prj-docs/meeting-notes/*.md`
- 출력:
  - Active Project의 `prj-docs/task.md` 갱신
  - 필요 시 `Notes` 섹션의 완료 이력/다음 작업 동기화

## 실행 절차
1. Active Project를 확인하고 대상 `task.md` 경로를 확정한다.
2. 최신 회의록(또는 사용자 지정 회의록)에서 `후속작업` 항목을 추출한다.
3. 동일 작업이 이미 `task.md`에 존재하는지 중복을 검사한다.
4. 신규 항목은 `다음 작업` 또는 TODO 체크리스트에 추가한다.
5. 완료 항목(`DONE`)은 `현재 완료` 섹션으로 이동 또는 `[x]` 처리한다.
6. 업데이트된 `task.md`와 회의록 간 참조 일관성을 최종 검증한다.

## 매핑 규칙
1. 회의록 `후속작업`의 `상태: TODO`
   - `task.md`의 미완료 TODO로 추가한다.
2. 회의록 `후속작업`의 `상태: DOING`
   - `task.md`의 진행 중 항목으로 추가하고 진행 상태를 명시한다.
3. 회의록 `후속작업`의 `상태: DONE`
   - `task.md` 완료 목록 또는 완료 체크(`[x]`)에 반영한다.
4. 회의록에 `기한`, `담당`이 있으면 항목 라인에 보존한다.

## 작성 규칙
- 기존 `task.md` 상세 내용을 삭제하지 않고 확장 방식으로 반영한다.
- 항목 문구는 "무엇을/왜/언제"가 보이도록 짧고 실행 가능하게 작성한다.
- 하나의 TODO는 하나의 완료 기준(Definition of Done)을 갖도록 분해한다.
- 적용 전/후 diff에서 기존 맥락 손실이 없는지 확인한다.

## 결과 보고
- 실행 후 아래를 보고한다.
  1. 입력 회의록 파일 경로
  2. `task.md` 반영 경로
  3. 신규 TODO/갱신 TODO/완료 처리 항목 수
  4. 중복으로 스킵한 항목
  5. 수동 확인이 필요한 항목

## 참고 문서
- 상세 매핑 템플릿: `references/task-sync-template.md`
