# Runtime Integration Test Guide

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
> - 실행
> - 기본 포함 테스트
> - 주요 환경변수
> - 산출물
<!-- DOC_TOC_END -->

Redis/Kafka/Postgres 런타임 의존을 포함한 통합 테스트 실행 가이드입니다.

## 실행

```bash
cd workspace/apps/backend/ticket-core-service
make test-integration-runtime
```

## 기본 포함 테스트

- `com.ticketrush.application.concert.service.ConcertExplorerIntegrationTest`
- `com.ticketrush.application.reservation.service.ReservationLifecycleServiceIntegrationTest`
- `com.ticketrush.infrastructure.messaging.KafkaPushEventConsumerTest`

## 주요 환경변수

- `IT_COMPOSE_PROJECT` (기본 `tcsit`)
- `IT_APP_REPLICAS` (기본 `1`)
- `IT_KEEP_ENV=true|false` (기본 `false`)
- `IT_HEALTH_URL` (기본 `http://127.0.0.1:18080/api/concerts`)

## 산출물

- `.codex/tmp/ticket-core-service/integration/latest/runtime-integration-latest.md`
- `.codex/tmp/ticket-core-service/integration/<run-id>/runtime-integration.log`
