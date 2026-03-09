# Meeting Notes: Demo Rebalancer Deterministic Dataset and Arch Guard Alignment (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-03-01 00:55:00`
> - **Updated At**: `2026-03-01 00:55:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 목표
> - 안건 2: 백엔드 반영 사항
> - 안건 3: 아키텍처 경계 보정
> - 안건 4: 검증 결과
> - 안건 5: 연계 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 목표
- Status: DONE
- 요약:
  - 데모 리밸런싱 실행 후에도 요구한 상태 분포/우선순위(오픈 임박/매진 임박)가 유지되도록 데이터 생성 로직을 결정론적으로 고정한다.
  - 운영 코드 침범을 막기 위해 데모 리밸런서 기능은 환경설정 기반으로 로컬/데모 환경에 한정한다.

## 안건 2: 백엔드 반영 사항
- Status: DONE
- 변경:
  - `POST /api/dev/demo/rebalancer/run`, `GET /api/dev/demo/rebalancer/status` 엔드포인트를 도입하고 비동기 Job 상태(`phase/progress/log line`)를 노출했다.
  - 리밸런서 상태 버킷을 아티스트 기준으로 고정 매핑해, 재실행 시에도 상태 분포와 우선순위가 유지되도록 정렬했다.
    - `OPEN`: `BTS`, `Saja Boys`, `BLACKPINK`
    - `OPEN_SOON`: `Stray Kids` 외 지정 그룹
    - `SOLD_OUT`/`UNSCHEDULED` 분리 고정
  - `OPEN` 그룹은 가용 좌석 비율을 결정론적으로 고정해 매진 임박 Top3 순위가 안정적으로 유지되도록 반영했다.
  - `setup-kpop20-demo-data.sh`를 확장해 `UNSCHEDULED` 버킷, 24개 데이터셋, YouTube 링크/썸네일 품질 보정을 포함했다.

## 안건 3: 아키텍처 경계 보정
- Status: DONE
- 보정:
  - `DemoRebalancerUseCase`(application inbound port)를 도입해 API controller의 `application..service` 직접 의존을 제거했다.
  - `DemoRebalancerProperties`를 `application.demo.config`로 이동해 `application -> global` 의존을 해소했다.
  - 데모 리밸런서 서비스/컨트롤러 모두 `app.demo-rebalancer.enabled=true`일 때만 활성화되도록 조건부 로딩을 적용했다.

## 안건 4: 검증 결과
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `./gradlew test --no-daemon --tests 'com.ticketrush.application.concert.service.ConcertExplorerIntegrationTest' --tests 'com.ticketrush.global.push.WebSocketPushNotifierTest' --tests 'com.ticketrush.architecture.LayerDependencyArchTest'` PASS
  - 리밸런서 실행 후 API 점검:
    - 상태 분포(`OPEN/OPEN_SOON/PREOPEN/SOLD_OUT/UNSCHEDULED`) 정상 반영
    - 매진 임박 Top3 우선순위(`BTS -> Saja Boys -> BLACKPINK`) 확인

## 안건 5: 연계 트래킹
- Status: DONE
- 트래킹:
  - task: `prj-docs/projects/ticket-core-service/task.md` (`TCS-SC-032`)
  - issue:
    - `https://github.com/rag-cargoo/ticket-core-service/issues/55` (progress comment update)
    - `https://github.com/rag-cargoo/ticket-core-service/issues/15` (status contract 연계 코멘트)
  - 코드 범위:
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/api/controller/DemoRebalancerController.java`
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/application/demo/**`
    - `workspace/apps/backend/ticket-core-service/scripts/api/setup-kpop20-demo-data.sh`
