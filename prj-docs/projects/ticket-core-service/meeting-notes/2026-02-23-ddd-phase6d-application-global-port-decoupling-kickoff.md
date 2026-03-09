# Meeting Notes: DDD Phase6-D Application-Global Port Decoupling Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 19:45:25`
> - **Updated At**: `2026-02-23 19:45:25`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase6-D)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase6-C까지 `global -> api/infrastructure`, `api/global -> infrastructure.messaging` 직접 의존은 제거됐다.
  - 그러나 `application` 계층에 `global` 직접 타입 의존이 남아 있었다.
    - `global.config.*Properties`
    - `global.cache.ConcertReadCacheEvictor`
    - `global.push.PushNotifier`
    - `global.cache.ConcertCacheNames`

## 안건 2: 이번 범위(Phase6-D)
- Status: DONE
- 범위:
  - application 포트 인터페이스 도입:
    - `RealtimePushPort`
    - `ConcertReadCacheEvictPort`
    - `AuthJwtConfigPort`
    - `ReservationConfigPort`
    - `PaymentConfigPort`
    - `AbuseGuardConfigPort`
    - `WaitingQueueConfigPort`
  - global 구현체/설정 클래스 정렬:
    - `PushNotifier`가 `RealtimePushPort`를 상속하도록 조정
    - `ConcertReadCacheEvictor`가 `ConcertReadCacheEvictPort` 구현
    - `AuthJwtProperties`, `ReservationProperties`, `PaymentProperties`, `AbuseGuardProperties`, `WaitingQueueProperties`
      가 각 config port 구현
  - application 서비스 의존 전환:
    - `ReservationServiceImpl`
    - `ReservationLifecycleServiceImpl`
    - `SeatSoftLockServiceImpl`
    - `PgReadyWebhookService`
    - `WaitingQueueServiceImpl`
    - `JwtTokenProvider`
    - `AbuseAuditServiceImpl`
  - `ConcertServiceImpl`의 `ConcertCacheNames(global)` 직접 의존 제거(로컬 상수화)
  - ArchUnit 규칙 보강:
    - `application_should_not_depend_on_global_layer`
- 목표:
  - application 계층은 global 구현/설정 타입 직접 참조 없이 포트 기준으로만 동작
- 구현 결과:
  - `application -> global` 직접 import 잔여: `0`건 / `0`파일
  - 기존 규칙과 합쳐 경계 스냅샷:
    - `global -> api` 직접 import: `0`
    - `global -> infrastructure` 직접 import: `0`
    - `api/global -> infrastructure.messaging` 직접 import: `0`

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - 캐시 TTL/키 정책 자체 변경
  - OAuth/JWT 만료 시간 운영값 변경
  - Push 전송 채널(SSE/WS/Kafka) 동작 방식 변경

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.application.waitingqueue.service.WaitingQueueServiceImplTest' --tests 'com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest' --tests 'com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest' --tests 'com.ticketrush.application.auth.service.AuthSessionServiceTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest' --tests 'com.ticketrush.api.controller.AuthSecurityIntegrationTest'`
- 결과:
  - compile/test 타깃 세트 PASS
  - ArchUnit에 `application -> global` 금지 규칙 반영 후 PASS

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open, DDD 연속 트래킹)
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에 누적 관리
