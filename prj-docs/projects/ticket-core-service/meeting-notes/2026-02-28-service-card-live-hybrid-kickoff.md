# Meeting Notes: Service Card Live Hybrid Backend Hardening (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-28 05:07:37`
> - **Updated At**: `2026-02-28 05:14:39`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 목표와 운영 원칙
> - 안건 2: 백엔드 선행 구현 범위
> - 안건 3: DDD/Hexagonal 경계 규칙
> - 안건 4: 완료 기준/검증 계획
> - 안건 5: 연계 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 목표와 운영 원칙
- Status: DONE
- 결정:
  - Service 카드 데이터는 실시간 사용자 경험을 위해 WebSocket push를 기본 채널로 사용한다.
  - 안전성은 `초기 HTTP 스냅샷 + WS 실시간 + 장애 시 fallback polling` 전략으로 보완한다.
  - 모드 전환은 런타임 핫스위치가 아닌 롤아웃 배포 단위로 관리한다.

## 안건 2: 백엔드 선행 구현 범위
- Status: DONE
- 결정:
  - 카드 refresh 토픽(`/topic/concerts/live`) 전파를 분산 fanout 경로(Kafka push)로 통일한다.
  - cache evict 시점에 발생하는 카드 refresh 이벤트를 push event 계약 타입으로 정식화한다.
  - 좌석 상태 변경뿐 아니라 판매정책/공연 메타 변경에서도 카드 refresh 누락이 없도록 보강한다.
- 구현 결과:
  - `CONCERTS_REFRESH` 이벤트 타입을 `PushEvent`/`KafkaPushEvent` 계약에 추가했다.
  - `ConcertRefreshPushPort` + `PushNotifierConfig` selector를 추가해 모드별 notifier 선택을 유지했다.
  - `KafkaPushEventConsumer -> WebSocketPushNotifier` 경로에 `/topic/concerts/live` dispatch를 연결했다.
  - `ConcertReadCacheEvictor`를 cache clear + refresh push 발행(예외 안전 처리) 구조로 확장했다.
  - `SalesPolicyServiceImpl`, `ConcertServiceImpl` 쓰기 경로에서 카드 refresh 트리거를 연계했다.

## 안건 3: DDD/Hexagonal 경계 규칙
- Status: DONE
- 결정:
  - 도메인/애플리케이션은 transport(WebSocket/STOMP/HTTP polling)를 직접 알지 않는다.
  - 이벤트 발행은 outbound port를 통해 수행하고, Kafka/WebSocket 구체화는 infrastructure adapter에서만 처리한다.
  - 기존 queue/reservation/seat-map push 경로 회귀를 허용하지 않는다.

## 안건 4: 완료 기준/검증 계획
- Status: DONE (백엔드 범위)
- 완료 기준:
  - 분산 인스턴스 환경에서 Service 카드 refresh 이벤트 fanout이 누락 없이 동작한다.
  - 좌석/판매정책/공연 메타 변경 후 카드 재조회 트리거가 누락되지 않는다.
  - 타깃 테스트 및 컴파일 검증이 통과한다.
- 검증 결과:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.infrastructure.messaging.KafkaPushEventConsumerTest' --tests 'com.ticketrush.global.push.KafkaWebSocketPushNotifierTest'`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.global.push.WebSocketPushNotifierTest' --tests 'com.ticketrush.global.config.PushNotifierConfigTest' --tests 'com.ticketrush.global.cache.ConcertReadCacheEvictorTest'`

## 안건 5: 연계 트래킹
- Status: DONE
- 트래킹:
  - backend issue: `https://github.com/rag-cargoo/ticket-core-service/issues/55`
  - task: `prj-docs/projects/ticket-core-service/task.md` (`TCS-SC-032`)
  - implementation branch: `feat/issue-55-service-card-live-hybrid-backend`
