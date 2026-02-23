# Incident Response Runbook

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
> - 1) 즉시 점검
> - 2) 1차 복구 절차
> - 3) 데이터/흐름 점검
> - 4) 증빙 규칙
<!-- DOC_TOC_END -->

런타임 장애 발생 시 표준 대응 절차입니다.

## 1) 즉시 점검

```bash
cd workspace/apps/backend/ticket-core-service
make ops-health-check
```

- 산출물: `.codex/tmp/ticket-core-service/ops/latest/runtime-health-check-latest.md`
- API/Redis/Kafka/Postgres 상태를 한 번에 확인합니다.

## 2) 1차 복구 절차

```bash
cd workspace/apps/backend/ticket-core-service
make compose-down
make compose-up APP_REPLICAS=1
```

복구 후 다시 `make ops-health-check`를 실행해 상태를 확인합니다.

## 3) 데이터/흐름 점검

1. 예약 상태 전이 API(`v6/v7`) 스모크 1회 수행
2. 대기열 join + 상태 조회 스모크 1회 수행
3. 지갑 충전/결제/환불 스모크 1회 수행

## 4) 증빙 규칙

- 장애 시점 로그 + 복구 후 건강 상태 리포트 + 재현 스크립트 결과를 남깁니다.
- 제품 이슈 코멘트와 sidecar 회의록에 동일 링크를 기록합니다.
