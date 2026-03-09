# Ops Observability and Alerting Guide

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-24 04:23:00`
> - **Updated At**: `2026-02-24 04:23:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 1) 모니터 키 표준
> - 2) 수집 명령
> - 3) 권장 경고 임계치(초기값)
> - 4) 운영 루틴
<!-- DOC_TOC_END -->

운영 관측성 기준과 경고 임계치를 정의합니다.

## 1) 모니터 키 표준

- `AUTH_MONITOR`: 인증/세션 예외 코드 집계 로그
- `QUEUE_MONITOR`: 대기열 상태/처리량 로그
- `PUSH_MONITOR`: SSE/WS/Kafka push 경로 로그
- `PUSH_MONITOR_SNAPSHOT`: 주기 집계 스냅샷 로그

## 2) 수집 명령

```bash
cd workspace/apps/backend/ticket-core-service
make ops-monitor-snapshot
```

- 산출물: `.codex/tmp/ticket-core-service/ops/latest/runtime-monitor-snapshot-latest.md`

## 3) 권장 경고 임계치(초기값)

- `AUTH_MONITOR` 5분 오류 비율 > `2%`
- `QUEUE_MONITOR` 대기열 평균 지연 > `3s`
- `PUSH_MONITOR` 실패율 > `1%`
- `PUSH_MONITOR_SNAPSHOT` 집계 누락(연속 2회)

## 4) 운영 루틴

1. 배포 직후 10분 내 모니터 스냅샷 1회 수집
2. 장애/성능 이슈 발생 시 스냅샷을 이슈/회의록 증빙으로 첨부
3. 임계치 변경은 `task.md`와 회의록에 동시 반영
