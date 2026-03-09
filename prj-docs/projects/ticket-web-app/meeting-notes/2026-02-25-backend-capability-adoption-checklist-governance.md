# Meeting Notes: Backend Capability Adoption Checklist Governance

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-25 03:05:00`
> - **Updated At**: `2026-02-25 03:05:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 문서 필요성 확정
> - 안건 2: 기능 분류 코드 정의
> - 안건 3: 초기 분류 결과
> - 안건 4: 운영 규칙
<!-- DOC_TOC_END -->

## 안건 1: 문서 필요성 확정
- Status: DONE
- 결정:
  - 백엔드에 존재하는 기능을 프론트 구현 대상으로 자동 채택하지 않는다.
  - 백엔드 항목별로 프론트 `채택/보류/제외` 결정을 문서화하고 task와 연결한다.

## 안건 2: 기능 분류 코드 정의
- Status: DONE
- 분류:
  - `ADOPT_NOW`: 현재 스프린트 반영
  - `ADOPT_LATER`: 후속 반영
  - `BACKEND_ONLY`: 사용자 UI 미노출
  - `LEGACY_SKIP`: 신규 프론트 미적용(구버전/호환 경로)

## 안건 3: 초기 분류 결과
- Status: DONE
- 요약:
  - 현재 즉시 채택: v7 예약 흐름, 결제수단 상태, 지갑 복구 UX, confirm 후속 액션 분기
  - 후속 채택: soft lock 고도화, WS 실시간 강화, 감사로그 대시보드
  - 백엔드 전용: PG webhook, OAuth callback 종착점, mock provider, setup/cleanup
- 증빙:
  - `prj-docs/projects/ticket-web-app/product-docs/backend-capability-adoption-checklist.md`

## 안건 4: 운영 규칙
- Status: DONE
- 규칙:
  - 백엔드 컨트롤러/결제/상태머신 변경 시 본 체크리스트를 먼저 갱신한다.
  - `ADOPT_NOW` 항목은 프론트 증빙 파일 + 검증 결과를 task에 함께 기록한다.
  - 분류 변경(`LATER -> NOW`)은 회의록 업데이트를 동반한다.
