# Task Dashboard (ticket-web-app sidecar)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-24 08:27:00`
> - **Updated At**: `2026-02-25 13:13:00`
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
- [~] TWA-SC-005 사용자 결제복구 UX(지갑/잔액부족 복구) + Admin 정책폼 단순화
- [x] TWA-SC-006 백엔드 기능 채택 매트릭스 문서화(채택/보류/제외 기준)
- [x] TWA-SC-007 기획/설계 문서 재베이스라인(계약 드리프트/갭 명시)
- [~] TWA-SC-008 실사용 예매 플로우 재구성(모달+soft-lock+결제수단 카탈로그 강제)
- [~] TWA-SC-009 옵션별 다중 좌석 상한(`maxSeatsPerOrder`) 채택 + checkout 다중 선택

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

- TWA-SC-005 사용자 결제복구 UX(지갑/잔액부족 복구) + Admin 정책폼 단순화
  - Status: DOING
  - Description:
    - 서비스 화면에 지갑 잔액/충전/최근거래를 추가해 `409 Insufficient wallet balance` 복구 동선을 제공한다.
    - Admin 판매정책 폼을 백엔드 실필드(`maxReservationsPerUser`) 기준으로 단순화한다.
    - 콘서트 목록 파서에 필드 드리프트 대응(`agency*`, `entertainment*`)을 반영한다.
    - `confirm` 응답의 `paymentAction/paymentRedirectUrl`를 파싱해 `확정완료/승인대기/외부결제` 분기 UX를 제공한다.
    - `paymentAction=REDIRECT`일 때 결제창 자동 오픈을 시도하고, 팝업 차단 시 수동 `결제창 열기` 링크로 복구한다.
  - Evidence:
    - `workspace/apps/frontend/ticket-web-app/src/pages/ServicePage.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/shared/api/run-reservation-v7-flow.ts`
    - `workspace/apps/frontend/ticket-web-app/src/shared/api/reservation-v7-client.ts`
    - `workspace/apps/frontend/ticket-web-app/src/shared/api/wallet-client.ts`
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
  - Status: DOING
  - Description:
    - `ServicePage`의 카드 클릭 즉시 자동 예매 체인을 제거하고 checkout modal 진입 흐름으로 변경한다.
    - 좌석 선택 시 soft-lock(`v7/locks`)을 먼저 적용하고, 모달 종료/좌석 변경 시 lock 해제한다.
    - 결제수단은 `GET /api/payments/methods` enabled 항목만 허용하고 fail-open(WALLET 강제 fallback)을 제거한다.
    - checkout modal 좌석 선택 UI를 카드형 타일 + 상태 뱃지 + 선택 강조 스타일로 개선한다.
    - `paymentAction=REDIRECT/WAIT_WEBHOOK/RETRY_CONFIRM` 분기 UX를 완성한다.
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
  - Status: DOING
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

## Next Items
- `TWA-SC-009` OAuth 실사용 경로에서 다중 좌석 선택/soft-lock/결제 결과 집계 수동 검증
- `TWA-SC-008` paymentAction 분기 UX 미완료 구간(WAIT_WEBHOOK/RETRY_CONFIRM) 사용자 안내 고도화
- `TWA-SC-008` checkout modal UI 접근성/모바일 사용성 회귀 점검
- `TWA-SC-003` non-mock smoke 검증 및 실시간 채널 보강
- 백엔드 `GET /api/concerts/search` 500(lower(bytea)) 재현환경 원인 확인 및 안정화
