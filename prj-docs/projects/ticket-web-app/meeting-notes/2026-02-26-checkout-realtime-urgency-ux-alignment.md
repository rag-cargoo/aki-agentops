# Meeting Notes: Checkout Realtime and Urgency UX Alignment (ticket-web-app)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-26 23:58:00`
> - **Updated At**: `2026-02-26 23:58:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 회차별 상한 산정 정렬
> - 안건 2: 좌석 타일 상태/색상 실시간 반영
> - 안건 3: 긴급 섹션(오픈/매진 임박) 표시 정리
> - 안건 4: 로그인 모달/에러 중복 노출 완화
> - 안건 5: 이슈/태스크 동기화
<!-- DOC_TOC_END -->

## 안건 1: 회차별 상한 산정 정렬
- Status: DONE
- 요약:
  - checkout 모달에서 다른 회차 HOLD가 현재 회차 상한 계산에 섞이는 체감 문제가 있었다.
  - `existingReservations`를 `selectedOptionId` 기준으로 재스코프하고, `optionId` 누락 시 seat-map 범위 fallback을 적용했다.

## 안건 2: 좌석 타일 상태/색상 실시간 반영
- Status: DONE
- 요약:
  - 홀딩 직후 좌석표의 색상/상태 라벨이 늦게 바뀌어 육안 구분이 어렵다는 피드백이 있었다.
  - HOLD 성공/결제 후 `seat-map + v7/me` 재조회로 반영 시점을 앞당겼다.
  - 진행중 예약 좌석은 타일 톤을 busy로 보정해 상태 가시성을 유지했다.

## 안건 3: 긴급 섹션(오픈/매진 임박) 표시 정리
- Status: DONE
- 요약:
  - 상단 긴급 섹션은 카드 영역을 세로 스택(섹션) + 가로 카드(목록) 구조로 정렬한다.
  - 각 섹션 표시 수는 최대 3건으로 고정한다.
  - 중복 동작 버튼(`오픈 대기만 보기`, `예매 가능만 보기`)은 제거한다.

## 안건 4: 로그인 모달/에러 중복 노출 완화
- Status: DONE
- 요약:
  - `localhost`/`127.0.0.1` 루프백 오리진 차이로 OAuth callback 메시지 전달이 누락되는 케이스를 보완했다.
  - 서비스 화면에서 전역 인증 에러가 있는 경우, 하단 queue 에러 박스 중복 노출을 억제했다.

## 안건 5: 이슈/태스크 동기화
- Status: DONE
- 트래킹:
  - frontend issue: `https://github.com/rag-cargoo/ticket-web-app/issues/3`
  - task: `prj-docs/projects/ticket-web-app/task.md` (`TWA-SC-008`, `TWA-SC-011`)
  - 검증: `npm run lint`, `npm run build` pass
