# Meeting Notes: DDD Phase6-E API-Global Port Decoupling Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 19:51:05`
> - **Updated At**: `2026-02-23 19:51:05`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase6-E)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase6-D에서 `application -> global` 직접 의존을 제거했다.
  - API 컨트롤러에는 `global` 직접 의존이 일부 남아 있었다.
    - `ReservationController -> RedissonLockFacade`, `SsePushNotifier`
    - `WaitingQueueController -> SsePushNotifier`
    - `WebSocketPushController -> WebSocketPushNotifier`

## 안건 2: 이번 범위(Phase6-E)
- Status: DONE
- 범위:
  - API 포트 인터페이스 도입:
    - `DistributedReservationUseCase` (distributed lock 예약 유스케이스)
    - `SsePushPort` (SSE subscribe/send 포트)
    - `WebSocketSubscriptionPort` (WebSocket subscribe/unsubscribe 포트)
  - global 구현체 정렬:
    - `RedissonLockFacade` -> `DistributedReservationUseCase` 구현
    - `SsePushNotifier` -> `SsePushPort` 구현
    - `WebSocketPushNotifier` -> `WebSocketSubscriptionPort` 구현
  - 컨트롤러 의존 전환:
    - `ReservationController`
    - `WaitingQueueController`
    - `WebSocketPushController`
  - 테스트 정렬:
    - `WebSocketPushControllerTest` 목 타입을 포트 기준으로 정렬
  - ArchUnit 규칙 강화:
    - `api_layer_should_not_depend_on_global_layer`
- 목표:
  - API 계층의 global 구현체 직접 참조 제거 및 컨트롤러 경계를 포트 기준으로 정렬
- 구현 결과:
  - `api -> global` 직접 import 잔여: `0`건 / `0`파일
  - 경계 스냅샷(누적):
    - `application -> global`: `0`
    - `domain -> global`: `0`
    - `global -> api`: `0`
    - `global -> infrastructure`: `0`
    - `api/global -> infrastructure.messaging`: `0`

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - API endpoint/요청응답 스키마 변경
  - SSE/WebSocket topic path 변경
  - Redisson/Kafka/SSE 런타임 설정 변경

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.api.controller.WebSocketPushControllerTest' --tests 'com.ticketrush.global.sse.SsePushNotifierTest' --tests 'com.ticketrush.global.push.WebSocketPushNotifierTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.application.waitingqueue.service.WaitingQueueServiceImplTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.api.controller.AuthSecurityIntegrationTest'`
- 결과:
  - compile/test 타깃 세트 PASS
  - ArchUnit에 `api -> global` 금지 규칙 반영 후 PASS

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open, DDD 연속 트래킹)
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에 누적 관리
