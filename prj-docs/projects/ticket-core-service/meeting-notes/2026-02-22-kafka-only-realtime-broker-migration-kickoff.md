# Meeting Notes: Kafka-Only Realtime Broker Migration Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-22 23:19:47`
> - **Updated At**: `2026-02-22 23:25:48`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: Kafka-only 원칙 확정
> - 안건 2: 이슈 라이프사이클 적용
> - 안건 3: task 동기화
> - 안건 4: 구현 착수 게이트
<!-- DOC_TOC_END -->

## 안건 1: Kafka-only 원칙 확정
- Status: DONE
- 결정사항:
  - 런타임 브로커 의존성은 Kafka 단일 기준으로 정렬한다.
  - `ws-relay`(RabbitMQ STOMP relay) 기반 구성은 제거 대상으로 본다.
  - 기존 분산 기본값/compose 기준은 유지하되, WebSocket 전달 경로를 Kafka-only 아키텍처로 재설계한다.

## 안건 2: 이슈 라이프사이클 적용
- Status: DONE
- 처리결과:
  - 같은 Push/Realtime 아키텍처 범위 후속으로 `ticket-core-service Issue #3`을 재오픈했다.
  - sidecar 문서 동기화는 기존 sidecar 이슈 `#136`을 재오픈해 연계 추적한다.
  - phase-1 baseline 정리 구현은 `rag-cargoo/ticket-core-service PR #29`로 머지됐다.
- 링크:
  - Product tracking: `ticket-core-service Issue #3` (reopened)
  - Product progress comment: `ticket-core-service Issue #3 comment 3941035224`
  - Product PR: `rag-cargoo/ticket-core-service PR #29` (merged)
  - Sidecar tracking: `https://github.com/rag-cargoo/aki-agentops/issues/136` (reopened)
  - Sidecar progress comment: `https://github.com/rag-cargoo/aki-agentops/issues/136#issuecomment-3941036228`
  - Sidecar progress comment(phase-1 merge): `https://github.com/rag-cargoo/aki-agentops/issues/136#issuecomment-3941045490`

## 안건 3: task 동기화
- Status: DONE
- 처리결과:
  - sidecar task에 `TCS-SC-024` 항목을 `DOING`으로 추가해 Kafka-only 전환 작업을 실행 트랙으로 고정한다.
  - meeting notes index + sidebar manifest에 신규 노트 링크를 반영한다.

## 안건 4: 구현 착수 게이트
- Status: DOING
- 실행계획:
  - 완료(phase-1):
    - `docker-compose.yml`에서 `ws-relay` 및 relay env 기본 주입을 제거했다.
    - `application.yml`/`WebSocketBrokerProperties` 기본값을 `simple`로 재정렬했다.
    - `README.md` 운영 가이드를 `simple` 기본 기준으로 정렬했다.
    - 최소 회귀를 완료했다(`compose config`, `WebSocketConfigTest`).
  - 잔여(phase-2):
    - 다중 인스턴스 WS fanout을 Kafka-only로 재설계/구현한다.
  - 진행 로그:
    - `ticket-core-service Issue #3 comment 3941042057`
