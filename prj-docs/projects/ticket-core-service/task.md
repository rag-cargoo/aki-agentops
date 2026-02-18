# Task Dashboard (ticket-core-service sidecar)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 05:11:38`
> - **Updated At**: `2026-02-18 23:06:26`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Current Items
<!-- DOC_TOC_END -->

## Scope
- 이 문서는 `ticket-core-service` 운영 sidecar 태스크를 관리한다.
- 구현 상세 태스크는 제품 레포 이슈/PR에서 관리한다.

## Current Items
- TCS-SC-001 외부 레포 분리 전환 운영 확인
  - Status: DONE
  - Description: code_root, docs_root, repo_remote가 `project-map.yaml`과 일치하는지 점검
  - Evidence:
    - `project-map.yaml`에 `workspace/apps/backend/ticket-core-service` + `prj-docs/projects/ticket-core-service` + `https://github.com/rag-cargoo/ticket-core-service`
    - `session_start.sh` 출력에서 Active Project `Docs Root: prj-docs/projects/ticket-core-service` 확인
    - PR `#65` merged (`2026-02-16`) 및 연계 이슈 `#66` closed

- TCS-SC-002 sidecar 분리 이후 제품 레포 문서 SoT 중복 정리
  - Status: DONE
  - Description:
    - 제품 레포(`ticket-core-service`)의 `prj-docs`를 제거하고 sidecar 문서 SoT 단일화 전환 완료
    - 제품 README/스크립트 기본 경로를 sidecar 운영 모델에 맞게 정렬
  - Evidence:
    - 회의록: `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-17-sidecar-sot-dedup-followup.md`
    - AKI AgentOps 이슈 재오픈: `https://github.com/rag-cargoo/aki-agentops/issues/66`
    - 제품 레포 이슈: `rag-cargoo/ticket-core-service#1` (cross-repo shorthand)
    - 제품 레포 PR: `rag-cargoo/ticket-core-service PR #2` (merged, cross-repo shorthand)
    - 제품 레포 머지 커밋: `f0f798b0dfee0428b1d807acd0f4c25206f3e94a`
    - 제품 레포 이슈 상태: `#1 CLOSED`
    - 동기화 코멘트(AgentOps): `https://github.com/rag-cargoo/aki-agentops/issues/66#issuecomment-3914421398`
    - 동기화 코멘트(AgentOps 최신): `https://github.com/rag-cargoo/aki-agentops/issues/66#issuecomment-3914681986`
    - 동기화 코멘트(ticket-core-service): `rag-cargoo/ticket-core-service#1 comment 3914422354`
    - 동기화 코멘트(ticket-core-service 최신): `rag-cargoo/ticket-core-service#1 comment 3914680685`
    - 비고: `doc-state-sync`가 동일 저장소 기준으로 URL 이슈 번호를 해석하므로, cross-repo 이슈는 shorthand 표기로 유지

- TCS-SC-003 Pages 문서 라벨/Source 안내 정합화
  - Status: DONE
  - Description:
    - `product-docs`가 더 이상 mirror가 아님에 따라 제목/정책/링크 라벨을 `Pages Docs` 기준으로 정렬
    - 삭제된 upstream(`ticket-core-service/prj-docs/**`) 참조를 sidecar SoT 기준으로 교체
  - Evidence:
    - sidecar docs 갱신 PR: `https://github.com/rag-cargoo/aki-agentops/pull/92` (merged)
    - `github-pages/sidebar-manifest.md`의 Ticket Core Service 라벨을 `(Pages Docs)`로 정렬
    - `prj-docs/projects/ticket-core-service/product-docs/**` 상단 정책을 `Publication Policy`로 정렬

- TCS-SC-004 실시간 전송(SSE/WS) 전환 안건 정리 및 트래킹 동기화
  - Status: DONE
  - Description:
    - SSE 유지 + WebSocket 병행 + 설정 스위칭 전략을 회의록/이슈/태스크 기준으로 정렬
    - 구현 착수 전 관리 순서(회의록 -> task -> 제품 이슈)를 확정
  - Evidence:
    - 회의록: `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-18-realtime-transport-sse-ws-switching-plan.md`
    - 제품 레포 이슈: `rag-cargoo/ticket-core-service#3` (cross-repo shorthand)

- TCS-SC-005 실시간 전송 채널 추상화 및 WebSocket 병행 구현
  - Status: DONE
  - Description:
    - `ticket-core-service` 제품 레포에서 notifier 인터페이스 + SSE/WS 구현체 분리
    - 설정값 기반 모드 스위칭(`sse`, `websocket`)과 채널별 컨트롤러 분리 적용
    - 기존 SSE 경로 하위호환 유지 + 채널별 테스트/문서 정합화
  - Evidence:
    - Tracking Issue: `rag-cargoo/ticket-core-service#3` (closed)
    - Product PR: `https://github.com/rag-cargoo/ticket-core-service/pull/4` (merged)
    - Merge Commit: `72f57d7a0dfedf08305d4d6ed73af41d97800359`
    - Included:
      - `PushNotifier` + `SsePushNotifier` + `WebSocketPushNotifier`
      - `app.push.mode` (`APP_PUSH_MODE=sse|websocket`)
      - WebSocket endpoint `/ws` + subscription APIs
      - `./gradlew clean test` pass
