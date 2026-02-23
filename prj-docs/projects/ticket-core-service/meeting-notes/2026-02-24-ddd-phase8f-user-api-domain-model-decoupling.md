# Meeting Notes: DDD Phase8-F User API Domain-Model Decoupling (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-24 03:13:00`
> - **Updated At**: `2026-02-24 03:13:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase8-F)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase8-E 완료 이후에도 user API 경계에 `domain.user` 직접 의존이 남아 있었다.
    - `AuthController#me`
    - `AuthMeResponse`
    - `UserRequest`, `UserUpdateRequest`, `UserResponse`
  - adapter(API)가 domain user 모델/enum을 직접 참조하면 auth/user 경계 변경 시 파급 범위가 커지므로 application 결과 모델 경유가 필요했다.

## 안건 2: 이번 범위(Phase8-F)
- Status: DONE
- 범위:
  - application user 결과 모델 추가:
    - `application.user.model.UserResult`
  - inbound 포트 시그니처 정렬:
    - `UserUseCase`:
      - `createUser(String username, String tier) -> UserResult`
      - `getUsers() -> List<UserResult>`
      - `getUser(Long id) -> UserResult`
      - `updateUser(..., String tier, ...) -> UserResult`
  - 서비스 구현 정렬:
    - `UserServiceImpl`:
      - domain `User`를 `UserResult`로 매핑해 반환
      - tier 입력을 문자열 기반으로 파싱/검증(`Invalid user tier` 예외)
  - API adapter/DTO 정렬:
    - `AuthController`의 `/api/auth/me`는 `UserResult` 기반으로 응답 매핑
    - `AuthMeResponse`는 `UserResult` 기반으로 변환
    - `UserRequest`, `UserUpdateRequest`의 `tier`를 문자열 계약으로 전환
    - `UserResponse`는 `UserResult` 기반으로 변환
  - 테스트/규칙 정렬:
    - `AuthSecurityIntegrationTest`
    - `UserServiceImplDataJpaTest`(invalid tier 케이스 추가)
    - ArchUnit 규칙 추가:
      - `user_api_should_not_depend_on_domain_user_models`
- 목표:
  - user/auth-me adapter 경계를 `api -> application result` 계약으로 고정하고 `domain.user` 직접 의존 재유입을 차단

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - catalog/concert/reservation/payment DTO의 domain 모델 의존 제거는 후속 단계로 분리
  - OAuth provider client/인증 필터/결제 게이트웨이 런타임 경계 변경 없음
  - endpoint URI 자체 변경 없음

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon`
  - `./gradlew test --no-daemon --tests com.ticketrush.architecture.LayerDependencyArchTest --tests com.ticketrush.api.controller.AuthSecurityIntegrationTest --tests com.ticketrush.application.user.service.UserServiceImplDataJpaTest`
  - `./gradlew test --no-daemon --tests com.ticketrush.api.controller.SocialAuthControllerIntegrationTest`
  - `rg -n "^import com\\.ticketrush\\.domain\\." src/main/java/com/ticketrush/api/dto src/main/java/com/ticketrush/api/controller src/main/java/com/ticketrush/api/waitingqueue`
- 결과:
  - compile/test PASS
  - user/auth-me 대상(`AuthController`, `UserController`, `UserRequest`, `UserUpdateRequest`, `UserResponse`, `AuthMeResponse`)의 `domain.user` 직접 의존 0건 확인
  - API DTO 전체 기준 domain import 잔여 `16`건 확인(후속 분리 대상)

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33`
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026` Phase8-F 반영
