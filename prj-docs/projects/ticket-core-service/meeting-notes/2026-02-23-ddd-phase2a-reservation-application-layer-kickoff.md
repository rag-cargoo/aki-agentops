# Meeting Notes: DDD Phase2-A Reservation Application Boundary Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 07:55:00`
> - **Updated At**: `2026-02-23 07:55:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(Phase2-A)
> - 안건 3: 제외 범위
> - 안건 4: 검증 계획
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - Phase1에서 `Entity -> api`/`Controller -> Repository` 경계 위반은 해소했다.
  - 현재 잔여는 `domain service -> api dto` 의존이며, DDD 경계상 Phase2에서 제거가 필요하다.

## 안건 2: 이번 범위(Phase2-A)
- Status: DOING
- 범위:
  - `reservation` 도메인 서비스 계층에서 `api.dto` 의존을 제거한다.
  - 적용 대상:
    - `ReservationService*`
    - `ReservationLifecycleService*`
    - `SalesPolicyService*`
  - 방향:
    - 서비스 입력/출력 계약을 도메인 전용 모델(명령/결과)로 치환
    - 컨트롤러에서 API DTO 변환 책임을 가진다

## 안건 3: 제외 범위
- Status: DONE
- 제외:
  - `waitingqueue` 서비스 계층 정리는 Phase2-B에서 수행한다.
  - `payment/webhook` 서비스 계층 정리는 Phase2-B에서 수행한다.
  - application/use-case 계층 전면 도입은 별도 후속 단계로 유지한다.

## 안건 4: 검증 계획
- Status: DOING
- 검증:
  - `./gradlew clean compileJava`
  - `./gradlew test --tests '*LayerDependencyArchTest' --tests '*ReservationLifecycleServiceIntegrationTest' --tests '*AuthSecurityIntegrationTest'`
  - 필요 시 reservation 관련 단위/통합 테스트 추가 보강

## 안건 5: 트래킹
- Status: DOING
- Product:
  - `rag-cargoo/ticket-core-service#33` (reopened, cross-repo shorthand)
  - `rag-cargoo/ticket-core-service#33 comment 3941854946` (phase2-a kickoff)
- Sidecar:
  - `prj-docs/projects/ticket-core-service/task.md`의 `TCS-SC-026`에서 Phase2 진행상태를 누적 관리한다.

## 증빙
- Context:
  - `prj-docs/projects/ticket-core-service/meeting-notes/2026-02-23-clean-ddd-hexagonal-governance-kickoff.md`
- Residual Snapshot:
  - `domain -> api` import 잔여: `17`건 / `9`파일 (as-is 기준)
