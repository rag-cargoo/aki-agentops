# Meeting Notes: Checkout Existing Reservations Per Option Alignment (ticket-web-app)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-26 04:08:00`
> - **Updated At**: `2026-02-26 04:08:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 문제 정의
> - 안건 2: 조회 계약 정렬
> - 안건 3: 선택 상한/선점 UX 정렬
> - 안건 4: 다회차 더미 검증
> - 안건 5: 이슈/태스크 동기화
<!-- DOC_TOC_END -->

## 안건 1: 문제 정의
- Status: DONE
- 요약:
  - 사용자 입장에서는 "같은 콘서트/회차의 기존 예약"이 모달에서 즉시 보여야 한다.
  - 기존 예약이 이미 상한을 채운 경우에도 프론트가 이를 모르고 추가 선점을 시도하는 문제가 있었다.

## 안건 2: 조회 계약 정렬
- Status: DONE
- 결정:
  - 프론트는 `GET /api/reservations/v7/me`를 회차 범위로 호출한다.
  - 요청 파라미터:
    - `concertId`
    - `optionId`
    - `status=HOLD|PAYING|CONFIRMED` (repeated query)
  - API client(`fetchMyReservationsV7`)는 필터 입력/응답 파싱을 확장한다.

## 안건 3: 선택 상한/선점 UX 정렬
- Status: DONE
- 결정:
  - 기존 예약 목록을 테이블로 노출한다(예약번호/좌석/상태).
  - 선택 상한 계산식:
    - `remainingSelectableSeats = maxSeatsPerOrder - existingActiveReservations.length`
  - 잔여 좌석이 0이면 선택 단계에서 즉시 차단하고 안내문구를 노출한다.
  - 기존 예약 좌석 및 비가용 좌석(`TEMP_RESERVED/RESERVED`)은 선택 비활성 처리한다.

## 안건 4: 다회차 더미 검증
- Status: DONE
- 결과:
  - `API_HOST=http://127.0.0.1:18080 OPTION_COUNT=3 bash ./scripts/api/setup-test-data.sh`
  - 응답: `OptionCount=3, OptionIDs=[42, 43, 44]`
  - `GET /api/concerts/41/options`에서 3개 회차 응답 확인

## 안건 5: 이슈/태스크 동기화
- Status: DOING
- 트래킹:
  - frontend issue: `https://github.com/rag-cargoo/ticket-web-app/issues/3`
  - backend issue: `https://github.com/rag-cargoo/ticket-core-service/issues/21`
  - task:
    - `prj-docs/projects/ticket-web-app/task.md` `TWA-SC-011`
    - `prj-docs/projects/ticket-core-service/task.md` `TCS-SC-030`
