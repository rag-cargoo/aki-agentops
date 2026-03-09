# Meeting Notes: Demo Rebalancer Hourly Cron + Startup Trigger Fix

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-03-02 02:52:00`
> - **Updated At**: `2026-03-02 02:52:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 원인 확인
> - 안건 2: 자동 실행 정책 반영
> - 안건 3: 설정/배포 반영
> - 안건 4: 검증 결과
> - 안건 5: 정리 범위
<!-- DOC_TOC_END -->

## 안건 1: 원인 확인
- Status: DONE
- 요약:
  - 리밸런서의 `defaultIntervalMinutes=60`은 상태 조회용 값이며, 서버 자동실행 스케줄과 연결되어 있지 않았다.
  - 백엔드 `DemoRebalancerService`에는 자동실행 `@Scheduled` 메서드가 없어, 수동 `NOW` 버튼 API 호출 시에만 실행됐다.

## 안건 2: 자동 실행 정책 반영
- Status: DONE
- 정책:
  - `매시 00분` 자동 실행
  - `서버 시작 후 60초 이내 1회` 자동 실행(기본 30초)
- 변경:
  - `@Scheduled(cron = "0 0 * * * *", zone = "Asia/Seoul")` 기반 시간 고정 실행 추가
  - `@EventListener(ApplicationReadyEvent.class)` 기반 startup 1회 트리거 추가
  - 동시 실행 경합 방지를 위해 `compareAndSet` 가드 유지

## 안건 3: 설정/배포 반영
- Status: DONE
- 설정 키:
  - `APP_DEMO_REBALANCER_CRON` (default: `0 0 * * * *`)
  - `APP_DEMO_REBALANCER_CRON_ZONE` (default: `Asia/Seoul`)
  - `APP_DEMO_REBALANCER_STARTUP_TRIGGER_ENABLED` (default: `true`)
  - `APP_DEMO_REBALANCER_STARTUP_TRIGGER_DELAY_MILLIS` (default: `30000`)
- 운영 배포:
  - backend image tag: `20260302024451`
  - backend digest: `sha256:add4f9883ff216620225a74eb4b7a5c8835eb299da6f70de5d4d048c41742746`

## 안건 4: 검증 결과
- Status: DONE
- 검증:
  - `/api/dev/demo/rebalancer/status`에서 startup 1회 실행 이력 확인
    - startedAt: `2026-03-01T17:49:17.049335199Z`
    - finishedAt: `2026-03-01T17:49:20.837786569Z`
  - 수동 `POST /api/dev/demo/rebalancer/run` 경로는 기존처럼 정상 유지

## 안건 5: 정리 범위
- Status: DONE
- 커밋/반영:
  - `ticket-core-service`: `feat(demo-rebalancer): run at top of hour and trigger once after startup`
  - `ticket-web-app`: `fix(service): stabilize opening video controls and audio unlock`
  - `ticket-rush-deploy`: `chore(deploy): wire oauth runtime envs into aws compose deploy`
