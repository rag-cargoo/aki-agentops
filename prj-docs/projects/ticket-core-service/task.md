# Task Dashboard (ticket-core-service sidecar)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 05:11:38`
> - **Updated At**: `2026-02-19 01:31:31`
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
    - Product PR: `rag-cargoo/ticket-core-service PR #4` (merged, cross-repo shorthand)
    - Merge Commit: `72f57d7a0dfedf08305d4d6ed73af41d97800359`
    - Included:
      - `PushNotifier` + `SsePushNotifier` + `WebSocketPushNotifier`
      - `app.push.mode` (`APP_PUSH_MODE=sse|websocket`)
      - WebSocket endpoint `/ws` + subscription APIs
      - `./gradlew clean test` pass

- TCS-SC-006 결제/환불/보유머니 원장 구현 및 예약 연동
  - Status: DONE
  - Description:
    - 지갑 잔액(wallet) + 결제 원장(ledger) 최소 구현 도입
    - 예약 `confirm/refund` 흐름에 결제 차감/환불 복구 연동
    - 지갑 충전/조회/거래내역 API 및 테스트 스크립트 추가
  - Evidence:
    - 회의록: `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-18-wallet-payment-ledger-implementation-completion.md`
    - Product Issue: `rag-cargoo/ticket-core-service#5` (closed)
    - Product PR: `rag-cargoo/ticket-core-service PR #6` (merged, cross-repo shorthand)
    - Merge Commit: `34033788d38c51ed43205856d9d6f752335e1cbb`
    - Verification: `./gradlew test` pass

- TCS-SC-007 OAuth/JWT 만료/재발급/로그아웃 무효화 고도화
  - Status: DONE
  - Description:
    - Access/Refresh 만료/재발급 계약을 API/문서 기준으로 명확화
    - 로그아웃 이후 토큰 무효화 경계와 예외 응답 규약 보강
  - Evidence:
    - 회의록: `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-19-auth-session-hardening-completion.md`
    - Product Issue: `rag-cargoo/ticket-core-service#7` (closed)
    - Product PR: `rag-cargoo/ticket-core-service PR #8` (merged, cross-repo shorthand)
    - Merge Commit: `f3cd910632bddf266bda904a382b977d20538b05`
    - Verification: `./gradlew test` pass

- TCS-SC-008 프론트 출시 계약(에러코드/시간대/권한 경계) 보강
  - Status: DONE
  - Description:
    - 예약/결제/대기열 API의 오류 응답 표준 및 시간대 규칙(UTC/KST) 정리
    - 공개/인증/관리자 권한 경계 계약을 문서/테스트 케이스로 고정
  - Evidence:
    - 공통 계약 문서 추가:
      - `prj-docs/projects/ticket-core-service/product-docs/api-specs/api-contract-conventions.md`
    - 도메인 명세 보강:
      - `wallet-payment-api.md` 신규 추가
      - `realtime-push-api.md` 신규 추가
      - `reservation-api.md` v4 경로/결제 side effect/v7 인증 경계 보강
      - `waiting-queue-api.md` WS 구독 등록/해제 계약 보강
      - `user-api.md` `walletBalanceAmount` 필드 반영
    - 테스트 가이드 보강:
      - `prj-docs/projects/ticket-core-service/product-docs/api-test/README.md`
      - `run-api-script-tests` 기본 세트(`v1~v14 + a*`) 및 `v13/v14` 검증 절차 반영
