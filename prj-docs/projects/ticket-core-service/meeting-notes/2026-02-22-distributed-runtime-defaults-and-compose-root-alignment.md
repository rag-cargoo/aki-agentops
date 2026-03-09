# Meeting Notes: Distributed Runtime Defaults and Compose Root Alignment (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-22 20:30:00`
> - **Updated At**: `2026-02-22 20:30:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 분산 compose 경로 기준 정렬
> - 안건 2: 분산 런타임 기본 WS broker 모드 정렬
> - 안건 3: 운영 기본값(env override) 정렬
> - 진행현황: 완료/남은 항목
<!-- DOC_TOC_END -->

## 안건 1: 분산 compose 경로 기준 정렬
- Status: DONE
- 결정사항:
  - 분산 실행용 compose는 실험 스크립트 하위가 아니라 프로젝트 루트에 둔다.
  - 대상 파일을 `docker-compose.distributed.yml`로 루트 고정해 운영 진입점을 명확히 한다.
  - k6 분산 스크립트의 기본 compose 참조 경로도 루트 기준으로 맞춘다.

## 안건 2: 분산 런타임 기본 WS broker 모드 정렬
- Status: DONE
- 결정사항:
  - 분산 compose 기본은 `APP_WS_BROKER_MODE=relay`로 고정한다.
  - compose 내부에 STOMP relay 서비스(`ws-relay`)를 포함해 단일 노드 simple broker 의존을 제거한다.
  - app 노드들은 relay host/port/login/passcode를 compose 환경변수로 주입한다.

## 안건 3: 운영 기본값(env override) 정렬
- Status: DONE
- 결정사항:
  - 다음 값은 코드 하드코딩이 아니라 운영에서 env로 오버라이드 가능하도록 고정한다.
    - `APP_RESERVATION_SOFT_LOCK_TTL_SECONDS` (기본 `30`)
    - `APP_PAYMENT_PROVIDER` (기본 `wallet`)
  - `APP_PUSH_MODE`, `APP_WS_BROKER_MODE`는 기존처럼 env 기반 스위치로 유지한다.
  - README에 분산 compose 위치/relay 기본/override 키를 명시한다.

## 진행현황: 완료/남은 항목
- Status: DONE
- 완료된 것:
  - Tracking Issue 재개:
    - `rag-cargoo/ticket-core-service#21` reopen
    - 진행 코멘트: `https://github.com/rag-cargoo/ticket-core-service/issues/21#issuecomment-3940744518`
  - 구현 반영:
    - `workspace/apps/backend/ticket-core-service/docker-compose.distributed.yml` 루트 배치
    - `workspace/apps/backend/ticket-core-service/scripts/perf/run-k6-waiting-queue-distributed.sh` 기본 compose 경로 보정
    - `workspace/apps/backend/ticket-core-service/src/main/resources/application.yml` env override 반영
    - `workspace/apps/backend/ticket-core-service/src/main/resources/application-local.yml` env override 반영
    - `workspace/apps/backend/ticket-core-service/src/main/resources/application-docker.yml` env override 반영
    - `workspace/apps/backend/ticket-core-service/README.md` 운영 가이드 반영
  - 검증:
    - `bash -n workspace/apps/backend/ticket-core-service/scripts/perf/run-k6-waiting-queue-distributed.sh` PASS
    - `docker-compose -f workspace/apps/backend/ticket-core-service/docker-compose.distributed.yml config` PASS
- 남은 것:
  - 없음
