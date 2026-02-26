# Meeting Notes: DDD Phase8-E Auth API Domain-Model Decoupling (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-24 03:02:00`
> - **Updated At**: `2026-02-24 03:02:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase8-E)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase8-D 이후 runtime adapter 경계는 정리됐지만,
    auth API(`AuthController`, `SocialAuthController`, `api/dto/auth/*`)는 `domain.auth.model`에 직접 의존하고 있었다.
  - adapter(API)에서 domain 모델을 직접 다루면 경계 변경 시 파급이 커지므로 application 결과 모델로 분리 필요.

## 안건 2: 이번 범위(Phase8-E)
- Status: DONE
- 범위:
  - application auth 결과 모델 추가:
    - `application.auth.model.AuthTokenResult`
    - `application.auth.model.SocialAuthorizeResult`
    - `application.auth.model.SocialLoginUserResult`
  - inbound 포트 시그니처 정렬:
    - `AuthSessionUseCase`:
      - `issueForUserId(Long userId)`
      - `refresh(...) -> AuthTokenResult`
    - `SocialAuthUseCase`:
      - `getAuthorizeInfo(String provider, String state)`
      - `login(String provider, String code, String state)`
  - 서비스 구현 정렬:
    - `AuthSessionServiceImpl`는 user 조회 + 토큰 발급 결과를 `AuthTokenResult`로 반환
    - `SocialAuthServiceImpl`는 provider 문자열을 내부에서 enum 변환하고 `SocialLoginUserResult` 반환
  - API adapter/DTO 정렬:
    - `AuthController`, `SocialAuthController`
    - `AuthTokenResponse`, `SocialAuthorizeUrlResponse`, `SocialLoginResponse`
  - 테스트 정렬:
    - `AuthSessionServiceTest`, `SocialAuthServiceTest`
    - `SocialAuthControllerIntegrationTest` 시그니처/expectation 반영
  - ArchUnit 규칙 강화:
    - `auth_api_should_not_depend_on_domain_auth_models`
    - `social_auth_api_should_not_depend_on_social_provider_enum_directly`
- 목표:
  - auth API 경계에서 domain auth 모델/enum 노출을 제거하고 `api -> application result` 흐름으로 고정

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - `/api/auth/me`의 `User` 반환 경계는 user 도메인 후속 단계에서 정리(이번 범위 제외)
  - OAuth provider 클라이언트 구현체 및 외부 통신 로직 변경 없음
  - endpoint/응답 필드 계약 변경 없음

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests com.ticketrush.architecture.LayerDependencyArchTest --tests com.ticketrush.api.controller.AuthSecurityIntegrationTest --tests com.ticketrush.api.controller.SocialAuthControllerIntegrationTest --tests com.ticketrush.application.auth.service.AuthSessionServiceTest --tests com.ticketrush.application.auth.service.SocialAuthServiceTest --tests com.ticketrush.api.controller.WebSocketPushControllerTest --tests com.ticketrush.global.scheduler.ReservationLifecycleSchedulerTest --tests com.ticketrush.global.scheduler.WaitingQueueSchedulerTest --tests com.ticketrush.application.payment.webhook.PgReadyWebhookServiceTest --tests com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest`
  - `rg -n "com\\.ticketrush\\.domain\\.auth\\.model|com\\.ticketrush\\.domain\\.user\\.SocialProvider" src/main/java/com/ticketrush/api/controller src/main/java/com/ticketrush/api/dto/auth`
- 결과:
  - compile/test PASS
  - auth API(`controller + dto/auth`) 기준 domain auth model/social provider 직접 의존 0건 확인

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` Phase8-E 반영
