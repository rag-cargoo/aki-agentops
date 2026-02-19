# Frontend Feature Spec (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 21:12:00`
> - **Updated At**: `2026-02-19 21:12:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Feature Breakdown
> - API Contract Integration
> - Realtime Integration Plan
> - Error/Recovery Strategy
> - Playwright Mapping
<!-- DOC_TOC_END -->

## Scope
- 대상 프로젝트: `workspace/apps/frontend/ticket-web-client`
- 목적: 초기 랜딩/탐색 UI와 API 계약 파서 기반을 고정하고, 이후 기능 확장을 위한 검증 기준을 제공한다.

## Feature Breakdown
1. Layout/Navigate
- 상단 네비게이션(`Home`, `Highlights`, `Gallery`, `Queue`)과 앵커 이동 구조를 제공한다.
- Hero/Highlights/Gallery/Contract Panel 4개 섹션으로 메인 화면을 구성한다.

2. Highlights Grid
- K-POP 영상 썸네일 카드 그리드로 구성한다.
- 외부 링크(`YouTube 보기`) 동작을 제공한다.

3. Gallery Grid
- 포토 월 형태의 카드 레이아웃으로 시각 강조 영역을 구성한다.

4. Contract Panel
- `normalizeApiError` 결과(JSON)
- `parseServerDateTime` 결과(JSON)
- 위 2개를 동시에 노출해 프론트 계약 베이스를 시각 검증 가능하게 유지한다.

## API Contract Integration
- Error Parser:
  - 입력: `{ status, errorCode, message }`
  - 출력: `NormalizedApiError`
  - 비정상 값은 `errorCode: UNKNOWN`로 정규화
- DateTime Parser:
  - `Instant(UTC)`와 `LocalDateTime` 혼재 입력 지원
  - 출력: `{ isoUtc, sourceType, valid }`

## Realtime Integration Plan
- 1차: WebSocket 우선 연결 어댑터
- 2차: WS 실패 시 SSE fallback
- 3차: auth 만료/네트워크 오류 시 재연결(backoff) 및 구독 복구

## Error/Recovery Strategy
- 비정상 API 응답 본문은 공통 에러 파서로 강제 정규화한다.
- 시간 파싱 실패 시 `valid: false`를 UI/로그로 명시해 무음 실패를 차단한다.
- 네트워크/채널 오류는 이벤트 로그로 남기고, UI에 재시도 가능 상태를 노출한다.

## Playwright Mapping
- `@smoke`: 페이지 부팅, 핵심 섹션 노출
- `@nav`: 앵커 이동/내비게이션 동작
- `@contract`: Contract Panel JSON 구조/값 검증 + 콘솔 로그 검증
