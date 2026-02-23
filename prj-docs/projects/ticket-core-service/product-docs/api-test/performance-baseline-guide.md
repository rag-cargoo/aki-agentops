# Performance Baseline Guide

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
> - 1) 기준선 실행
> - 2) 기본 임계치
> - 3) 산출물
> - 4) 운영 해석
<!-- DOC_TOC_END -->

k6 기준선 실행과 판정 기준을 정의합니다.

## 1) 기준선 실행

```bash
cd workspace/apps/backend/ticket-core-service
make test-k6-baseline
```

## 2) 기본 임계치

- `K6_BASELINE_MAX_P95_MS=1200`
- `K6_BASELINE_MAX_FAIL_RATE=0.02`
- `K6_BASELINE_MIN_CHECKS_RATE=0.98`

필요 시 환경변수로 오버라이드합니다.

## 3) 산출물

- `.codex/tmp/ticket-core-service/k6/latest/k6-latest.md`
- `.codex/tmp/ticket-core-service/k6/latest/k6-summary.json`
- `.codex/tmp/ticket-core-service/k6/latest/k6-baseline-summary.json`
- `.codex/tmp/ticket-core-service/k6/latest/k6-baseline-latest.md`

## 4) 운영 해석

1. 결과가 `FAIL`이면 릴리즈 후보에서 제외
2. 실패 원인은 raw log/summary를 기준으로 회의록과 이슈 코멘트에 기록
3. 임계치 변경은 사전 합의 후 문서/태스크를 동시 갱신
