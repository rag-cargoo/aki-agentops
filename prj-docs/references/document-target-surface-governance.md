# Document Target/Surface Governance

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 09:37:07`
> - **Updated At**: `2026-02-17 17:43:45`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Purpose
> - Metadata Schema
> - Classification Rules
> - Surface Semantics
> - Default Mapping by Path
> - Repository vs Project Boundary
> - Current Baseline (2026-02-17)
> - Rollout Stages
> - Validation Gate
<!-- DOC_TOC_END -->

## Purpose
- 문서 대상(`Target`)과 노출면(`Surface`)을 명시해 사용자 중심 GitHub Pages 탐색과 에이전트 운영 문서를 분리한다.
- 문서 공개성(접근 가능 여부)과 메뉴 노출성(탐색 가시성)을 구분해 운영한다.

## Metadata Schema
문서 메타 블록에 아래 필드를 추가한다.

```md
<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `YYYY-MM-DD HH:MM:SS`
> - **Updated At**: `YYYY-MM-DD HH:MM:SS`
> - **Target**: `HUMAN | AGENT | BOTH | FUTURE:<group>`
> - **Surface**: `PUBLIC_NAV | AGENT_NAV | HIDDEN`
<!-- DOC_META_END -->
```

## Classification Rules
1. `Target`
   - `HUMAN`: 사용자/운영자 안내 중심 문서
   - `AGENT`: 자동화 절차/스킬 실행/런타임 내부 규칙 문서
   - `BOTH`: 사람/에이전트가 함께 참조하는 운영 기준
   - `FUTURE:<group>`: 향후 대상 그룹 확장 예약값
2. `Surface`
   - `PUBLIC_NAV`: 기본 사용자 사이드바 노출
   - `AGENT_NAV`: 에이전트 전용 사이드바 노출
   - `HIDDEN`: 어느 사이드바에도 자동 노출하지 않음

## Surface Semantics
1. `Surface`는 메뉴 노출 정책이다.
2. 저장소/Pages가 공개 상태면 `HIDDEN`이어도 URL 직접 접근이 가능할 수 있다.
3. 민감 정보 비공개는 `Surface`가 아니라 저장소/배포 분리로 해결한다.

## Default Mapping by Path
1. `AGENTS.md`, `skills/**`, `.codex/runtime/**`:
   - 권장 `Target=AGENT`
   - 권장 `Surface=AGENT_NAV` 또는 `HIDDEN`
2. `README.md`, `HOME.md`, `prj-docs/meeting-notes/**`:
   - 권장 `Target=HUMAN`
   - 권장 `Surface=PUBLIC_NAV`
3. `prj-docs/task.md`, `prj-docs/references/**`, `prj-docs/projects/**`:
   - 권장 `Target=BOTH`
   - 권장 `Surface=PUBLIC_NAV` (필요 시 일부 `AGENT_NAV`/`HIDDEN`)

## Repository vs Project Boundary
1. `workspace/**` 경로는 물리 배치(도메인) 기준이며, 경로만으로 `PROJECT`로 확정하지 않는다.
2. `PROJECT`는 아래 기준 중 하나를 충족해야 한다.
   - `prj-docs/projects/project-map.yaml`에 `project_id/code_root/docs_root/repo_remote`가 등록되고 `docs_root/task.md`가 존재한다.
   - 레거시 호환으로 `workspace/**/prj-docs/task.md`가 존재하고 세션 리로드 기준(`PROJECT_AGENT.md`, `meeting-notes/README.md`)을 충족한다.
3. Public 메뉴의 `REPOSITORY (AKI AgentOps)`는 루트 운영 문서(거버넌스/회의록/태스크) 전용 영역이다.
4. Public 메뉴의 `PROJECTS`는 등록된 프로젝트 sidecar 문서 묶음이며, 외부 제품 레포 링크는 보조 링크(`Repository (GitHub)`)로 표기한다.

## Current Baseline (2026-02-17)
1. 인벤토리:
   - `prj-docs/references/document-target-surface-inventory-2026-02-17.md`
2. 메뉴 분리:
   - Public: `sidebar-manifest.md`
   - Agent: `sidebar-agent-manifest.md`
3. 런타임 전환:
   - 기본 `/?surface=public`
   - 에이전트 `/?surface=agent#/AGENTS.md`
4. 구현 위치:
   - `index.html`에서 `surface` query 값으로 sidebar manifest 선택

## Rollout Stages
1. Stage 1: 정책/스키마 확정 + task/issue 등록
2. Stage 2: 전 문서 인벤토리 분류 리포트 작성
3. Stage 3: `PUBLIC_NAV` 중심 메뉴 재구성 + `AGENT_NAV` 분리
4. Stage 4: pre-commit lint 게이트 도입

## Validation Gate
1. 신규/수정 문서는 `Target`/`Surface` 누락 없이 기록한다.
2. 허용값 외 enum 사용 시 pre-commit에서 차단한다.
3. `AGENT` 문서가 `PUBLIC_NAV`에 들어갈 경우 의도 검토 코멘트를 남긴다.
4. 자동 검증 스크립트:
   - `bash skills/aki-codex-precommit/scripts/check-target-surface-governance.sh --scope staged`
5. 실패 시 복구:
   - 문서 메타에 `Target`/`Surface`를 보완한 뒤 재검증한다.
   - public 사이드바에 `AGENT` 문서 직접 링크가 있으면 `sidebar-agent-manifest.md`로 이동한다.
