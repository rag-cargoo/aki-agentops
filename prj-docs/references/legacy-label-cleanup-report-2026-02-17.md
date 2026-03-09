# Legacy Label Cleanup Report (2026-02-17)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 09:24:40`
> - **Updated At**: `2026-02-17 17:14:21`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Scan Command
> - Classification Summary
> - Preserve Targets (Historical Context)
> - Replace Targets (Operational Docs)
> - Action Result
> - Residual Check
<!-- DOC_TOC_END -->

## Scope
- `TSK-2602-016` 기준으로 레거시 표기(`2602`, 구 슬러그/구 경로)를 전수 스캔하고 `보존`/`치환`으로 분류했다.
- 기준일: 2026-02-17

## Scan Command
```bash
rg -n -S -- "(\\b2602\\b|/home/aki/2602|rag-cargoo/2602|https://rag-cargoo.github.io/2602/|/2602/)" .
```

## Classification Summary
- Preserve: 7건
- Replace: 3건
- Replace applied: 3건 (완료)
- Follow-up task (`TSK-2602-017+`): not-required

## Preserve Targets (Historical Context)
1. `README.md`의 `Previous Repository Slug: 2602` 표기
2. `prj-docs/references/repository-rename-migration-note.md` 내 레거시 매핑 표기
3. `prj-docs/meeting-notes/2026-02-17-repo-architecture-refactoring-agenda.md` 증빙 커맨드
4. `prj-docs/meeting-notes/2026-02-17-repo-rename-readme-governance-planning.md` 리스크 설명
5. `prj-docs/task.md`의 과거 완료 증빙(`TSK-2602-001`)
6. `prj-docs/task.md`의 `TSK-2602-015` 설명(정리 대상 정의 기록)
7. `prj-docs/references/repository-rename-migration-note.md`의 검사 규칙(`/2602/` 금지)

## Replace Targets (Operational Docs)
1. `prj-docs/projects/README.md`
   - `Project Sidecar Index (2602)` -> `Project Sidecar Index (AKI AgentOps)`
   - `2602 sidecar` -> `AKI AgentOps sidecar`
2. `prj-docs/projects/ticket-core-service/rules/architecture.md`
   - `2602 sidecar` -> `AKI AgentOps sidecar`
3. `prj-docs/references/repo-architecture-gap-map.md`
   - 제목/Scope/표에서 `2602` 중심 표기를 `AKI AgentOps` 기준으로 정렬
   - Scope에 `구 명칭: 2602` 호환 주석 유지

## Action Result
- Replace 대상 3건을 모두 치환 반영했다.
- 호환성/증빙 맥락이 필요한 레거시 표기는 Preserve 대상으로 유지했다.

## Residual Check
```bash
rg -n -S --glob '!prj-docs/meeting-notes/**' --glob '!prj-docs/task.md' -- "(\\b2602\\b|/home/aki/2602|rag-cargoo/2602|https://rag-cargoo.github.io/2602/|/2602/)" .
```
- 결과 해석:
  - 운영 문서의 치환 대상은 반영 완료
  - 잔여 값은 호환 주석/마이그레이션 문서/역사적 문맥으로 분류된 Preserve 대상
