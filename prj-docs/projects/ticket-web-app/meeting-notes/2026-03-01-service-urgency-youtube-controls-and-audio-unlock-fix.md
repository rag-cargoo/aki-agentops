# Meeting Notes: Service Urgency YouTube Controls and Audio Unlock Fix (ticket-web-app)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-03-01 09:41:25`
> - **Updated At**: `2026-03-01 09:41:25`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 증상 재확인
> - 안건 2: YouTube 기본 컨트롤 복구
> - 안건 3: 스크롤 이후 재음소거 회귀 수정
> - 안건 4: 오버레이/종료 상태 대응
> - 안건 5: 검증 결과 및 태스크 동기화
<!-- DOC_TOC_END -->

## 안건 1: 증상 재확인
- Status: DONE
- 요약:
  - 오픈 임박 히어로 YouTube iframe에서 기본 플레이/음소거/전체화면 컨트롤이 보이지 않았다.
  - 스크롤로 영상 위치에 진입해 음소거가 해제된 뒤에도, 화면 이동 시 재음소거되는 회귀가 있었다.

## 안건 2: YouTube 기본 컨트롤 복구
- Status: DONE
- 변경:
  - embed query를 `controls=1`, `disablekb=0`, `fs=1`로 조정했다.
  - iframe 상호작용 차단을 유발하던 `pointer-events: none`을 제거했다.
  - 컨트롤 영역을 가리던 상/하단 마스킹 pseudo-element를 제거했다.

## 안건 3: 스크롤 이후 재음소거 회귀 수정
- Status: DONE
- 변경:
  - `openingShouldPlayWithSound`가 true가 된 뒤에는 `isOpeningMediaInView` 변화만으로 다시 mute하지 않도록 조건을 재정렬했다.
  - 사용자 제스처로 오디오 unlock이 성립한 세션에서는 unMute 상태를 유지하도록 정렬했다.

## 안건 4: 오버레이/종료 상태 대응
- Status: DONE
- 변경:
  - YouTube player message(`onStateChange`)에서 `Ended(0)` 감지 시 `seekTo(0)+playVideo`를 즉시 재요청하도록 보강했다.
  - 재생 keep-alive를 통해 종료 후 오버레이 고정 노출 가능성을 낮추도록 보완했다.

## 안건 5: 검증 결과 및 태스크 동기화
- Status: DONE
- 검증:
  - `npm run lint` PASS
  - `npm run typecheck` PASS
  - `npm run build` PASS
  - 사용자 수동 확인: "이제 제대로 되네" 피드백으로 동작 확인
- 연계:
  - task: `prj-docs/projects/ticket-web-app/task.md` (`TWA-SC-013`)
  - 코드 범위:
    - `workspace/apps/frontend/ticket-web-app/src/pages/service/ServiceUrgencyBannerSection.tsx`
    - `workspace/apps/frontend/ticket-web-app/src/styles.css`
