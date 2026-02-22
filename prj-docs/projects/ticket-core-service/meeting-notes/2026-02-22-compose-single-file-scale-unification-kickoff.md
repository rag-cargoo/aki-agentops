# Meeting Notes: Compose Single-File + Scale Unification Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-22 22:17:08`
> - **Updated At**: `2026-02-22 22:29:51`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: compose 단일화 + scale 운영 기준
> - 안건 2: 이슈 라이프사이클 적용(#21 재오픈)
> - 안건 3: task 동기화
> - 안건 4: 구현/검증 계획
<!-- DOC_TOC_END -->

## 안건 1: compose 단일화 + scale 운영 기준
- Status: DONE
- 결정사항:
  - 분산 운영 기준 compose를 `docker-compose.yml` 단일 파일로 통합한다.
  - 앱 인스턴스 수는 서비스 분기(`app-node-1/2/3`)가 아니라 `app` 단일 서비스 + `--scale app=N`으로 운영한다.
  - 기본 인스턴스 수는 compose yaml 고정값이 아니라 실행 명령/스크립트 기본값으로 관리한다.

## 안건 2: 이슈 라이프사이클 적용(#21 재오픈)
- Status: DONE
- 처리결과:
  - 동일 분산 범위 후속으로 `ticket-core-service#21`을 재오픈하고 본 작업 범위를 코멘트로 누적했다.
  - 신규 이슈 생성 대신 기존 이슈를 재개해 분산 런타임 변경 히스토리를 단일 이슈에 유지한다.
  - 구현 PR `#28` 머지 완료 후 이슈 `#21`은 `CLOSED`로 종료됐다.
- 링크:
  - 이슈: `https://github.com/rag-cargoo/ticket-core-service/issues/21`
  - 후속 코멘트: `https://github.com/rag-cargoo/ticket-core-service/issues/21#issuecomment-3940924556`
  - PR: `https://github.com/rag-cargoo/ticket-core-service/pull/28`

## 안건 3: task 동기화
- Status: DONE
- 처리결과:
  - sidecar task에 `TCS-SC-023` 항목을 추가하고 구현/검증 완료 후 `DONE`으로 정렬했다.
  - meeting notes index + sidebar manifest에 신규 노트 링크를 동기화했다.

## 안건 4: 구현/검증 계획
- Status: DONE
- 구현 결과:
  - `docker-compose.yml`에 `ws-relay`, `nginx-lb`, `app` 단일 서비스 스케일 구조를 통합했다.
  - `docker-compose.distributed.yml`를 제거하고 분산 스크립트 기본 compose 경로를 `docker-compose.yml`로 정렬했다.
  - `scripts/perf/nginx/k6-distributed-lb.conf`를 고정 노드(`app-node-*`)에서 `app:8080` 동적 resolve 방식으로 전환했다.
  - `run-k6-waiting-queue-distributed.sh`에 `DIST_APP_REPLICAS`(기본 3) + `--scale app=<N>` 반영을 추가했다.
  - `README.md`/`Makefile`에 단일 compose + scale 운영 명령을 동기화했다.
  - WS broker 기본 모드를 relay로 정렬했다.
- 검증 결과:
  - `docker-compose -f docker-compose.yml config` PASS
  - `bash -n scripts/perf/run-k6-waiting-queue-distributed.sh` PASS
  - `./gradlew test --tests '*WebSocketConfigTest'` PASS
- 증빙:
  - `https://github.com/rag-cargoo/ticket-core-service/issues/21#issuecomment-3940943019`
  - `https://github.com/rag-cargoo/ticket-core-service/pull/28`
  - `workspace/apps/backend/ticket-core-service/docker-compose.yml`
  - `workspace/apps/backend/ticket-core-service/scripts/perf/run-k6-waiting-queue-distributed.sh`
  - `workspace/apps/backend/ticket-core-service/scripts/perf/nginx/k6-distributed-lb.conf`
  - `workspace/apps/backend/ticket-core-service/README.md`
  - `workspace/apps/backend/ticket-core-service/Makefile`
