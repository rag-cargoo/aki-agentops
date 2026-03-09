# Meeting Notes: Reservation v7/me Filter + Multi-Option Setup Alignment (ticket-core-service)

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
> - 안건 2: `v7/me` 조회 계약 확장
> - 안건 3: 선점 단계 정책 가드 보강
> - 안건 4: 더미 데이터 다회차 생성 정렬
> - 안건 5: 검증 및 연계 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 문제 정의
- Status: DONE
- 요약:
  - 프론트 checkout에서 "해당 콘서트-회차의 내 기존 예약"을 직접 조회할 계약이 필요하다.
  - 기존 예약이 상한을 이미 채운 상태에서도 soft-lock 단계 진입이 시도되는 문제가 있었다.
  - 더미 환경에서 회차를 2개 이상 생성해 다회차 시나리오를 반복 검증할 수 있어야 한다.

## 안건 2: `v7/me` 조회 계약 확장
- Status: DONE
- 결정:
  - `GET /api/reservations/v7/me`에 선택 필터를 추가한다.
  - 요청 파라미터:
    - `concertId` (optional)
    - `optionId` (optional)
    - `status` repeated query (optional)
  - 응답은 목록 아이템 단위로 상태/좌석 메타를 포함한다.
    - `status`, `concertId`, `optionId`, `seatNumber`

## 안건 3: 선점 단계 정책 가드 보강
- Status: DONE
- 결정:
  - `SeatSoftLockServiceImpl.acquire`에서 판매정책 검증을 선적용한다.
  - `reservationUserPort.getUser(userId)` + `salesPolicyService.validateHoldRequest(...)` 호출로 상한 위반 요청을 선점 단계에서 차단한다.
  - 좌석 상태가 `AVAILABLE`이 아닌 경우 기존처럼 즉시 차단한다.

## 안건 4: 더미 데이터 다회차 생성 정렬
- Status: DONE
- 결정:
  - `POST /api/concerts/setup` 요청에 `optionCount`를 추가한다.
  - setup 응답에 `OptionCount`, `OptionIDs`를 포함한다.
  - `scripts/api/setup-test-data.sh`에서 `OPTION_COUNT` 환경변수를 받는다(기본 2).
  - `DataInitializer` 기본 시드도 concert당 2회차로 상향한다.

## 안건 5: 검증 및 연계 트래킹
- Status: DONE
- 검증:
  - `./gradlew compileJava compileTestJava --no-daemon` PASS
  - `API_HOST=http://127.0.0.1:18080 OPTION_COUNT=3 bash ./scripts/api/setup-test-data.sh` PASS
    - 응답: `OptionCount=3, OptionIDs=[42, 43, 44]`
  - `curl -sS http://127.0.0.1:18080/api/concerts/41/options` 응답 3건 확인
- 연계:
  - backend issue: `https://github.com/rag-cargoo/ticket-core-service/issues/21`
  - frontend issue: `https://github.com/rag-cargoo/ticket-web-app/issues/3`
