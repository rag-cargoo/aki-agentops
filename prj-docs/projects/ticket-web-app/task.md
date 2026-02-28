# Task Dashboard (ticket-web-app sidecar)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-24 08:27:00`
> - **Updated At**: `2026-03-01 00:55:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Checklist
> - Current Items
> - Next Items
<!-- DOC_TOC_END -->

## Scope
- 이 문서는 `ticket-web-app` 운영 sidecar 태스크를 관리한다.
- 구현 상세 태스크는 제품 레포 이슈/PR에서 관리한다.

## Checklist
- [x] TWA-SC-001 신규 프론트 레포 생성 + sidecar 등록 + active project 전환
- [x] TWA-SC-002 앱 부트스트랩(Vite/React/TS + lint/typecheck/build + CI)
- [~] TWA-SC-003 SC019 이관 Sprint-1(토큰 정책/예약 API 경로/non-mock smoke)
- [x] TWA-SC-004 백엔드 계약 인벤토리/프론트 설계 블루프린트 고정
- [~] TWA-SC-005 사용자 결제복구 UX(카드/결제상태 복구) + Admin 정책폼 단순화
- [x] TWA-SC-006 백엔드 기능 채택 매트릭스 문서화(채택/보류/제외 기준)
- [x] TWA-SC-007 기획/설계 문서 재베이스라인(계약 드리프트/갭 명시)
- [~] TWA-SC-008 실사용 예매 플로우 재구성(모달+soft-lock+결제수단 카탈로그 강제)
- [~] TWA-SC-009 옵션별 다중 좌석 상한(`maxSeatsPerOrder`) 채택 + checkout 다중 선택
- [~] TWA-SC-010 checkout 예약(HOLD) 후 단건/전체 취소 UX + 벌크 취소 연동
- [~] TWA-SC-011 회차 seat-map(전체 상태) 계약 도입 + checkout 선택 가능 좌석 게이트
- [~] TWA-SC-012 카드 단일 결제(가상 테스트카드) 고정 + 월렛/무통장 제거
- [~] TWA-SC-013 서비스 카드 실시간 상태(서버시간 기준) WS 채널 + fallback 계약 도입

## Current Items
- TWA-SC-001 신규 프론트 레포 생성 + sidecar 등록 + active project 전환
  - Status: DONE
  - Description:
    - 신규 제품 레포 `ticket-web-app`을 생성하고 로컬 클론을 `workspace/apps/frontend/ticket-web-app`으로 고정한다.
    - `project-map.yaml`에 새 프로젝트를 등록한다.
    - sidecar 기본 문서(`README`, `PROJECT_AGENT`, `task`, `meeting-notes/README`, `rules/`)를 생성한다.
  - Evidence:
    - `https://github.com/rag-cargoo/ticket-web-app`
    - `workspace/apps/frontend/ticket-web-app`
    - `prj-docs/projects/project-map.yaml`
    - `prj-docs/projects/ticket-web-app/README.md`
    - `prj-docs/projects/ticket-web-app/PROJECT_AGENT.md`
    - `prj-docs/projects/ticket-web-app/task.md`
    - `prj-docs/projects/ticket-web-app/meeting-notes/README.md`
    - `prj-docs/projects/ticket-web-app/rules/architecture.md`

- TWA-SC-002 앱 부트스트랩(Vite/React/TS + lint/typecheck/build + CI)
  - Status: DONE
  - Description:
    - 프론트 앱 런타임 골격(Vite + React + TypeScript)을 구축한다.
    - 최소 품질 게이트(`lint`, `typecheck`, `build`)와 GitHub Actions CI를 연결한다.
    - 개발 기본값(`.env.example`, API base, WS base)을 문서와 함께 고정한다.
  - Evidence:
    - `https://github.com/rag-cargoo/ticket-web-app/issues/1`
    - `workspace/apps/frontend/ticket-web-app/src/App.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/styles.css`
    - `workspace/apps/frontend/ticket-web-app/.github/workflows/ci.yml`
    - `workspace/apps/frontend/ticket-web-app/.env.example`
    - `workspace/apps/frontend/ticket-web-app/README.md`
    - `npm run lint` (pass)
    - `npm run typecheck` (pass)
    - `npm run build` (pass)
    - `http://127.0.0.1:5173/service` (dev route check)

