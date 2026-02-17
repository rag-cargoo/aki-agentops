# Repository Rename Migration Note

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 09:07:32`
> - **Updated At**: `2026-02-17 18:07:35`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Purpose
> - Compatibility Policy
> - Rename Mapping
> - Link Handling Rules
> - Validation Checklist
<!-- DOC_TOC_END -->

## Purpose
- 저장소 표시명/슬러그 변경 이후에도 문서 탐색과 과거 증빙 링크를 안정적으로 유지하기 위한 기준을 기록한다.
- 범위: `AKI AgentOps` 루트 문서(`README.md`, `github-pages/sidebar-manifest.md`, `prj-docs/**`).

## Compatibility Policy
1. 과거 문서 원문은 삭제하지 않는다.
2. 과거 명칭(`2602`)은 역사적 맥락에서만 유지하고, 신규 문서 기본 표기는 `AKI AgentOps`로 통일한다.
3. URL/레포 식별자는 현재 소스 오브 트루스(`rag-cargoo/aki-agentops`)를 우선 사용한다.

## Rename Mapping
| Category | Legacy | Current | Note |
| --- | --- | --- | --- |
| Display Name | `2602` | `AKI AgentOps` | 문서 표기 정렬 대상 |
| Repository Slug | `rag-cargoo/2602` | `rag-cargoo/aki-agentops` | 2026-02-17 전환 완료 |
| Pages URL | `https://rag-cargoo.github.io/2602/` | `https://rag-cargoo.github.io/aki-agentops/` | Legacy URL은 404 가능 |

## Link Handling Rules
1. 신규 링크는 `aki-agentops` 경로만 사용한다.
2. 과거 회의록/이슈/PR 본문에 남은 `2602` 링크는 원문 보존한다.
3. 레거시 링크를 참조하는 문서에는 가능하면 인접 문장으로 현재 링크를 함께 병기한다.

## Validation Checklist
1. 루트 README에 Pages 홈 주소가 `https://rag-cargoo.github.io/aki-agentops/`로 표기되어 있는지 확인.
2. 이슈 템플릿/주요 가이드에 `rag-cargoo/aki-agentops` 기준 URL이 반영되어 있는지 확인.
3. 신규 문서 작성 시 구 슬러그(`/2602/`) 링크를 추가하지 않았는지 확인.
