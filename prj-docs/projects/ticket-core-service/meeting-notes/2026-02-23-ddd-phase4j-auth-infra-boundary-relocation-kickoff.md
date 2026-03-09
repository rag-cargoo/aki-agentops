# Meeting Notes: DDD Phase4-J Auth Infra Boundary Relocation Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 13:40:00`
> - **Updated At**: `2026-02-23 13:47:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase4-J)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase4-I에서 payment API/gateway 경계를 application/infrastructure로 정렬했다.
  - auth 영역에는 아직 domain 패키지에 infra/security 구현체가 남아 있다.
  - 특히 `oauth client`, `jwt filter`, `denylist impl/config`는 domain 계층 책임이 아니다.

## 안건 2: 이번 범위(Phase4-J)
- Status: DONE
- 범위:
  - auth infra/security 구현체 이동:
    - `domain.auth.oauth.(KakaoOAuthClient, NaverOAuthClient)` -> `infrastructure.auth.oauth`
    - `domain.auth.security.JwtAuthenticationFilter` -> `infrastructure.auth.security`
    - `domain.auth.service.(InMemoryAccessTokenDenylistService, RedisAccessTokenDenylistService)` -> `infrastructure.auth.denylist`
    - `domain.auth.config.AccessTokenDenylistConfig` -> `infrastructure.auth.config`
  - auth principal/token 지원 경계 정렬:
    - `domain.auth.security.AuthUserPrincipal` -> `application.auth.model`
    - `domain.auth.service.JwtTokenProvider` -> `application.auth.service`
  - auth 관련 controller/test import 정렬
  - ArchUnit 규칙 보강:
    - domain 계층의 infrastructure 직접 의존 금지 규칙 추가
- 목표:
  - domain.auth에는 entity/model/repository/port(interface)만 남기고, 구현체는 application/infrastructure로 정렬
- 구현 결과:
  - auth package relocation:
    - `AuthUserPrincipal` -> `application.auth.model`
    - `JwtTokenProvider` -> `application.auth.service`
    - `JwtAuthenticationFilter` -> `infrastructure.auth.security`
    - `KakaoOAuthClient`, `NaverOAuthClient` -> `infrastructure.auth.oauth`
    - `InMemoryAccessTokenDenylistService`, `RedisAccessTokenDenylistService` -> `infrastructure.auth.denylist`
    - `AccessTokenDenylistConfig` -> `infrastructure.auth.config`
  - main/test import 정렬:
    - `AuthController`, `ReservationController`, `WebSocketPushController`, `SecurityConfig`
    - `AuthSecurityIntegrationTest`, `SocialAuthControllerIntegrationTest`,
      `SocialAuthCallbackRedirectController*Test`, `WebSocketPushControllerTest`, `AuthSessionServiceTest`
  - ArchUnit 보강:
    - `domain_should_not_depend_on_infrastructure_layer` 규칙 추가

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - 인증 API endpoint/응답 스키마 변경
  - JWT claim 구조/만료 정책 변경
  - OAuth provider business flow 변경
  - DB 스키마 변경

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.application.auth.service.AuthSessionServiceTest' --tests 'com.ticketrush.application.auth.service.SocialAuthServiceTest' --tests 'com.ticketrush.api.controller.AuthSecurityIntegrationTest' --tests 'com.ticketrush.api.controller.SocialAuthControllerIntegrationTest' --tests 'com.ticketrush.api.controller.WebSocketPushControllerTest'`
- 결과:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.application.auth.service.AuthSessionServiceTest' --tests 'com.ticketrush.application.auth.service.SocialAuthServiceTest' --tests 'com.ticketrush.api.controller.AuthSecurityIntegrationTest' --tests 'com.ticketrush.api.controller.SocialAuthControllerIntegrationTest' --tests 'com.ticketrush.api.controller.WebSocketPushControllerTest'` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.api.controller.SocialAuthCallbackRedirectControllerTest' --tests 'com.ticketrush.api.controller.SocialAuthCallbackRedirectControllerExternalUrlTest'` PASS

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open)
- Sidecar:
  - `rag-cargoo/aki-agentops#155` (reopened)
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에서 누적 관리
