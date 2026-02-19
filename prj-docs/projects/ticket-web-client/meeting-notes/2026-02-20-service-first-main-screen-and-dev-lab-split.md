# Meeting Notes: Service-first Main Screen and Dev Lab Split (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-20 03:05:00`
> - **Updated At**: `2026-02-20 03:05:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 구현 방향 교정
> - 안건 2: UI 분리 정책
> - 안건 3: 검증 결과
<!-- DOC_TOC_END -->

## 안건 1: 구현 방향 교정
- Status: DONE
- 결정사항:
  - 메인 화면은 서비스 목적(탐색/대기열/구매 진입) 우선으로 구성한다.
  - 테스트/검증 패널은 사용자 기본 화면에서 직접 노출하지 않는다.

## 안건 2: UI 분리 정책
- Status: DONE
- 처리사항:
  - `Queue` 섹션을 서비스 중심(티켓 대기열/지표/액션)으로 전환
  - `Contract/Auth/Realtime` 패널은 Dev Lab으로 분리
  - Dev Lab 노출 조건:
    - `?labs=1`
    - `VITE_APP_DEV_LABS=1`
    - e2e probe(`VITE_E2E_CONSOLE_LOG=1`)

## 안건 3: 검증 결과
- Status: DONE
- 결과:
  - `npm run typecheck` PASS
  - `npm run build` PASS
  - `npm run e2e:all` PASS (5 passed)
