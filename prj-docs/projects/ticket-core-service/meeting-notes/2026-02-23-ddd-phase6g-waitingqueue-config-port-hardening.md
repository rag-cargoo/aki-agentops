# Meeting Notes: DDD Phase6-G WaitingQueue Config Port Hardening (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 20:20:00`
> - **Updated At**: `2026-02-23 20:20:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase6-G)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase6-F에서 `infrastructure -> global` 직접 의존을 제거했다.
  - `global` 런타임 컴포넌트(`scheduler/sse/interceptor`)에는
    `WaitingQueueProperties` 구체 타입 의존이 남아 있었다.

## 안건 2: 이번 범위(Phase6-G)
- Status: DONE
- 범위:
  - `WaitingQueueConfigPort` 확장:
    - `getActivationBatchSize()`
    - `getActivationConcertId()`
    - `getSseTimeoutMillis()`
  - 런타임 컴포넌트 의존 전환:
    - `WaitingQueueScheduler` -> `WaitingQueueConfigPort`
    - `SsePushNotifier` -> `WaitingQueueConfigPort`
    - `WaitingQueueInterceptor` -> `WaitingQueueConfigPort`
  - 테스트 정렬:
    - `WaitingQueueSchedulerTest` mock 타입을 `WaitingQueueConfigPort`로 전환
  - ArchUnit 강화:
    - `waiting_queue_runtime_should_not_depend_on_waiting_queue_properties_concrete`
- 목표:
  - 런타임 컴포넌트에서 설정 구체 타입을 제거해 포트 기반 의존으로 고정

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - 대기열 API/응답 스키마 변경
  - SSE/WebSocket destination 변경
  - 스케줄러 실행 주기 변경

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.global.scheduler.WaitingQueueSchedulerTest' --tests 'com.ticketrush.global.sse.SsePushNotifierTest'`
- 결과:
  - compile/test PASS
  - 신규 ArchUnit 규칙 포함 PASS

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md` `TCS-SC-026`에 누적 반영
