# Meeting Notes: DDD Phase6-C Global Boundary Decoupling Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 19:32:59`
> - **Updated At**: `2026-02-23 19:32:59`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase6-C)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase6-B에서 `api/global -> infrastructure.messaging` 직접 의존을 제거했다.
  - 후속 스캔에서 `global` 계층의 잔여 경계 결합이 확인됐다.
    - `global.lock.RedissonLockFacade`의 `api.dto` 직접 의존
    - `global.scheduler.WaitingQueueScheduler`의 `api.dto` 직접 의존
    - `global.config.SecurityConfig`의 `infrastructure` 직접 타입 의존

## 안건 2: 이번 범위(Phase6-C)
- Status: DONE
- 범위:
  - distributed lock 경계 정리:
    - `RedissonLockFacade` 시그니처를 API DTO 기반에서 application command/result 기반으로 전환
    - `ReservationController`에서 API DTO <-> application 매핑 책임화
    - 분산락 동시성 테스트 호출 시그니처 정렬
  - waiting queue scheduler payload 경계 정리:
    - `WaitingQueueScheduler`의 `WaitingQueueSsePayload(api dto)` 의존 제거
    - scheduler 내부 payload를 `Map<String, Object>` 기반으로 전환
  - security config 경계 정리:
    - `SecurityConfig`의 `JwtAuthenticationFilter(infrastructure)` 직접 타입 의존 제거
    - `@Qualifier(\"jwtAuthenticationFilter\") OncePerRequestFilter` 경유로 의존 정렬
  - ArchUnit 규칙 강화:
    - `global_should_not_depend_on_api_layer`
    - `global_should_not_depend_on_infrastructure_layer`
- 목표:
  - `global` 계층의 API/Infrastructure 직접 타입 참조를 제거하고, 경계 회귀를 ArchUnit으로 차단
- 구현 결과:
  - 변경 파일:
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/global/lock/RedissonLockFacade.java`
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/global/scheduler/WaitingQueueScheduler.java`
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/global/config/SecurityConfig.java`
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/api/controller/ReservationController.java`
    - `workspace/apps/backend/ticket-core-service/src/test/java/com/ticketrush/application/reservation/service/동시성_테스트_3_분산_락.java`
    - `workspace/apps/backend/ticket-core-service/src/test/java/com/ticketrush/architecture/LayerDependencyArchTest.java`

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - 인증/인가 정책 규칙(permit/authenticated/role) 변경
  - SSE/WebSocket 이벤트 계약 필드 변경
  - Redis/Kafka 운영 구성값 변경

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.api.controller.AuthSecurityIntegrationTest'`
- 결과:
  - compile/test 타깃 세트 PASS
  - `global` 계층의 `import com.ticketrush.api..` / `import com.ticketrush.infrastructure..` 잔여 `0`건 확인

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open, DDD 연속 트래킹)
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에 누적 관리