- TWA-SC-003 SC019 이관 Sprint-1(토큰 정책/예약 API 경로/non-mock smoke)
  - Status: DOING
  - Description:
    - 기존 `ticket-web-client`의 SC019 이관 범위를 신규 프로젝트 코드베이스에 적용한다.
    - 서비스 화면 인증 정책을 OAuth 세션 단일화로 고정한다.
    - 예약/취소/환불 API를 백엔드 단건 v7 계약으로 정렬하고 non-mock smoke 검증을 추가한다.

- TWA-SC-004 백엔드 계약 인벤토리/프론트 설계 블루프린트 고정
  - Status: DONE
  - Description:
    - 백엔드 도메인/엔드포인트/상태전이/프로파일 계약을 코드 기준으로 다시 인벤토리화한다.
    - 실응답 드리프트(`agency*` vs `entertainment*`)를 별도 노트로 기록한다.
    - 프론트 구현 순서를 문서로 강제한다(문서 고정 -> 계약 정렬 -> 검증).
  - Evidence:
    - `prj-docs/projects/ticket-web-app/product-docs/backend-contract-inventory.md`
    - `prj-docs/projects/ticket-web-app/product-docs/frontend-implementation-blueprint.md`

- TWA-SC-005 사용자 결제복구 UX(카드/결제상태 복구) + Admin 정책폼 단순화
  - Status: DOING
  - Description:
    - 서비스 화면 결제 상태 복구 동선을 카드 결제 기준으로 정렬한다.
    - Admin 판매정책 폼을 백엔드 실필드(`maxReservationsPerUser`) 기준으로 단순화한다.
    - 콘서트 목록 파서에 필드 드리프트 대응(`agency*`, `entertainment*`)을 반영한다.
    - `confirm` 응답의 `paymentAction/paymentRedirectUrl`를 파싱해 `확정완료/승인대기/외부결제` 분기 UX를 제공한다.
    - `paymentAction=REDIRECT`일 때 결제창 자동 오픈을 시도하고, 팝업 차단 시 수동 `결제창 열기` 링크로 복구한다.
  - Evidence:
    - `workspace/apps/frontend/ticket-web-app/src/pages/ServicePage.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/shared/api/run-reservation-v7-flow.ts`
    - `workspace/apps/frontend/ticket-web-app/src/shared/api/reservation-v7-client.ts`
    - `workspace/apps/frontend/ticket-web-app/src/shared/api/admin-concert-client.ts`
    - `workspace/apps/frontend/ticket-web-app/src/pages/AdminPage.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/styles.css`
    - `npm run lint` (pass)
    - `npm run typecheck` (pass)
    - `npm run build` (pass)

- TWA-SC-006 백엔드 기능 채택 매트릭스 문서화(채택/보류/제외 기준)
  - Status: DONE
  - Description:
    - 백엔드 구현 항목을 프론트 대상에 그대로 반영하지 않고 `ADOPT_NOW/ADOPT_LATER/BACKEND_ONLY/LEGACY_SKIP`로 분류하는 운영 문서를 고정한다.
    - 프론트 구현/검증 시 항목별 상태와 근거 파일을 남기고, 후속 백엔드 변경 시 문서 갱신을 강제한다.
  - Evidence:
    - `prj-docs/projects/ticket-web-app/product-docs/backend-capability-adoption-checklist.md`
    - `prj-docs/projects/ticket-web-app/product-docs/backend-contract-inventory.md`
    - `prj-docs/projects/ticket-web-app/product-docs/frontend-implementation-blueprint.md`

- TWA-SC-007 기획/설계 문서 재베이스라인(계약 드리프트/갭 명시)
  - Status: DONE
  - Description:
    - 백엔드 코드/런타임 계약을 재검증하고 제품 문서 3종을 전면 재작성한다.
    - 기존 문서의 과장된 DONE 표기를 제거하고, 실제 미구현/리스크를 `DOING/TODO/RISK/BLOCKED`로 명시한다.
    - 예매-결제-실시간 흐름의 실서비스 기준 IA(`메인 탐색`, `프로필 기반 계정`, `모달 기반 결제`)를 고정한다.
  - Evidence:
    - `prj-docs/projects/ticket-web-app/product-docs/backend-contract-inventory.md`
    - `prj-docs/projects/ticket-web-app/product-docs/frontend-implementation-blueprint.md`
    - `prj-docs/projects/ticket-web-app/product-docs/backend-capability-adoption-checklist.md`
    - `prj-docs/projects/ticket-web-app/meeting-notes/2026-02-25-frontend-rebuild-contract-rebaseline.md`

