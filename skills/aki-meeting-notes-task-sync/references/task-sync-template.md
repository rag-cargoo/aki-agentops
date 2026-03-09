# Task Sync Template

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
> - 1) Meeting Note Input Checklist
> - 2) Task.md Update Targets
> - 3) Mapping Snippet
> - 4) De-duplication Rule
> - 5) Output Report Template
<!-- DOC_TOC_END -->

> [!NOTE]
> 회의록 후속작업을 `task.md` 실행 TODO로 내릴 때 사용하는 표준 템플릿이다.

## 1) Meeting Note Input Checklist

- Source file: `workspace/**/prj-docs/meeting-notes/<date>-<topic>.md`
- Confirm each agenda has:
  - `Status`
  - `결정사항`
  - `후속작업` (`담당`, `기한`, `상태`)

## 2) Task.md Update Targets

- Preferred order:
  1. `다음 작업` (미완료 항목)
  2. `현재 완료` 또는 완료 체크리스트 (완료 항목)

## 3) Mapping Snippet

Use this bullet format when appending TODO entries:

```md
- [ ] <작업 제목> (source: <meeting-note-file>, owner: <담당>, due: <YYYY-MM-DD>, status: TODO|DOING)
```

Use this bullet format for completed items:

```md
- [x] <작업 제목> (source: <meeting-note-file>, owner: <담당>, done: <YYYY-MM-DD>)
```

## 4) De-duplication Rule

- If title + owner + due are same as existing entry, update status only.
- Do not append duplicates.

## 5) Output Report Template

```md
- Input Note: <path>
- Updated Task Doc: <path>
- Added TODO: <n>
- Updated Existing: <n>
- Marked DONE: <n>
- Skipped Duplicates: <n>
- Follow-up Needed: <items>
```
