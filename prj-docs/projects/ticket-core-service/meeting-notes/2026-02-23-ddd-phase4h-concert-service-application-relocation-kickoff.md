# Meeting Notes: DDD Phase4-H Concert Service Application Relocation Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 12:36:00`
> - **Updated At**: `2026-02-23 12:39:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase4-H)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase4-G에서 auth/user controller의 `domain.*.service` 직접 의존을 제거했다.
  - 현재 controller direct dependency는 `ConcertController`, `AdminConcertController`의 `domain.concert.service.ConcertService`가 잔여 상태다.

## 안건 2: 이번 범위(Phase4-H)
- Status: DONE
- 범위:
  - `ConcertService*`를 `domain.concert.service` -> `application.concert.service`로 이동
  - `ConcertController`, `AdminConcertController` import/주입 경로 정렬
  - concert service 참조 테스트 import 정렬(동시성 테스트 포함)
  - ArchUnit 규칙 보강:
    - concert controller 2종의 `domain.concert.service..` 직접 의존 금지
- 목표:
  - concert API 계층에서 domain service 직접 의존 제거
- 구현 결과:
  - 서비스 이동:
    - `domain.concert.service.ConcertService*` -> `application.concert.service.ConcertService*`
  - controller 정렬:
    - `ConcertController`
    - `AdminConcertController`
  - 테스트 정렬:
    - reservation 동시성 테스트 4종 import를 `application.concert.service.ConcertService`로 갱신
    - `ConcertExplorerIntegrationTest` package를 `application.concert.service`로 정렬
  - ArchUnit 보강:
    - `concert_controllers_should_not_depend_on_domain_concert_services` 규칙 추가

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - `PaymentService*` 이동
  - payment gateway 패키지 정렬
  - DB 스키마 변경
  - API endpoint/필드 스키마 변경

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest'`
- 결과:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest'` PASS

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open)
- Sidecar:
  - `rag-cargoo/aki-agentops#155` (reopened)
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에서 누적 관리