- TWA-SC-008 실사용 예매 플로우 재구성(모달+soft-lock+결제수단 카탈로그 강제)
  - Status: DOING (코드 구현 완료, 실사용 회귀 검증 대기)
  - Description:
    - `ServicePage`의 카드 클릭 즉시 자동 예매 체인을 제거하고 checkout modal 진입 흐름으로 변경한다.
    - 좌석 선택 시 soft-lock(`v7/locks`)을 먼저 적용하고, 모달 종료/좌석 변경 시 lock 해제한다.
    - 결제수단은 `GET /api/payments/methods` enabled 항목만 허용하고 fail-open(WALLET 강제 fallback)을 제거한다.
    - checkout modal 좌석 선택 UI를 카드형 타일 + 상태 뱃지 + 선택 강조 스타일로 개선한다.
    - `paymentAction=REDIRECT/WAIT_WEBHOOK/RETRY_CONFIRM` 분기 UX를 완성한다.
  - Progress (2026-02-26 PM update):
    - `ServiceCheckoutModal`에서 회차별 진행중 예약(`HOLD/PAYING`) 기준으로 결제/버튼 상태를 재정렬했다.
    - 홀딩 직후 `seat-map + v7/me`를 즉시 재조회해 타일 상태/색상 반영 지연을 줄였다.
    - `ServiceUrgencyBannerSection`의 중복 CTA 버튼(`오픈 대기만 보기`, `예매 가능만 보기`)을 제거해 필터/탐색 UX 중복을 정리했다.
  - Evidence:
    - `workspace/apps/frontend/ticket-web-app/src/pages/ServicePage.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/pages/service/ServiceCheckoutModal.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/styles.css`
    - `workspace/apps/frontend/ticket-web-app/src/shared/api/run-reservation-v7-flow.ts`
    - `workspace/apps/frontend/ticket-web-app/src/shared/api/payment-methods-client.ts`
    - `workspace/apps/frontend/ticket-web-app/src/shared/realtime/**`
    - `ticket-web-app issue #3 (cross-repo tracking)`
    - `prj-docs/projects/ticket-web-app/meeting-notes/2026-02-25-checkout-modal-seat-ux-polish.md`

- TWA-SC-009 옵션별 다중 좌석 상한(`maxSeatsPerOrder`) 채택 + checkout 다중 선택
  - Status: DOING (코드 구현 완료, 실사용 회귀 검증 대기)
  - Description:
    - 백엔드 `ConcertOption.maxSeatsPerOrder` 계약을 프론트 API 모델에 반영한다.
    - Admin Option CRUD에서 `maxSeatsPerOrder`를 입력/조회 가능하게 확장한다.
    - checkout modal 좌석 선택을 단일 선택에서 다중 선택으로 확장하고, 옵션 상한값을 UI에서 강제한다.
    - 결제 결과는 다중 reservation 집계 기준으로 `CONFIRMED/PARTIAL/WAIT_WEBHOOK/REDIRECT/RETRY_CONFIRM`를 처리한다.
  - Evidence:
    - `workspace/apps/frontend/ticket-web-app/src/shared/api/admin-concert-client.ts`
    - `workspace/apps/frontend/ticket-web-app/src/pages/AdminPage.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/shared/api/run-reservation-v7-flow.ts`
    - `workspace/apps/frontend/ticket-web-app/src/pages/service/ServiceCheckoutModal.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/pages/ServicePage.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/styles.css`
    - `prj-docs/projects/ticket-web-app/meeting-notes/2026-02-25-option-max-seats-multiselect-checkout-followup.md`
    - `ticket-web-app issue #3` (in progress)

- TWA-SC-010 checkout 예약(HOLD) 후 단건/전체 취소 UX + 벌크 취소 연동
  - Status: DOING (코드 구현 완료, 실사용 회귀 검증 대기)
  - Description:
    - checkout 모달에서 HOLD 생성 후에도 좌석 단건 취소(`X`)를 지원한다.
    - `전체 취소`는 벌크 API를 우선 호출해 다중 HOLD 해제를 1회 요청으로 처리한다.
    - 취소 후 결제창 상태/좌석 리스트/선택 좌석 테이블을 즉시 동기화한다.
  - Progress (2026-02-25):
    - `ServiceCheckoutModal`:
      - HOLD 이후 단건 취소(`X`)에서 `POST /api/reservations/v7/{reservationId}/cancel` 연동
      - HOLD 이후 전체 취소에서 `POST /api/reservations/v7/cancel/bulk` 우선 연동(1건은 단건 cancel fallback)
      - 취소 후 `holdRecords`, `selectedSeatIds`, 결제 시트(`paymentSheetOpen`) 상태 동기화
      - 좌석 상태 라벨을 예약 상태(`HOLD/PAYING/CONFIRMED/...`) 기준으로 분기
    - API client:
      - `cancelReservationV7`, `cancelReservationsBulkV7` 함수 추가 및 응답 정합성 검증
  - Evidence:
    - `workspace/apps/frontend/ticket-web-app/src/pages/service/ServiceCheckoutModal.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/shared/api/run-reservation-v7-flow.ts`
    - `prj-docs/projects/ticket-web-app/meeting-notes/2026-02-25-checkout-hold-cancel-ux-followup.md`
    - `prj-docs/projects/ticket-web-app/meeting-notes/README.md` (sidecar tracking)
    - `npm run build` (pass)

