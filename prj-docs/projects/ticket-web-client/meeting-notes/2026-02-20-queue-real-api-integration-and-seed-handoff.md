# Meeting Notes: Queue Real API Integration and Seed Handoff (ticket-web-client)

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
> - 안건 1: Queue 실 API 연동 완료
> - 안건 2: 로컬 실행/연결 규칙 정리
> - 안건 3: 백엔드 더미 시드 연동 확인
> - 안건 4: 후속 작업
<!-- DOC_TOC_END -->

## 안건 1: Queue 실 API 연동 완료
- Status: DONE
- 처리결과:
  - `Live Ticket Queue` 섹션을 `GET /api/concerts/search` 기반으로 전환했다.
  - `saleStatus`, `saleOpensInSeconds`, `reservationButtonVisible`, `reservationButtonEnabled`를 카드 UI에 직접 반영했다.
  - 카운트다운은 초 단위 라이브 갱신 + 경계(0초) 도달 시 자동 재조회로 처리한다.

## 안건 2: 로컬 실행/연결 규칙 정리
- Status: DONE
- 처리결과:
  - 프론트 `VITE_API_BASE_URL` 기본값을 `/api`로 고정했다.
  - Vite dev server proxy(`/api`, `/ws`)를 추가해 백엔드 `127.0.0.1:8080`에 바로 연결되도록 맞췄다.
  - `.env.example`에 `VITE_API_BASE_URL`, `VITE_DEV_PROXY_TARGET`를 추가했다.

## 안건 3: 백엔드 더미 시드 연동 확인
- Status: DONE
- 처리결과:
  - 백엔드 `APP_PORTFOLIO_SEED_ENABLED=true` 시 샘플 공연이 자동 생성되도록 반영했다.
  - 포트폴리오 시드 데이터는 Queue 화면에서 바로 조회 가능하다.

## 안건 4: 후속 작업
- Status: TODO
- 후속작업:
  - Queue 카드 `예매하기` 버튼을 Reservation v7 hold/confirm 플로우와 연결한다.
  - 결제/세션 만료 오류를 Queue 카드 단위 에러 UX로 분기한다.
