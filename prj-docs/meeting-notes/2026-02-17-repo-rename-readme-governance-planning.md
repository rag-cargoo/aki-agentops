# Meeting Notes: 2602 Repo Rename and README Governance Planning

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 06:51:30`
> - **Updated At**: `2026-02-17 07:03:18`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Mandatory Runtime Gate
> - External Sync
> - 안건 1: 프로젝트/레포 이름 변경 필요성 판단
> - 안건 2: README 정보구조 재정의(자체 프로젝트 소개/사용방법)
> - 안건 3: 기존 문서 처리 원칙(보존/이관/폐기)
> - 안건 4: 실행 순서와 리스크
<!-- DOC_TOC_END -->

## Mandatory Runtime Gate
- Checked At: 2026-02-17 06:50:53
- `session_start.sh`: PASS
- `mcp_toolset(context/repos/issues/projects/pull_requests/labels)`: PASS
- `validate-precommit-chain.sh`: PASS
- Evidence:
  - command:
    - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
    - `bash skills/aki-codex-precommit/scripts/validate-precommit-chain.sh --mode quick --all`
    - `mcp__github__list_available_toolsets`
  - result:
    - Active Project `workspace/apps/backend/ticket-core-service (OK)`
    - precommit quick chain 통과
    - GitHub MCP 기본 6개 toolset enabled 확인

## External Sync
- Source of Truth: `rag-cargoo/2602` issue `#70`
- Sync Action: issue-comment + task-update
- Last Synced At: 2026-02-17 07:03:18

## 안건 1: 프로젝트/레포 이름 변경 필요성 판단
- Created At: 2026-02-17 06:51:30
- Updated At: 2026-02-17 07:03:18
- Status: DONE
- 결정사항:
  - `2602` 숫자 기반 명칭은 의미 전달력이 낮아 운영/온보딩에 불리하다.
  - 표시명(Display Name)과 실제 레포 슬러그(rename)는 분리해서 단계적으로 진행한다.
  - 프로젝트 표시명은 `AKI AgentOps`로 확정한다. (한글 표기는 `아키에이전트옵스` 사용 가능)
  - 레포 slug는 당분간 `2602`를 유지하고, 필요 시 2차로 rename을 별도 안건으로 처리한다.
- 후속작업:
  - 담당: User + Codex
  - 기한: 2026-02-20
  - 상태: DONE
  - 메모: 실행 태스크는 `TSK-2602-013`, `TSK-2602-014`로 분리 관리한다.

## 안건 2: README 정보구조 재정의(자체 프로젝트 소개/사용방법)
- Created At: 2026-02-17 06:51:30
- Updated At: 2026-02-17 06:51:30
- Status: TODO
- 결정사항:
  - 루트 `README.md`에 `이 프로젝트가 무엇인지`, `누가 언제 쓰는지`, `빠른 시작(Quick Start)`를 명시한다.
  - 최소 포함 섹션:
    - Project Overview
    - Primary Use Cases
    - Quick Start (세션 시작/Active Project 설정/검증 명령)
    - Repository Boundaries (`2602` vs 외부 제품 레포)
  - 기존 링크 중심 README는 유지하되, 구조를 상단에서 목적 중심으로 재배치한다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-02-18
  - 상태: TODO
  - 메모: 기존 링크/목차는 하위 섹션으로 내리고, 상단 1화면에 소개+사용법을 배치한다.

## 안건 3: 기존 문서 처리 원칙(보존/이관/폐기)
- Created At: 2026-02-17 06:51:30
- Updated At: 2026-02-17 06:51:30
- Status: TODO
- 결정사항:
  - 기존 문서는 원칙적으로 삭제하지 않고 보존한다.
  - 이름 변경 시 처리 원칙:
    - 과거 회의록/증빙 링크는 원문 유지
    - 새 표기명 도입 시 호환 주석(구 명칭 -> 신 명칭) 추가
    - 장기적으로는 Legacy Index를 두어 이전 명칭 문서를 모아 탐색 가능하게 한다
  - 즉, “기존 문서 폐기”가 아니라 “표기 정렬 + 탐색 경로 보강” 전략을 채택한다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-02-18
  - 상태: TODO
  - 메모: `prj-docs/references/`에 migration note를 추가하고 README에서 링크한다.

## 안건 4: 실행 순서와 리스크
- Created At: 2026-02-17 06:51:30
- Updated At: 2026-02-17 06:51:30
- Status: TODO
- 결정사항:
  - 권장 순서:
    1) 표시명/README 구조 개편
    2) 링크/문서/스크립트 하드코딩 치환
    3) 필요 시 레포 slug rename + Pages URL 검증
  - 주요 리스크:
    - Pages 경로(`/2602/`) 변경 시 링크 대량 수정 필요
    - 이슈/PR/회의록의 과거 URL 무결성 관리 필요
    - 스크립트 내부 하드코딩 누락 시 회귀 발생 가능
- 후속작업:
  - 담당: User + Codex
  - 기한: 2026-02-19
  - 상태: TODO
  - 메모: rename 여부 확정 전에는 기능 변경 없이 문서/정책만 준비한다.