- TWA-SC-011 회차 seat-map(전체 상태) 계약 도입 + checkout 선택 가능 좌석 게이트
  - Status: DOING (코드 구현 완료, 실사용 회귀 검증 대기)
  - Description:
    - backend에 회차 좌석 전체 상태 조회 API(`seat-map`)를 추가하고 `status` 필터를 선택 지원한다.
    - 기존 `AVAILABLE` 중심 API는 하위 호환으로 유지한다.
    - checkout 모달은 seat-map 기준으로 렌더링하고 `AVAILABLE` 이외 좌석(`TEMP_RESERVED/RESERVED`)은 선택 비활성 처리한다.
    - 예약(HOLD) 이후 좌석 목록/상태 라벨이 유지되도록 프론트 상태 동기화를 고정한다.
    - `GET /api/reservations/v7/me`를 회차(concertId+optionId+status) 범위로 조회해 기존 예약 목록을 모달에 노출한다.
    - 기존 예약 수를 `maxSeatsPerOrder`에 반영해 잔여 선택 가능 좌석 수를 계산하고 선점 단계에서 차단한다.
  - Progress (2026-02-26):
    - `ServiceCheckoutModal`:
      - `existingReservations` 상태 추가 및 회차 전환/예약 이후 재조회 동기화
      - "해당 회차 내 기존 예약" 테이블 추가(예약번호/좌석/상태)
      - `remainingSelectableSeats = maxSeatsPerOrder - existingActiveReservations.length` 계산으로 선택 상한 재정렬
      - 기존 예약 좌석/비가용 좌석(`TEMP_RESERVED/RESERVED`) 타일 비활성화
    - API client:
      - `fetchMyReservationsV7(apiBaseUrl, accessToken, { concertId, optionId, statuses })` 필터 입력 지원
      - `ReservationSummary`에 `status/concertId/optionId/seatNumber` 파싱 추가
    - Runtime validation:
      - `API_HOST=http://127.0.0.1:18080 OPTION_COUNT=3 bash ./scripts/api/setup-test-data.sh` 실행
      - 응답 `OptionCount=3, OptionIDs=[42, 43, 44]` 확인
      - `GET /api/concerts/41/options`에서 3개 회차 응답 확인
  - Progress (2026-02-26 PM update):
    - `existingReservations` 집계를 `selectedOptionId` 범위로 재스코프해 "다른 회차 HOLD가 현재 회차 상한에 섞이는 문제"를 완화했다.
    - 백엔드 응답에 `optionId` 누락이 있어도 seat-map 범위 기반 fallback 필터를 적용했다.
    - 회차 전환 차단 조건에서 임시 로컬 상태 의존을 제거해 다회차 이동/선점 시나리오를 복구했다.
  - Evidence:
    - `prj-docs/projects/ticket-web-app/meeting-notes/2026-02-26-seat-map-status-contract-alignment.md`
    - `prj-docs/projects/ticket-web-app/meeting-notes/2026-02-26-checkout-existing-reservations-per-option-alignment.md`
    - `prj-docs/projects/ticket-web-app/meeting-notes/2026-02-26-checkout-realtime-urgency-ux-alignment.md`
    - `workspace/apps/frontend/ticket-web-app/src/pages/service/ServiceCheckoutModal.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/shared/api/reservation-v7-client.ts`
    - `npm run build` (pass)

