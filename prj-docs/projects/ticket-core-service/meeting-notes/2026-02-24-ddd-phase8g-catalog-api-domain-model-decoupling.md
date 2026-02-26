# Meeting Notes: DDD Phase8-G Catalog API Domain-Model Decoupling (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-24 03:24:00`
> - **Updated At**: `2026-02-24 03:24:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase8-G)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase8-F 이후 API DTO 기준 domain import 잔여 16건 중 4건이 catalog 응답 DTO였다.
    - `EntertainmentResponse`
    - `ArtistResponse`
    - `PromoterResponse`
    - `VenueResponse`
  - catalog adapter가 domain 모델을 직접 참조하면 응답 계층 변경 시 도메인 파급이 커지므로 application 결과 모델을 경유하도록 정렬이 필요했다.

## 안건 2: 이번 범위(Phase8-G)
- Status: DONE
- 범위:
  - application catalog 결과 모델 추가:
    - `application.catalog.model.EntertainmentResult`
    - `application.catalog.model.ArtistResult`
    - `application.catalog.model.PromoterResult`
    - `application.catalog.model.VenueResult`
  - inbound 포트 시그니처 정렬:
    - `EntertainmentUseCase`, `ArtistUseCase`, `PromoterUseCase`, `VenueUseCase`
    - 반환 계약을 domain 엔티티에서 result 모델로 전환(`create/search/getAll/getById/update`)
  - 서비스 구현 정렬:
    - `EntertainmentServiceImpl`, `ArtistServiceImpl`, `PromoterServiceImpl`, `VenueServiceImpl`
    - domain 엔티티는 서비스 내부에서만 사용하고 외부에는 result 모델만 반환
  - API DTO 정렬:
    - `EntertainmentResponse`, `ArtistResponse`, `PromoterResponse`, `VenueResponse`를 result 모델 기반 변환으로 전환
  - 테스트/규칙 정렬:
    - `EntertainmentArtistCrudDataJpaTest`를 result 계약에 맞게 수정
    - ArchUnit 규칙 추가:
      - `catalog_api_should_not_depend_on_domain_catalog_models`
- 목표:
  - catalog adapter 경계를 `api -> application result` 계약으로 고정하고 domain catalog 모델 직접 의존 재유입을 차단

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - reservation/concert/payment DTO domain 모델 의존 제거는 후속 단계로 분리
  - catalog endpoint URI/파라미터 계약 변경 없음
  - 도메인 저장소/엔티티 구조 변경 없음

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests com.ticketrush.architecture.LayerDependencyArchTest --tests com.ticketrush.application.catalog.service.EntertainmentArtistCrudDataJpaTest --tests com.ticketrush.api.controller.AuthSecurityIntegrationTest --tests com.ticketrush.api.controller.SocialAuthControllerIntegrationTest`
  - `rg -n "^import com\\.ticketrush\\.domain\\." src/main/java/com/ticketrush/api/dto src/main/java/com/ticketrush/api/controller src/main/java/com/ticketrush/api/waitingqueue`
- 결과:
  - compile/test PASS
  - API DTO/controller 기준 domain import 잔여 `16 -> 12`로 감소
  - catalog 응답 DTO 4종의 domain 직접 의존 제거 완료

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` Phase8-G 반영
