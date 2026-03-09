# Meeting Notes: DDD Phase4-A ArchUnit Guardrail + CI Verify Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 09:33:00`
> - **Updated At**: `2026-02-23 09:38:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase4-A)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase3-B 완료로 `domain -> api dto`, `application -> api dto` import 잔여가 `0`건이 되었다.
  - 다음 단계는 재발 방지용 아키텍처 테스트 가드레일을 CI에 고정하는 것이다.

## 안건 2: 이번 범위(Phase4-A)
- Status: DONE
- 범위:
  - `LayerDependencyArchTest` 규칙 강화
    - `domain -> api` 금지(패키지 단위)
    - `application -> api` 금지(패키지 단위)
    - `RestController -> Repository 직접 의존` 금지
  - CI `verify` 워크플로 추가(ArchUnit 테스트 상시 실행)
  - 가능 시 main branch required check에 `verify` 등록
- 구현 결과:
  - 아키텍처 테스트 강화:
    - `src/test/java/com/ticketrush/architecture/LayerDependencyArchTest.java`
      - `domain -> api` 금지
      - `application -> api` 금지
      - `@RestController -> *Repository` 직접 의존 금지
  - CI 워크플로 추가:
    - `.github/workflows/verify.yml`
      - `pull_request/push(main)`에서 `LayerDependencyArchTest` 상시 실행
  - GitHub 보호 규칙 반영:
    - `main` branch protection 활성화
    - required status check: `verify`(strict=true)

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - 도메인 모델/상태머신 로직 변경
  - API 스펙/응답 스키마 변경
  - 대규모 패키지 재배치

## 안건 4: 검증 계획
- Status: DONE
- 검증:
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest'`
  - `./gradlew compileJava compileTestJava --no-daemon`
- 결과:
  - `./gradlew test --no-daemon --tests 'com.ticketrush.architecture.LayerDependencyArchTest'` PASS
  - `./gradlew compileJava compileTestJava --no-daemon` PASS

## 안건 5: 트래킹
- Status: DONE
- Product:
  - `rag-cargoo/ticket-core-service#33` (open)
- Sidecar:
  - `rag-cargoo/aki-agentops#155` (reopened)
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에서 누적 관리
