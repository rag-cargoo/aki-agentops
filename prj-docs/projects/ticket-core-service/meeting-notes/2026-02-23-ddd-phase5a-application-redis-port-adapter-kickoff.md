# Meeting Notes: DDD Phase5-A Application Redis Port/Adapter Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 13:58:00`
> - **Updated At**: `2026-02-23 14:04:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase5-A)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase4-J에서 auth infra/security 구현체를 domain 밖으로 이동했다.
  - 현재 application 계층 일부 서비스가 `StringRedisTemplate`에 직접 의존한다.
  - clean architecture 관점에서 application은 Redis 클라이언트 구현 상세를 직접 참조하지 않도록 정렬이 필요하다.

## 안건 2: 이번 범위(Phase5-A)
- Status: DONE
- 범위:
  - application 서비스의 Redis 직접 의존 제거:
    - `application.waitingqueue.service.WaitingQueueServiceImpl`
    - `application.reservation.service.ReservationQueueServiceImpl`
    - `application.reservation.service.SeatSoftLockServiceImpl`
  - application outbound port 추가 + infrastructure adapter 구현으로 치환
  - 관련 테스트 mock 대상을 RedisTemplate -> port 기준으로 전환
  - ArchUnit 규칙 보강:
    - `application..`의 `org.springframework.data.redis..` 직접 의존 금지
- 목표:
  - application 서비스는 port(interface)만 의존하고 Redis 연동은 infrastructure adapter가 담당
- 구현 결과:
  - application outbound port 추가:
    - `application.waitingqueue.port.outbound.WaitingQueueStore`
    - `application.reservation.port.outbound.ReservationQueueStatusStore`
    - `application.reservation.port.outbound.SeatSoftLockStore`
  - infrastructure adapter 구현:
    - `infrastructure.waitingqueue.adapter.outbound.RedisWaitingQueueStoreAdapter`
    - `infrastructure.reservation.adapter.outbound.RedisReservationQueueStatusStoreAdapter`
    - `infrastructure.reservation.adapter.outbound.RedisSeatSoftLockStoreAdapter`
  - 서비스 의존 전환:
    - `WaitingQueueServiceImpl` -> `WaitingQueueStore`
    - `ReservationQueueServiceImpl` -> `ReservationQueueStatusStore`
    - `SeatSoftLockServiceImpl` -> `SeatSoftLockStore`
  - 테스트 정렬:
    - `WaitingQueueServiceImplTest`, `SeatSoftLockServiceImplTest` mock 대상을 port로 전환
  - ArchUnit 보강:
    - `application_should_not_depend_on_spring_redis_directly` 규칙 추가

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - `global.push.WebSocketPushNotifier`의 Redis 의존 제거
  - `global.interceptor.WaitingQueueInterceptor`의 Redis 의존 제거
  - Redis 키 스키마/TTL 정책 변경
  - API endpoint/응답 스키마 변경

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.application.waitingqueue.service.WaitingQueueServiceImplTest' --tests 'com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest'`
- 결과:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.application.waitingqueue.service.WaitingQueueServiceImplTest' --tests 'com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest'` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest'` PASS

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open)
- Sidecar:
  - `rag-cargoo/aki-agentops#155` (reopened)
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에서 누적 관리
