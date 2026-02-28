# Meeting Notes: KPOP20 Startup Seed Mode + Marker Governance (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-03-01 02:33:00`
> - **Updated At**: `2026-03-01 02:33:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 합의사항
> - 안건 2: 구현 내용
> - 안건 3: 운영 가드레일
> - 안건 4: 검증 결과
> - 안건 5: 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 합의사항
- Status: DONE
- 합의:
  - KPOP20 더미 데이터는 스크립트 실행 의존을 줄이고, 백엔드 기동 시 `enabled` 플래그로 제어 가능한 경로를 제공한다.
  - 분산 환경에서는 기본값 `false`를 유지하고, 필요 시 한 인스턴스만 `true`로 올려 초기 시드를 수행한다.
  - 중복 생성 방지는 seed marker로 보장한다.

## 안건 2: 구현 내용
- Status: DONE
- 구현:
  - `DataInitializer`에 KPOP20 startup seed 경로 추가
  - 설정 추가:
    - `APP_SEED_KPOP20_ENABLED` (default `false`)
    - `APP_SEED_KPOP20_MARKER_KEY`
    - `APP_SEED_KPOP20_PROFILES`
    - `APP_SEED_KPOP20_DATASET_RESOURCE`
    - `APP_SEED_KPOP20_TITLE_TAG`
    - `APP_SEED_KPOP20_MAX_RESERVATIONS_PER_USER`
    - `APP_SEED_KPOP20_TICKET_PRICE_AMOUNT`
  - 데이터셋 로딩:
    - classpath resource(`src/main/resources/seed/kpop20-demo-dataset.json`)에서 JSON 로딩 + 필수 필드 검증
  - 샘플 데이터 생성:
    - 콘서트/옵션/좌석/판매정책을 bucket 기반으로 생성
    - YouTube URL 기반 썸네일 다운로드 시도 + 실패 시 fallback 이미지 저장
  - 리밸런서 호환:
    - 타깃 식별 키워드를 `KPOP20` 기준으로 완화해 기존/신규 타이틀 모두 처리

## 안건 3: 운영 가드레일
- Status: DONE
- 원칙:
  - 운영 로직(예매/결제/실시간 처리)에는 변경 없음
  - seed 경로는 startup initializer 내부로 한정
  - 기본값은 `false`로 유지해 일반 배포에는 자동 생성이 발생하지 않음

## 안건 4: 검증 결과
- Status: DONE
- 검증:
  - `bash -n scripts/api/setup-kpop20-demo-data.sh` PASS
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.DataInitializerDataJpaTest' --tests 'com.ticketrush.architecture.LayerDependencyArchTest' --tests 'com.ticketrush.application.concert.service.ConcertExplorerIntegrationTest'` PASS

## 안건 5: 트래킹
- Status: DONE
- issue: `https://github.com/rag-cargoo/ticket-core-service/issues/59`
- branch: `feat/issue-59-kpop20-startup-seed`
- PR: `https://github.com/rag-cargoo/ticket-core-service/pull/61` (merged, commit `5a50a79`)
- task: `prj-docs/projects/ticket-core-service/task.md` (`TCS-SC-034`)
