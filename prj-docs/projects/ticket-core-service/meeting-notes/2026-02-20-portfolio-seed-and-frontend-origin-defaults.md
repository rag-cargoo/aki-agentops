# Meeting Notes: Portfolio Seed and Frontend Origin Defaults (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-20 04:30:00`
> - **Updated At**: `2026-02-20 04:30:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 포트폴리오 더미 시드 토글
> - 안건 2: 프론트 개발 오리진 기본값
> - 안건 3: 문서/가이드 동기화
> - 안건 4: 후속작업
<!-- DOC_TOC_END -->

## 안건 1: 포트폴리오 더미 시드 토글
- Status: DONE
- 결정사항:
  - 기본값은 `APP_PORTFOLIO_SEED_ENABLED=false`로 유지한다.
  - 포트폴리오/데모 실행에서는 `APP_PORTFOLIO_SEED_ENABLED=true`로 샘플 데이터를 자동 생성한다.
  - 시드는 마커 유저(`portfolio_seed_marker_v1`) 기준으로 중복 생성을 방지한다.

## 안건 2: 프론트 개발 오리진 기본값
- Status: DONE
- 처리결과:
  - CORS + WS 기본 허용 오리진에 `5173`, `4173`, `8080`(localhost/127.0.0.1)을 반영했다.
  - 프론트의 Vite dev/preview 및 기존 U1 화면을 동시에 기본 허용 범위에 포함했다.

## 안건 3: 문서/가이드 동기화
- Status: DONE
- 처리결과:
  - API 명세에 포트폴리오 시드 동작과 런타임 플래그를 추가했다.
  - API 테스트 가이드에 시드 스모크 검증 절차를 추가했다.
  - social-auth 명세의 `FRONTEND_ALLOWED_ORIGINS` 기본값을 최신 오리진 세트로 갱신했다.

## 안건 4: 후속작업
- Status: TODO
- 후속작업:
  - 포트폴리오 시드 데이터를 미디어 메타데이터(썸네일/영상 링크) 계약까지 확장한다.
  - 예약 v7 시나리오에서 Queue 카드 `예매하기` end-to-end 흐름을 Playwright로 고정한다.
