# Meeting Notes: DDD Phase6-F Infrastructure-Global Decoupling Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 20:08:00`
> - **Updated At**: `2026-02-23 20:08:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase6-F)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase6-E까지 `api/application/domain -> global` 직접 의존을 제거했다.
  - 남은 경계 위반은 `infrastructure -> global` 직접 의존이었다.
    - `infrastructure.auth.. -> global.config..`
    - `infrastructure.messaging.. -> global.push..`
    - `infrastructure.push.. -> global.push.. / global.config..`

## 안건 2: 이번 범위(Phase6-F)
- Status: DONE
- 범위:
  - auth 경계 전환:
    - `SocialLoginConfigPort`를 OAuth 클라이언트 경계에 적용
    - `AuthJwtConfigPort`를 denylist 구성/구현 경계에 적용
  - messaging 경계 전환:
    - `KafkaReservationConsumer`를 `RealtimePushPort` 의존으로 전환
    - `KafkaPushEventConsumer`를 `WebSocketEventDispatchPort` 의존으로 전환
    - `KafkaPushEventProducer`를 `PushEventPublisherPort` 의존으로 전환
  - websocket subscription store 경계 전환:
    - `WebSocketQueueSubscriptionStorePort` 도입
    - `RedisWebSocketQueueSubscriptionStoreAdapter`/`WebSocketPushNotifier`를 포트 기준으로 정렬
    - 기존 global 중복 타입(`PushEvent`, `PushEventPublisher`, `WebSocketQueueSubscriptionStore`) 제거
  - ArchUnit 규칙 강화:
    - `infrastructure_should_not_depend_on_global_layer`
- 목표:
  - infrastructure 계층이 global 구현 타입을 직접 참조하지 않도록 경계를 포트 기반으로 고정
- 구현 결과:
  - `infrastructure -> global` 직접 import 잔여: `0`건 / `0`파일
  - 누적 경계 스냅샷:
    - `api -> global`: `0`
    - `application -> global`: `0`
    - `infrastructure -> global`: `0`
    - `global -> api`: `0`
    - `global -> infrastructure`: `0`

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - OAuth provider endpoint/파라미터 계약 변경
  - Kafka topic/schema 변경
  - WebSocket destination path 변경

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --tests com.ticketrush.architecture.LayerDependencyArchTest --tests com.ticketrush.infrastructure.messaging.KafkaPushEventConsumerTest --tests com.ticketrush.global.push.KafkaWebSocketPushNotifierTest --tests com.ticketrush.global.push.WebSocketPushNotifierTest --no-daemon`
- 결과:
  - compile/test 타깃 세트 PASS
  - ArchUnit 신규 규칙(`infrastructure -> global` 금지) 포함 PASS

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open, DDD 연속 트래킹)
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에 누적 관리
