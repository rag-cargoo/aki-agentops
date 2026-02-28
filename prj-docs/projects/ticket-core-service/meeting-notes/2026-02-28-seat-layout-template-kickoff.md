# 2026-02-28 Seat Layout Template Kickoff

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-28 13:28:30`
> - **Updated At**: `2026-02-28 13:28:30`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Summary
> - Scope
> - Decisions
> - Next Steps
<!-- DOC_TOC_END -->

## Summary
- 좌석 생성이 `seatCount` -> `A-1..A-N` 하드코딩인 구조를 실서비스형 좌석 템플릿 모델로 전환하기로 결정했다.
- 정렬 기준을 문자열 기반에서 구역/열/번호 기반 natural sort로 전환해 `A-1, A-10, A-2` 문제를 제거한다.
- 하위호환을 위해 기존 `seatCount` 입력 경로는 유지하고, 신규 `seatLayout` 입력을 병행 지원한다.

## Scope
- Product Issue: `rag-cargoo/ticket-core-service#57`
- New Branch: `feat/issue-57-seat-layout-template`
- 포함 범위:
  - 옵션 생성 API 확장(`seatLayout` 입력)
  - 좌석 도메인/조회 정렬 계약 보강
  - seed/setup 스크립트 존 기반 시나리오 추가
- 제외 범위:
  - 프론트 좌석맵 대규모 UI 리디자인
  - 외부 티켓팅 엔진 연동

## Decisions
1. API는 `seatCount`(legacy) + `seatLayout`(new)를 동시에 허용한다.
2. `seatLayout`이 들어오면 템플릿 우선으로 좌석을 생성하고, 없으면 기존 `A-*` fallback을 유지한다.
3. seat-map 응답 정렬은 백엔드에서 natural sort를 보장한다.
4. cross-repo 링크는 doc-state-sync 정책에 따라 URL 대신 shorthand(`owner/repo#num`)로 표기한다.

## Next Steps
1. 백엔드 브랜치에서 설계/마이그레이션 초안 반영
2. 단위/통합 테스트 케이스 추가(정렬/하위호환 포함)
3. 구현 완료 후 sidecar task와 product issue 진행상태 동기화
