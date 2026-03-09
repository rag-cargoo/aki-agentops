# Meeting Notes: DDD Phase4-G Auth/User Service Application Relocation Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 12:21:00`
> - **Updated At**: `2026-02-23 12:21:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase4-G)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase4-F에서 catalog controller의 `domain.*.service` 직접 의존을 제거했다.
  - 남은 controller direct dependency는 auth/user 축(`AuthController`, `SocialAuthController`, `UserController`)에 집중되어 있다.

## 안건 2: 이번 범위(Phase4-G)
- Status: DONE
- 범위:
  - 아래 서비스 인터페이스/구현을 `domain`에서 `application` 계층으로 이동
    - `AuthSessionService*`
    - `SocialAuthService*`
    - `UserService*`
  - `AuthController`, `SocialAuthController`, `UserController` import/주입 경로 정렬
  - 관련 테스트 package/import 정렬
  - ArchUnit 규칙 보강:
    - 위 3개 controller의 `domain.auth.service..`/`domain.user.service..` 직접 의존 금지
- 목표:
  - auth/user API 계층에서 domain service 직접 참조 제거
- 구현 결과:
  - 서비스 이동:
    - `domain.auth.service.AuthSessionService*` -> `application.auth.service.AuthSessionService*`
    - `domain.auth.service.SocialAuthService*` -> `application.auth.service.SocialAuthService*`
    - `domain.user.service.UserService*` -> `application.user.service.UserService*`
  - controller 정렬:
    - `AuthController`
    - `SocialAuthController`
    - `UserController`
  - 테스트 정렬:
    - `AuthSecurityIntegrationTest`
    - `SocialAuthControllerIntegrationTest`
    - `AuthSessionServiceTest` -> `application.auth.service`
    - `SocialAuthServiceTest` -> `application.auth.service`
    - `UserServiceImplDataJpaTest` -> `application.user.service`
  - ArchUnit 보강:
    - `auth_and_user_controllers_should_not_depend_on_domain_auth_user_services` 규칙 추가

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - `PaymentService*`, `ConcertService*` 이동
  - `JwtTokenProvider`, denylist 구현 이동
  - DB 스키마 변경
  - API endpoint/응답 스키마 변경

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.application.auth.service.AuthSessionServiceTest' --tests 'com.ticketrush.application.auth.service.SocialAuthServiceTest' --tests 'com.ticketrush.application.user.service.UserServiceImplDataJpaTest' --tests 'com.ticketrush.api.controller.AuthSecurityIntegrationTest' --tests 'com.ticketrush.api.controller.SocialAuthControllerIntegrationTest'`
- 결과:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.application.auth.service.AuthSessionServiceTest' --tests 'com.ticketrush.application.auth.service.SocialAuthServiceTest' --tests 'com.ticketrush.application.user.service.UserServiceImplDataJpaTest' --tests 'com.ticketrush.api.controller.AuthSecurityIntegrationTest' --tests 'com.ticketrush.api.controller.SocialAuthControllerIntegrationTest'` PASS

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open)
- Sidecar:
  - `rag-cargoo/aki-agentops#155` (reopened)
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에서 누적 관리
