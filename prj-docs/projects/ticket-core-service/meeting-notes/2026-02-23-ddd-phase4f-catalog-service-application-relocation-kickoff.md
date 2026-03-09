# Meeting Notes: DDD Phase4-F Catalog Service Application Relocation Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 11:36:00`
> - **Updated At**: `2026-02-23 11:41:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase4-F)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase4-E까지 reservation 축의 application/infrastructure 경계 정리를 완료했다.
  - `catalog CRUD` 영역의 controller는 여전히 `domain.*.service`를 직접 참조하고 있어 application 경유 구조로 정렬이 필요하다.

## 안건 2: 이번 범위(Phase4-F)
- Status: DONE
- 범위:
  - 아래 서비스 인터페이스/구현을 `domain`에서 `application` 계층으로 이동
    - `EntertainmentService*`
    - `ArtistService*`
    - `PromoterService*`
    - `VenueService*`
  - catalog 관련 controller import/주입 경로 정렬
  - 관련 통합 테스트 import/package 정렬
  - ArchUnit 규칙 보강:
    - catalog controller 5종이 `domain.*.service`에 직접 의존하지 않도록 고정
- 목표:
  - catalog API는 application 서비스만 참조하고 domain은 entity/repository 중심으로 정렬
- 구현 결과:
  - 서비스 이동:
    - `domain.*.service` -> `application.catalog.service`
    - 이동 대상:
      - `EntertainmentService`, `EntertainmentServiceImpl`
      - `ArtistService`, `ArtistServiceImpl`
      - `PromoterService`, `PromoterServiceImpl`
      - `VenueService`, `VenueServiceImpl`
  - 참조 정렬:
    - `EntertainmentController`
    - `EntertainmentCatalogController`
    - `ArtistController`
    - `PromoterController`
    - `VenueController`
    - `EntertainmentArtistCrudDataJpaTest`
  - ArchUnit 보강:
    - catalog controller 5종의 `domain.*.service` 직접 의존 금지 규칙 추가
      - `catalog_controllers_should_not_depend_on_domain_catalog_services`

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - `ConcertService*`, `PaymentService*`, `AuthSessionService*`, `SocialAuthService*`, `UserService*` 이동
  - DB 스키마 변경
  - API endpoint/필드 스키마 변경

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest'`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.application.catalog.service.EntertainmentArtistCrudDataJpaTest'`
- 결과:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.application.catalog.service.EntertainmentArtistCrudDataJpaTest'` PASS

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open)
- Sidecar:
  - `rag-cargoo/aki-agentops#155` (reopened)
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에서 누적 관리