- TWA-SC-012 카드 단일 결제(가상 테스트카드) 고정 + 월렛/무통장 제거
  - Status: DOING (코드 구현 완료, 실사용 회귀 검증 대기)
  - Description:
    - checkout 결제 단계를 카드 단일 흐름으로 고정하고, 사용자에게 가상 테스트카드 선택 UI를 제공한다.
    - 프론트 결제수단 타입에서 `WALLET/BANK_TRANSFER`를 제거하고 기본 fallback을 `CARD`로 통일한다.
    - 계정 화면의 지갑 원장/잔액 UX를 제거하고 `내 예약/결제` 단일 진입으로 정리한다.
  - Progress (2026-02-26):
    - `ServiceCheckoutModal`:
      - 결제시트에 `가상 테스트 카드 선택` 패널 추가
      - 테스트카드 미선택 시 결제확정 비활성
      - 결제 성공 메시지에 선택 카드 번호(마스킹) 표시
    - `AccountPage/HeaderNav`:
      - `/account/wallet` 흐름 제거 및 `내 예약/결제`로 단일화
      - `ServiceWalletSection`, `wallet-client` 삭제
    - API client:
      - `PaymentMethod` 타입에서 `WALLET/BANK_TRANSFER` 제거
      - 결제수단/예약 플로우 fallback을 `CARD`로 고정
  - Evidence:
    - `workspace/apps/frontend/ticket-web-app/src/pages/service/ServiceCheckoutModal.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/pages/AccountPage.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/components/HeaderNav.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/shared/api/payment-methods-client.ts`
    - `workspace/apps/frontend/ticket-web-app/src/shared/api/run-reservation-v7-flow.ts`
    - `prj-docs/projects/ticket-web-app/meeting-notes/2026-02-26-card-only-checkout-and-wallet-removal-alignment.md`
    - `ticket-web-app issue #3` (comment update)
    - `npm run lint` (pass)
    - `npm run typecheck` (pass)
    - `npm run build` (pass)

