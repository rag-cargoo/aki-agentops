# Meeting Notes: Backend Seed Strategy Completion and Issue #16 Closeout (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 06:49:48`
> - **Updated At**: `2026-02-23 06:49:48`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 완료 범위
> - 안건 2: 구현 상세
> - 안건 3: 검증 결과
> - 안건 4: 이슈/PR 정리
> - 안건 5: 후속 작업
<!-- DOC_TOC_END -->

## 안건 1: 완료 범위
- Status: DONE
- 범위:
  - Admin CRUD/카탈로그/도메인 분리 후 남아 있던 초기 시드 전략 항목을 완료한다.
  - `DataInitializer`를 `dev/demo` 프로필 분리 + runtime flag + idempotent marker 기반으로 정렬한다.
  - Product issue `#16` 종료 기준을 충족하고 close 판정까지 완료한다.

## 안건 2: 구현 상세
- Status: DONE
- 구현:
  - `DataInitializer` 고도화:
    - 관리 계정 시드와 포트폴리오 시드를 분리했다.
    - 포트폴리오 시드는 `APP_PORTFOLIO_SEED_ENABLED=true` + 허용 프로필(`local,demo`)에서만 동작한다.
    - 판매 상태 검증용 시나리오(`UNSCHEDULED`, `PREOPEN`, `OPEN_SOON_1H`, `OPEN_SOON_5M`, `OPEN`, `SOLD_OUT`) 데이터를 생성한다.
  - idempotent 마커 도입:
    - `seed_markers` 테이블(`SeedMarker`)과 `SeedMarkerRepository`를 추가했다.
    - marker 키(`APP_PORTFOLIO_SEED_MARKER_KEY`)가 존재하면 재시드를 차단한다.
  - 문서/설정 동기화:
    - `application.yml`에 seed runtime 옵션을 추가했다.
    - `README.md`에 운영 오버라이드 옵션(시드 플래그/프로필/마커)을 반영했다.

## 안건 3: 검증 결과
- Status: DONE
- 결과:
  - `./gradlew clean compileJava` PASS
  - `./gradlew test --tests '*DataInitializerDataJpaTest'` PASS
  - `./gradlew test --tests '*ReservationStateMachineTest' --tests '*SeatSoftLockServiceImplTest' --tests '*ReservationLifecycleServiceIntegrationTest'` PASS
- 보강 테스트:
  - `DataInitializerDataJpaTest`에서
    - local profile + seed enabled 시 1회 시드 적용을 검증했다.
    - disallowed profile(docker)에서 포트폴리오 시드 비활성을 검증했다.

## 안건 4: 이슈/PR 정리
- Status: DONE
- Product:
  - Issue: `https://github.com/rag-cargoo/ticket-core-service/issues/16` (closed)
  - PR:
    - `https://github.com/rag-cargoo/ticket-core-service/pull/31` (merged)
    - `https://github.com/rag-cargoo/ticket-core-service/pull/32` (merged)
  - Merge Commit:
    - `41aaefbc62099bf3ec760dae54b7a6d01160e991` (PR #31)
    - `bfe1692f0a72ef64fdd5502724ab9070411c081c` (PR #32)

## 안건 5: 후속 작업
- Status: TODO
- 후속:
  - 프론트 Admin 셀렉트 플로우(Entertainment -> Artist, Promoter, Venue) 실백엔드 연동 강화
  - 관리자 CRUD/공개 조회 계약을 포함한 프론트 E2E 계약 검증 확대

## 증빙
- 코드:
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/DataInitializer.java`
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/domain/seed/SeedMarker.java`
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/domain/seed/SeedMarkerRepository.java`
  - `workspace/apps/backend/ticket-core-service/src/test/java/com/ticketrush/DataInitializerDataJpaTest.java`
  - `workspace/apps/backend/ticket-core-service/src/main/resources/application.yml`
  - `workspace/apps/backend/ticket-core-service/README.md`
