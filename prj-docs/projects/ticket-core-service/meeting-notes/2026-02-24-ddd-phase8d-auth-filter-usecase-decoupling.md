# Meeting Notes: DDD Phase8-D Auth Filter UseCase Decoupling (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-24 00:56:00`
> - **Updated At**: `2026-02-24 00:59:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase8-D)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase8-C 이후 global/infrastructure에서 남은 `application..service` 직접 의존은
    `JwtAuthenticationFilter -> JwtTokenProvider` 1건이었다.
  - 인증 필터도 adapter이므로 JWT 파싱/검증 로직 구현 대신 inbound contract에 의존하도록 정렬이 필요했다.

## 안건 2: 이번 범위(Phase8-D)
- Status: DONE
- 범위:
  - inbound 포트 추가:
    - `application.auth.port.inbound.AuthTokenAuthenticationUseCase`
  - application 구현 추가:
    - `application.auth.service.AuthTokenAuthenticationServiceImpl`
      - access token 파싱/타입검증/denylist 검사/`AuthUserPrincipal` 생성 담당
  - infrastructure 의존 전환:
    - `infrastructure.auth.security.JwtAuthenticationFilter`
      - 기존 의존: `JwtTokenProvider`, `AccessTokenDenylistService`
      - 전환 후: `AuthTokenAuthenticationUseCase`
  - 테스트 정렬:
    - `AuthSecurityIntegrationTest`, `SocialAuthControllerIntegrationTest`에서 filter 의존을 usecase mock 기반으로 조정
  - ArchUnit 규칙 강화:
    - `jwt_authentication_filter_should_not_depend_on_jwt_token_provider_service_directly`
    - `runtime_adapters_should_not_depend_on_application_service_package_directly`
- 목표:
  - 인증 adapter까지 `adapter -> inbound usecase`로 완전 정렬하여 runtime layer의 service 직접 의존을 0으로 수렴

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - JWT 토큰 포맷/claim 규약 변경 없음
  - 보안 정책(SecurityConfig) 변경 없음
  - API endpoint 및 응답 스키마 변경 없음

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests com.ticketrush.architecture.LayerDependencyArchTest --tests com.ticketrush.api.controller.AuthSecurityIntegrationTest --tests com.ticketrush.api.controller.SocialAuthControllerIntegrationTest --tests com.ticketrush.api.controller.WebSocketPushControllerTest --tests com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest --tests com.ticketrush.global.scheduler.WaitingQueueSchedulerTest --tests com.ticketrush.application.realtime.service.RealtimeSubscriptionServiceImplTest --tests com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest --tests com.ticketrush.application.reservation.service.SeatSoftLockServiceImplTest --tests com.ticketrush.application.auth.service.AuthSessionServiceTest --tests com.ticketrush.application.auth.service.SocialAuthServiceTest --tests com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest --tests com.ticketrush.application.payment.service.PaymentServiceIntegrationTest --tests com.ticketrush.application.user.service.UserServiceImplDataJpaTest`
  - `rg -n "com\\.ticketrush\\.application\\..*\\.service" src/main/java/com/ticketrush/global src/main/java/com/ticketrush/infrastructure`
- 결과:
  - compile/test PASS
  - global/infrastructure의 `application..service` 직접 의존 0건 확인

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` Phase8-D 반영