- TWA-SC-013 서비스 카드 실시간 상태(서버시간 기준) WS 채널 + fallback 계약 도입
  - Status: DOING
  - Description:
    - 서비스 카드의 `오픈 남은시간/오픈 카운트다운/오픈 시점 상태`를 서버시간 기준으로 계산/전달하도록 백엔드 실시간 채널을 확장한다.
    - 카드 payload에 `serverNow`를 포함해 클라이언트 시간 오차로 인한 표시 불일치를 제거한다.
    - 멀티 인스턴스 환경에서 Redis/Kafka 전파 + 분산락 기반 스케줄링으로 동일 이벤트를 브로드캐스트한다.
    - 프론트는 초기 스냅샷 HTTP + WS 실시간 + 장애 시 저주기 poll fallback 계약으로 정렬한다.
    - 모드 정책은 `websocket(default)`, `hybrid(optional)`, `polling(emergency)`로 고정한다.
  - Progress (2026-02-28):
    - 런타임 점검 결과, 현재 카드는 `CONCERTS_REFRESH` 중심이며 오픈 카운트다운/상태 전환 실시간 발행은 미구현임을 확인했다.
    - WS 실수신(`CONNECTED`, `MESSAGE`) 및 Redis 대기열 키 증빙은 완료했고, 카드 시간 상태 채널 확장이 후속 핵심 범위로 확정됐다.
  - Progress (2026-02-28 backend update):
    - `GET /api/concerts/search` 응답에 실시간 카드 필드(`saleStatus`, `saleOpensAt`, `saleOpensInSeconds`, `reservationButton*`, `seat count`, `serverNow`)를 추가했다.
    - `ConcertSaleStatusScheduler`를 도입해 판매 상태 전환 감지 시 `/topic/concerts/live` refresh 이벤트를 발행하도록 반영했다.
    - 런타임 시나리오에서 `OPEN_SOON_5M -> OPEN` 전환과 WS `CONCERTS_REFRESH` 수신을 확인했다.
  - Progress (2026-02-28 backend update-2):
    - `/topic/concerts/live` `CONCERTS_REFRESH` payload에 카드 전체 `items` + `realtimeMode` + `hybridPollIntervalMillis` + `serverNow`를 포함하도록 확장했다.
    - ArchUnit 경계 준수를 위해 `ConcertCardRuntimeUseCase`(application inbound port) 경유로 controller/global `application..service` 직참조를 제거했다.
    - `ConcertExplorerIntegrationTest`, `WebSocketPushNotifierTest`, `LayerDependencyArchTest`를 통과했다.
  - Progress (2026-03-01 frontend update):
    - highlights `openingSoon`가 비는 경우 queue 섹션 계산값으로 오픈 임박 히어로를 fallback 하도록 보강했다.
    - 오픈 임박 영상 재생 제어를 `play`와 `mute/unMute`로 분리해 스크롤 중 영상 재시작 체감 이슈를 완화했다.
    - 사용자 상호작용 감지 범위를 `wheel/scroll`까지 확장하고, 한 번 오디오 unlock 조건을 만족하면 세션 내 재음소거를 방지하도록 정렬했다.
    - Demo Rebalancer UI를 env flag(`VITE_DEMO_REBALANCER_ENABLED`)로 게이트해 운영환경 기본 비노출을 유지했다.
  - Execution Checklist (2026-02-28 reconfirm):
    - [x] backend: 검색 응답 실시간 카드 필드 + `serverNow` 반영
    - [x] backend: 검색 응답 `realtimeMode`, `hybridPollIntervalMillis` 반영
    - [x] backend: 판매 상태 전환 감지 스케줄러 + 분산락 반영
    - [x] backend: 전환 이벤트 WS refresh 발행 검증
    - [x] backend: WS refresh payload에 카드 `items` 직접 포함(WS 수신만으로 카드 갱신 가능)
    - [x] backend: ArchUnit 경계 규칙(`global/api -> application port`) 준수
    - [ ] frontend: `websocket` 모드에서 상시 30초 polling 제거
    - [ ] frontend: `hybrid` 모드에서만 저주기 polling 동작 보장
    - [ ] frontend: 모드값(백엔드 설정) 기반 자동 전환 반영
    - [ ] frontend: 모드별 네트워크/실시간 증빙 수집
  - Evidence:
    - `prj-docs/projects/ticket-web-app/meeting-notes/2026-02-28-service-card-server-time-realtime-ws-alignment.md`
    - `prj-docs/projects/ticket-web-app/meeting-notes/2026-03-01-service-urgency-video-playback-and-demo-rebalancer-ops-sync.md`
    - `ticket-core-service issue #3` (reopened/comment update)
    - `ticket-web-app issue #9` (comment update)
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/global/push/WebSocketPushNotifier.java`
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/application/concert/port/inbound/ConcertCardRuntimeUseCase.java`
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/application/concert/model/ConcertLiveCardPayload.java`
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/application/concert/service/ConcertCardRuntimeService.java`
    - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/global/scheduler/ConcertSaleStatusScheduler.java`
    - `workspace/apps/frontend/ticket-web-app/src/pages/ServicePage.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/pages/service/ServiceUrgencyBannerSection.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/shared/api/demo-rebalancer-client.ts`
    - `workspace/apps/frontend/ticket-web-app/src/styles.css`
    - `workspace/apps/backend/ticket-core-service/src/test/java/com/ticketrush/application/concert/service/ConcertExplorerIntegrationTest.java`
    - `workspace/apps/backend/ticket-core-service/src/test/java/com/ticketrush/global/push/WebSocketPushNotifierTest.java`
    - `npm run lint` (pass)
    - `npm run typecheck` (pass)
    - `npm run build` (pass)

## Next Items
- 아래 항목은 신규 구현 + OAuth 실사용 계정 기준 수동 회귀/운영 검증을 함께 포함한다.
- `TWA-SC-013` 프론트 서비스 카드 모드 분기(`websocket` 기본, `hybrid` 선택, `polling` 비상) 반영
- `TWA-SC-013` `websocket` 모드 상시 polling 제거 + `hybrid` 모드 저주기 보정 폴링 제한
- `TWA-SC-013` 프론트 `serverNow` 기준 카운트다운 보정 및 모드별 증빙 수집
- `TWA-SC-012` OAuth 실사용 계정 기준 카드 단일 결제 + 가상 테스트카드 선택 UX 수동 회귀 검증
- `TWA-SC-011` OAuth 실사용 계정으로 회차별 기존 예약 테이블/선택 상한(기존 예약 포함) 수동 회귀 확인
- `TWA-SC-010` HOLD 취소 단건/전체 UX 최종 문구 점검 + 모바일 회귀 확인
- `TWA-SC-009` OAuth 실사용 경로에서 다중 좌석 선택/soft-lock/결제 결과 집계 수동 검증
- `TWA-SC-008` paymentAction 분기 UX 미완료 구간(WAIT_WEBHOOK/RETRY_CONFIRM) 사용자 안내 고도화
- `TWA-SC-008` checkout modal UI 접근성/모바일 사용성 회귀 점검
- `TWA-SC-003` non-mock smoke 검증 및 실시간 채널 보강
- 백엔드 `GET /api/concerts/search` 500(lower(bytea)) 재현환경 원인 확인 및 안정화
