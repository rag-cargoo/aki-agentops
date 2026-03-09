# Meeting Notes: Option maxSeatsPerOrder Multi-Seat Checkout Follow-up (ticket-web-app)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-25 13:12:00`
> - **Updated At**: `2026-02-25 13:12:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 백엔드 선행 계약 수용
> - 안건 2: Admin 옵션 폼 반영
> - 안건 3: checkout 다중 좌석 선택 반영
> - 안건 4: 후속 검증
<!-- DOC_TOC_END -->

## 안건 1: 백엔드 선행 계약 수용
- Status: DONE
- 정렬:
  - 백엔드가 `ConcertOption.maxSeatsPerOrder` 계약을 먼저 고정한 뒤 프론트가 이를 채택한다.
  - 프론트 트래킹 이슈는 기존 `ticket-web-app#3`에 후속 태스크로 누적한다.
  - 연계 이슈:
    - backend: `https://github.com/rag-cargoo/ticket-core-service/issues/20`
    - frontend: `https://github.com/rag-cargoo/ticket-web-app/issues/3`

## 안건 2: Admin 옵션 폼 반영
- Status: DONE
- 적용:
  - Admin 옵션 생성/수정 폼에 `maxSeatsPerOrder` 입력 필드(1~10)를 추가한다.
  - 옵션 목록 테이블에 `Max Seats/Order` 컬럼을 추가한다.
  - 옵션 조회 파서가 `maxSeatsPerOrder`를 읽도록 API 타입을 확장한다.

## 안건 3: checkout 다중 좌석 선택 반영
- Status: DONE
- 적용:
  - 회차별 `maxSeatsPerOrder`를 기준으로 좌석 다중 선택 상한을 강제한다.
  - 좌석 입력을 단일 라디오에서 다중 체크박스로 변경한다.
  - 선택 좌석 수/상한 도달 안내/soft-lock 상태 카운트를 모달에 표시한다.
  - 결제 단계에서 다중 reservation 결과를 집계해 `CONFIRMED/PARTIAL/WAIT_WEBHOOK/REDIRECT/RETRY_CONFIRM`를 처리한다.

## 안건 4: 후속 검증
- Status: DOING
- 남은 확인:
  - OAuth 로그인 상태에서 실제 다중 좌석 선택/홀드/결제 흐름 수동 점검
  - `WAIT_WEBHOOK` 다중 예약 재조회 시 상태 요약 문구/버튼 동작 회귀 확인
  - 모바일 뷰포트에서 다중 선택 UI 조작성 확인
