# Meeting Notes: Sidecar SoT Dedup Follow-up (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 21:07:43`
> - **Updated At**: `2026-02-17 22:38:23`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Mandatory Runtime Gate
> - External Sync
> - 안건 1: 현황 확인(분리 완료 vs 중복 잔존)
> - 안건 2: 추적 축 정리(이슈/태스크)
> - 안건 3: 마무리 작업 범위
> - 안건 4: Doc State Sync 오탐 보정
> - 안건 5: 제품 레포 정리 PR 완료
<!-- DOC_TOC_END -->

## Mandatory Runtime Gate
- Checked At: 2026-02-17 21:13:30
- `session_start.sh`: PASS
- `mcp_toolset(context/repos/issues/projects/pull_requests/labels)`: PASS
- `validate-precommit-chain.sh`: PASS
- Evidence:
  - command:
    - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
    - `mcp__github__list_available_toolsets`
    - `bash skills/aki-codex-precommit/scripts/validate-precommit-chain.sh --mode quick --all`
  - result:
    - Active Project `workspace/apps/backend/ticket-core-service (OK)`
    - GitHub MCP 기본 6개 toolset `currently_enabled=true` 확인
    - precommit quick chain 통과

## External Sync
- Source of Truth:
  - `https://github.com/rag-cargoo/aki-agentops/issues/66`
  - `https://github.com/rag-cargoo/ticket-core-service/issues/1`
- Sync Action: issue-comment + task-update + doc-state-sync-guard
- Sync Evidence:
  - `https://github.com/rag-cargoo/aki-agentops/issues/66#issuecomment-3914421398`
  - `https://github.com/rag-cargoo/ticket-core-service/issues/1#issuecomment-3914422354`
  - `https://github.com/rag-cargoo/aki-agentops/issues/66#issuecomment-3914681986`
  - `https://github.com/rag-cargoo/ticket-core-service/issues/1#issuecomment-3914680685`
- Last Synced At: 2026-02-17 22:22:30

## 안건 1: 현황 확인(분리 완료 vs 중복 잔존)
- Created At: 2026-02-17 21:07:43
- Updated At: 2026-02-17 21:07:43
- Status: DONE
- 결정사항:
  - sidecar 분리(`AKI AgentOps`)와 docs_root 매핑 전환은 완료 상태다.
  - 다만 제품 레포(`ticket-core-service`) 내부 `prj-docs`가 남아 있어 운영 문서 SoT가 중복된 상태다.
  - 이번 후속 작업은 “분리 자체”가 아니라 “중복 SoT 정리”에 초점을 둔다.

## 안건 2: 추적 축 정리(이슈/태스크)
- Created At: 2026-02-17 21:07:43
- Updated At: 2026-02-17 21:07:43
- Status: DONE
- 결정사항:
  - `AKI AgentOps`에서는 기존 후속 이슈 `#66`을 재오픈해 거버넌스 추적을 연장한다.
  - 제품 레포에는 실행 이슈 `#1`을 생성해 실제 정리 작업(정책 확정/경로 정합/PR)을 관리한다.
  - sidecar task에 `TCS-SC-002`를 추가해 상태를 `DOING`으로 관리한다.

## 안건 3: 마무리 작업 범위
- Created At: 2026-02-17 21:07:43
- Updated At: 2026-02-17 22:22:30
- Status: DONE
- 결정사항:
  - 제품 레포 문서 유지 정책을 확정한다(전부 제거 vs 최소 유지).
  - 정책 확정 후 `ticket-core-service` PR에서 문서/링크/스크립트 참조를 일괄 정리한다.
  - sidecar 문서(`task`, `meeting-notes`)와 제품 레포 이슈/PR 링크를 양방향으로 동기화한다.

## 안건 4: Doc State Sync 오탐 보정
- Created At: 2026-02-17 21:13:30
- Updated At: 2026-02-17 21:25:58
- Status: DONE
- 결정사항:
  - `doc-state-sync`는 문서 내 `https://github.com/.../issues/<number>`를 현재 저장소 이슈 번호로 해석한다.
  - sidecar `task.md`의 cross-repo 이슈 표기는 URL 대신 `owner/repo#number` shorthand를 기본으로 사용한다.
  - 이번 작업에서 `TCS-SC-002` 증빙 항목을 shorthand로 정렬했다.
  - 추가 보정: cross-repo 이슈 comment URL(`.../issues/1#issuecomment...`)도 issue URL로 해석되므로 `task.md`에서는 URL 대신 텍스트 표기를 사용한다.

## 안건 5: 제품 레포 정리 PR 완료
- Created At: 2026-02-17 22:22:30
- Updated At: 2026-02-17 22:38:23
- Status: DONE
- 결정사항:
  - 제품 레포 PR `#2`를 통해 `prj-docs` 제거 및 sidecar SoT 단일화를 완료했다.
  - `ticket-core-service#1`은 `CLOSED` 상태로 종료됐다.
  - 검증 결과는 `scripts/check-doc-remote-sync.sh --scope all` pass(skip), `./gradlew compileJava` pass, `./gradlew test`는 Redis 미기동으로 fail(환경 이슈)로 기록한다.
