# Meeting Notes: DDD Phase5-B Global Redis Port/Adapter Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 14:18:00`
> - **Updated At**: `2026-02-23 14:18:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase5-B)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase5-A에서 application 계층의 Redis 직접 의존을 포트/어댑터로 분리했다.
  - `global` 계층에는 Redis 직접 의존이 잔여(`WebSocketPushNotifier`, `WaitingQueueInterceptor`) 상태였다.
  - global 계층도 구현 상세 분리를 위해 port/adapter 경계 정렬이 필요하다.

## 안건 2: 이번 범위(Phase5-B)
- Status: DONE
- 범위:
  - `global.push.WebSocketPushNotifier`의 Redis 직접 의존 제거
  - `global.interceptor.WaitingQueueInterceptor`의 Redis 직접 의존 제거
  - global Redis 접근용 store interface 도입 + infrastructure adapter 구현
  - ArchUnit 규칙 보강:
    - `global..`의 `org.springframework.data.redis..` 직접 의존 금지
- 목표:
  - global 계층은 store interface만 의존하고 Redis 클라이언트 구현은 infrastructure adapter로 격리
- 구현 결과:
  - global store interface 추가:
    - `global.push.WebSocketQueueSubscriptionStore`
  - infrastructure adapter 추가:
    - `infrastructure.push.adapter.outbound.RedisWebSocketQueueSubscriptionStoreAdapter`
  - global 컴포넌트 의존 전환:
    - `WebSocketPushNotifier` -> `WebSocketQueueSubscriptionStore`
    - `WaitingQueueInterceptor` -> `application.waitingqueue.port.outbound.WaitingQueueStore`
  - 테스트 정렬:
    - `WebSocketPushNotifierTest` mock 대상을 `WebSocketQueueSubscriptionStore` 기준으로 전환
  - ArchUnit 보강:
    - `global_should_not_depend_on_spring_redis_directly` 규칙 추가

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - Redis 키 스키마/TTL 정책 변경
  - websocket topic/destination 계약 변경
  - API endpoint/응답 스키마 변경

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.global.push.WebSocketPushNotifierTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.application.waitingqueue.service.WaitingQueueServiceImplTest'`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest' --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest'`
- 결과:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - 첫 번째 테스트 세트 PASS
  - 두 번째 테스트 세트 PASS

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open)
- Sidecar:
  - `rag-cargoo/aki-agentops#155` (reopened)
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에서 누적 관리
