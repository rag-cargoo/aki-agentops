# Meeting Notes: Service Urgency Video Playback Stabilization and Demo Rebalancer Ops Sync (ticket-web-app)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-03-01 00:55:00`
> - **Updated At**: `2026-03-01 00:55:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 증상 정리
> - 안건 2: 프론트 반영 사항
> - 안건 3: 검증 결과
> - 안건 4: 이슈/태스크 동기화
<!-- DOC_TOC_END -->

## 안건 1: 증상 정리
- Status: DONE
- 요약:
  - 오픈 임박 영상이 스크롤 시점 변화에서 재시작되는 체감 이슈가 있었다.
  - 영상이 화면 진입/이탈 시 자동 음소거 상태가 반복 변경되면서 UX 일관성이 떨어졌다.
  - highlights 응답의 `openingSoon`이 비는 타이밍에는 상단 히어로가 공백으로 표시되는 케이스가 있었다.

## 안건 2: 프론트 반영 사항
- Status: DONE
- 변경:
  - 오픈 임박 히어로 데이터 결정 로직을 보강해, highlights `openingSoon[0]`가 비면 queue 섹션 계산 결과에서 fallback 하도록 반영했다.
  - 오픈 임박 YouTube iframe 제어를 `재생(play)`과 `음소거(mute/unMute)`로 분리해 스크롤 변화 시 영상 재시작이 발생하지 않도록 정렬했다.
  - `wheel/scroll`도 사용자 상호작용으로 감지하고, 한 번 오디오 unlock 조건을 만족하면 같은 세션에서 다시 강제 mute하지 않도록 조정했다.
  - Demo Rebalancer 제어 패널은 환경변수(`VITE_DEMO_REBALANCER_ENABLED`)로 노출을 제어해 운영 코드와 분리했다.

## 안건 3: 검증 결과
- Status: DONE
- 검증:
  - `npm run lint` PASS
  - `npm run typecheck` PASS
  - `npm run build` PASS

## 안건 4: 이슈/태스크 동기화
- Status: DONE
- 연계:
  - task: `prj-docs/projects/ticket-web-app/task.md` (`TWA-SC-013`)
  - issue: `https://github.com/rag-cargoo/ticket-web-app/issues/9` (progress comment update)
  - 코드 범위:
    - `workspace/apps/frontend/ticket-web-app/src/pages/ServicePage.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/pages/service/ServiceUrgencyBannerSection.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/shared/api/demo-rebalancer-client.ts`
    - `workspace/apps/frontend/ticket-web-app/src/styles.css`
