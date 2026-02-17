# Document Target/Surface Inventory (2026-02-17)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 11:21:48`
> - **Updated At**: `2026-02-17 11:22:41`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Scan Basis
> - Classification Rule Summary
> - Totals
> - Navigation Split Result
> - Notes
<!-- DOC_TOC_END -->

## Scope
- `TSK-2602-018` 기준으로 저장소의 tracked markdown 파일을 `Target`/`Surface`로 분류한다.
- 기준 파일: `git ls-files '*.md'`
- 기준 시점 총 파일수: `90`

## Scan Basis
```bash
git ls-files '*.md' | sort | wc -l
```

## Classification Rule Summary
| Rule | Target | Surface | Count | Example |
| --- | --- | --- | ---: | --- |
| `agents_entry` | `AGENT` | `AGENT_NAV` | 1 | `AGENTS.md` |
| `skills_domain` | `AGENT` | `AGENT_NAV` | 55 | `skills/aki-codex-core/SKILL.md` |
| `runtime_engine_domain` | `AGENT` | `AGENT_NAV` | 9 | `workspace/agent-skills/codex-runtime-engine/README.md` |
| `root_meeting_notes` | `HUMAN` | `PUBLIC_NAV` | 4 | `prj-docs/meeting-notes/README.md` |
| `project_meeting_notes` | `HUMAN` | `PUBLIC_NAV` | 1 | `prj-docs/projects/ticket-core-service/meeting-notes/README.md` |
| `human_entry` | `HUMAN` | `PUBLIC_NAV` | 2 | `README.md` |
| `root_task` | `BOTH` | `PUBLIC_NAV` | 1 | `prj-docs/task.md` |
| `governance_references` | `BOTH` | `PUBLIC_NAV` | 5 | `prj-docs/references/document-target-surface-governance.md` |
| `project_sidecar` | `BOTH` | `PUBLIC_NAV` | 5 | `prj-docs/projects/README.md` |
| `mcp_ops` | `BOTH` | `PUBLIC_NAV` | 4 | `mcp/README.md` |
| `repo_internal` | `AGENT` | `HIDDEN` | 2 | `.gemini/GEMINI.md` |
| `sidebar_control` | `AGENT` | `HIDDEN` | 1 | `sidebar-manifest.md` |

## Totals
### By Target
- `AGENT`: 68
- `BOTH`: 15
- `HUMAN`: 7

### By Surface
- `AGENT_NAV`: 65
- `PUBLIC_NAV`: 22
- `HIDDEN`: 3

## Navigation Split Result
1. Public sidebar:
   - 파일: `sidebar-manifest.md`
   - 성격: 사용자 중심(`HUMAN` + 운영 `BOTH`)
2. Agent sidebar:
   - 파일: `sidebar-agent-manifest.md`
   - 성격: 스킬/런타임/운영 자동화 중심(`AGENT`)
3. Runtime switching:
   - 기본: `/?surface=public`
   - 에이전트: `/?surface=agent#/AGENTS.md`
   - 구현 위치: `index.html` (`surface` query로 sidebar manifest 선택)

## Notes
1. `Surface=HIDDEN`은 메뉴 비노출 정책이며 접근 제어가 아니다.
2. 민감 정보 비공개는 저장소/배포 분리로 해결한다.
3. 본 인벤토리는 baseline이며, `Target`/`Surface` 개별 메타 필드 부착은 후속 게이트(`TSK-2602-019`)에서 강제한다.
