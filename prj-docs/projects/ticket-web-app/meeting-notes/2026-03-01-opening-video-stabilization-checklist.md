# 2026-03-01 Opening Video Stabilization Checklist

## Scope
- [CRITICAL GATE] 모든 검증은 `viewport width > 2500px`(예: `2560x1440`, `3000x1440`, `3440x1440`)에서 먼저 통과해야 한다.
- 대상: `/service` 페이지 `오늘 오픈 임박` YouTube 재생 영역
- 제외: 리밸런서 로직(데이터 갱신), OAuth 로그인

## Acceptance Criteria
- [x] YouTube 기본 컨트롤 아이콘(재생/음소거/진행바/전체화면)이 보인다.
- [x] 강제 새로고침/일반 새로고침 이후에도 영상 자동재생 요청이 유지된다.
- [x] 스크롤로 영상 영역 진입 후 사용자 제스처(휠/클릭/터치/키입력) 시 음소거 해제가 동작한다.
- [x] 커스텀 버튼/링크(`재생/일시정지`, `유튜브에서 영상 열기`, 커스텀 음소거 버튼)가 제거된다.
- [x] 강제 재생 루프(하트비트 `setInterval`/`loop=1` + `playlist`) 없이 동작한다.
- [x] 영상 클릭 후 YouTube frame 내부에서 `More videos/동영상 더보기`가 노출되지 않는다.

## Execution Log
- [x] 체크리스트 생성.
- [x] 1차 영상 제어 로직 반영 및 배포.
- [x] 사용자 피드백 기반 2차 재구성 완료(기본 컨트롤 복원 + 커스텀 제어 제거 + 강제 루프 제거).
- [x] 3차 수정 완료(`More videos/동영상 더보기` 재현 후 차단 로직 반영).
- [x] 4차 수정 완료(`>1980 게이트` + 유튜브 기본 컨트롤 노출/클릭 가능 + `More videos` 재검증).
- [x] 5차 수정 완료(중앙 클릭만 차단 + 하단 유튜브 컨트롤 영역 유지, `>1980` 반복 검증 통과).
- [x] 6차 수정 완료(`>2500` 게이트로 상향 + `Ctrl+F5`/하단 컨트롤 클릭 재검증).
- [x] 7차 수정 완료(`>2500` 고정 검증 기준에서 중앙 클릭 pause overlay 차단 + 하단 유튜브 컨트롤 유지).
- [x] 빌드/배포 완료(최종 태그 반영).
- [x] 자동 검증 증적 기록(2500 초과 뷰포트 고정 / `Ctrl+F5` / 클릭 / 프레임 텍스트 / 네트워크 포함).

## Evidence
- 검증 명령/출력은 이 문서 하단에 업데이트.

### 2026-03-02 01:42 KST - 7차 재작업(현재 운영 반영본, >2500 강제 게이트)
- 코드 변경
  - `workspace/apps/frontend/ticket-web-app/src/pages/service/ServiceUrgencyBannerSection.tsx`
  - `workspace/apps/frontend/ticket-web-app/src/styles.css`

- 핵심 변경
  - 중앙 영역 클릭 차단 실드 재도입:
    - `.service-opening-interaction-shield { inset: 0 0 92px 0; }`
    - 목적: 영상 본문 클릭으로 player가 `paused-mode`로 전환되며 `동영상 더보기/More videos`가 노출되는 경로 차단
  - 하단 유튜브 컨트롤 바는 차단 제외:
    - 목적: 유튜브 기본 재생/음소거/진행바/전체화면 컨트롤은 유지
  - 실드 클릭 시 제스처 언락 처리:
    - `setIsOpeningAudioUnlocked(true)` + `syncOpeningPlayerState(... withSound: true)`

- 빌드
  - 명령: `npm run build`
  - 결과: `pass`

- 이미지 빌드/푸시
  - 이미지: `966543711258.dkr.ecr.ap-northeast-2.amazonaws.com/ticketrush/frontend:20260302013619`
  - digest: `sha256:2938500d2e0ecd4da15272a27559ef4c8b89a3529390e215769029b6e0df7886`

- AWS 반영
  - 대상 인스턴스: `i-04f003f8cf4c65b44`
  - `/opt/ticket-rush/.env` 반영값: `FRONTEND_IMAGE_TAG=20260302013619`
  - compose 상태: `ticket-rush-frontend` 재생성 후 `Up`

- 실서비스 자동검증(2500 초과 뷰포트 고정)
  - 명령:
    - `cd tmp-playwright && npx playwright test opening-video-ctrlf5-2500plus-recheck.spec.js --reporter=line --workers=1`
    - `cd tmp-playwright && node opening-video-audio-unlock-3000-probe.js`
  - 결과:
    - `1 passed (34.1s)`
    - audio unlock probe:
      - before: `muteLabel='음소거 해제(m)'`(muted)
      - after wheel gesture: `muteLabel='음소거(m)'`(unmuted)
  - 핵심 수치(모든 케이스: `2560/3000/3440 x before/after ctrl+f5`)
    - `moreVideosVisible=0`
    - `pauseOverlayVisible=false`
    - `visibleControlCount=4`
    - `hasPlayButton=true`, `hasMuteButton=true`, `hasFullscreenButton=true`

### 2026-03-02 00:50 KST - 4차 재작업(현재 운영 반영본, CRITICAL GATE 적용)
- 코드 변경
  - `workspace/apps/frontend/ticket-web-app/src/pages/service/ServiceUrgencyBannerSection.tsx`
  - `workspace/apps/frontend/ticket-web-app/src/styles.css`

- 핵심 변경
  - 유튜브 기본 컨트롤 노출/상호작용 복구:
    - iframe `pointer-events: auto` (클릭 가능)
    - embed query는 `controls=1`, `fs=1`, `disablekb=0` 유지
  - `More videos/동영상 더보기` 재노출 완화:
    - `onStateChange=2(paused)` 시 다회 재생 복구 시퀀스 적용(`[0,120,320,700,1200]ms`)
    - 종료(`onStateChange=0`) 시 `seekTo(0)` + 재생 복구
  - 인뷰 게이트 완화 유지(`intersectionRatio >= 0.02`)로 대형 뷰포트에서 오탐지 pause 감소

- 빌드
  - 명령: `npm run build`
  - 결과: `pass`

- 이미지 빌드/푸시
  - 이미지: `966543711258.dkr.ecr.ap-northeast-2.amazonaws.com/ticketrush/frontend:20260302004731`
  - digest: `sha256:b55812cc1a7cce50c6014d27e73cda4fba44d0cf5500a5579a3893f4dfd02ac7`

- AWS 반영
  - 대상 인스턴스: `i-04f003f8cf4c65b44`
  - `/opt/ticket-rush/.env` 반영값: `FRONTEND_IMAGE_TAG=20260302004731`
  - compose 상태: `ticket-rush-frontend` 재생성 후 `Up`

- 실서비스 자동검증(1980 초과 뷰포트 고정)
  - 명령:
    - `npx playwright test tmp-playwright/opening-video-2kplus-strict.spec.js --reporter=line --workers=1`
  - 결과:
    - `>1980 strict checks` -> `1 passed (37.0s)`
  - 핵심 수치:
    - viewport: `2560x1440` 고정
    - 5회 사이클(`soft-1/2`, `hard-1/2/3`) 전부
      - `pointerEvents=auto`
      - `controls=1`
      - `moreVideos=false`
      - `mediaRequests>0` (7~10)

### 2026-03-02 01:07 KST - 5차 재작업(현재 운영 반영본)
- 코드 변경
  - `workspace/apps/frontend/ticket-web-app/src/pages/service/ServiceUrgencyBannerSection.tsx`
  - `workspace/apps/frontend/ticket-web-app/src/styles.css`

- 핵심 변경
  - 중앙 영상 영역 클릭만 차단하는 투명 실드 추가:
    - `.service-opening-interaction-shield { inset: 0 0 56px 0; }`
    - 목적: 중앙 클릭으로 발생하는 `More videos/동영상 더보기` 트리거 방지
  - 하단 56px 유튜브 컨트롤 바는 실드 제외:
    - 목적: 유튜브 기본 재생/음소거/진행바/전체화면 버튼은 계속 사용 가능
  - pause 상태 복구 시퀀스 유지:
    - `onStateChange=2` 시 `[0,120,320,700,1200]ms` 재생 동기화

- 빌드
  - 명령: `npm run build`
  - 결과: `pass`

- 이미지 빌드/푸시
  - 이미지: `966543711258.dkr.ecr.ap-northeast-2.amazonaws.com/ticketrush/frontend:20260302010428`
  - digest: `sha256:7fe5e80adb9ffff548913d8edb55c08d6f2ba737159eca7cf3beb551e22f66ad`

- AWS 반영
  - `/opt/ticket-rush/.env` 반영값: `FRONTEND_IMAGE_TAG=20260302010428`
  - compose 상태: `ticket-rush-frontend` 재생성 후 `Up`

- 실서비스 자동검증(1980 초과 뷰포트 고정)
  - 명령:
    - `npx playwright test tmp-playwright/opening-video-2kplus-final.spec.js --reporter=line --workers=1`
  - 결과:
    - `>1980 gate: no more-videos + youtube controls clickable` -> `1 passed (38.8s)`
  - 핵심 수치(2560x1440, 5회 반복):
    - `pointerEvents=auto`
    - `controls=1`
    - `moreVideos=false` 전부
    - `mediaRequests>0` 전부(9~11)

### 2026-03-02 01:16 KST - 6차 재작업(현재 운영 반영본, >2500 강제 게이트)
- 코드 변경
  - `workspace/apps/frontend/ticket-web-app/src/pages/service/ServiceUrgencyBannerSection.tsx`
  - `workspace/apps/frontend/ticket-web-app/src/styles.css`

- 핵심 변경
  - 유튜브 컨트롤 가시성 복구를 위해 중앙 실드 제거(iframe 직접 상호작용 허용)
  - pause/end 상태에서 재생 복구 시퀀스 유지로 `More videos` 노출 완화
  - 검증 기준을 `>1980`에서 `>2500`으로 상향 고정

- 빌드
  - 명령: `npm run build`
  - 결과: `pass`

- 이미지 빌드/푸시
  - 이미지: `966543711258.dkr.ecr.ap-northeast-2.amazonaws.com/ticketrush/frontend:20260302011446`
  - digest: `sha256:b55812cc1a7cce50c6014d27e73cda4fba44d0cf5500a5579a3893f4dfd02ac7`

- AWS 반영
  - `/opt/ticket-rush/.env` 반영값: `FRONTEND_IMAGE_TAG=20260302011446`
  - compose 상태: `ticket-rush-frontend` 재생성 후 `Up`

- 실서비스 자동검증(2500 초과 뷰포트 고정)
  - 명령:
    - `npx playwright test tmp-playwright/opening-video-ctrlf5-2500plus.spec.js --reporter=line --workers=1`
    - `npx playwright test tmp-playwright/opening-video-ctrlf5-bottomzone-2500plus.spec.js --reporter=line --workers=1`
    - `npx playwright test tmp-playwright/opening-video-2500plus-width-matrix.spec.js --reporter=line --workers=1`
    - `npx playwright test tmp-playwright/opening-video-controls-presence-2500plus.spec.js --reporter=line --workers=1`
    - `npx playwright test tmp-playwright/opening-video-morevideos-direct-2500plus.spec.js --reporter=line --workers=1`
  - 결과:
    - `ctrl+f5/f5 scenario on >2500 viewport` -> `1 passed (25.5s)`
    - `ctrl+f5 + bottom control zone interaction on >2500` -> `1 passed (30.5s)`
    - `>2500 width matrix` -> `1 passed (55.4s)` (2560/3000/3440)
    - `youtube controls presence on >2500 viewport` -> `1 passed (10.4s)`
    - `direct more-videos controls visibility on >2500` -> `1 passed (8.1s)`
  - 핵심 수치:
    - `pointerEvents=auto`
    - `controls=1` 유지
    - `mediaRequests>0` 유지
    - `More videos` direct control `visibleExactNodes=0`

### 2026-03-02 00:06 KST - 3차 재작업(superseded)
- 코드 변경
  - `workspace/apps/frontend/ticket-web-app/src/pages/service/ServiceUrgencyBannerSection.tsx`
  - `workspace/apps/frontend/ticket-web-app/src/styles.css`

- 핵심 변경
  - `More videos/동영상 더보기` 재현 테스트 추가 후 원인 확정(iframe 상호작용 시 노출)
  - YouTube player 상태 동기화 보강(제스처 직후 즉시 재생 동기화 + 종료 시 재시작 처리)
  - iframe 클릭 차단(`.service-opening-media.is-youtube-embed .service-opening-video { pointer-events: none; }`) 적용으로 `More videos/동영상 더보기` 노출 방지
  - 강제 하트비트 루프(`setInterval`)는 미사용 유지

- 빌드
  - 명령: `npm run build`
  - 결과: `pass`

- 이미지 빌드/푸시
  - 이미지: `966543711258.dkr.ecr.ap-northeast-2.amazonaws.com/ticketrush/frontend:20260302000349`
  - digest: `sha256:8b92980c260f535d642e05e7b91802143ca860089be4acb172d5902d4ec50370`

- AWS 반영
  - 대상 인스턴스: `i-04f003f8cf4c65b44`
  - `/opt/ticket-rush/.env` 반영값: `FRONTEND_IMAGE_TAG=20260302000349`
  - compose 상태: `ticket-rush-frontend` 재생성 후 `Up`

- 실서비스 자동검증(텍스트 증빙)
  - 명령:
    - `npx playwright test tmp-playwright/opening-video-more-videos-detect.spec.js --reporter=line --workers=1`
    - `npx playwright test tmp-playwright/opening-video-regression-current.spec.js --reporter=line --workers=1`
    - `npx playwright test tmp-playwright/opening-video-refresh-verify.spec.js --reporter=line --workers=1`
  - 결과:
    - `opening-video-more-videos-detect.spec.js` -> `1 passed (13.2s)`
    - `opening-video-regression-current.spec.js` -> `1 passed (11.6s)`
    - `opening-video-refresh-verify.spec.js` -> `1 passed (27.8s)`
  - 핵심 수치:
    - `More videos/동영상 더보기` 감지: 전 단계 실패 -> 현재 단계 `all false`
    - 새로고침 전/후 미디어 요청 수: `mediaRequests1=9`, `mediaRequests2=18`
    - 새로고침 검증 상세:
      - `soft-load-1/2/3`: `moreVideos=false`, `mediaRequests=7/6/7`
      - `hard-like-1/2/3`: `moreVideos=false`, `mediaRequests=7/6/7`

### 2026-03-01 23:33 KST - 2차 재작업(superseded)
- 코드 변경
  - `workspace/apps/frontend/ticket-web-app/src/pages/service/ServiceUrgencyBannerSection.tsx`
  - `workspace/apps/frontend/ticket-web-app/src/styles.css`

- 핵심 변경
  - YouTube embed 파라미터 변경
    - `controls=1`, `disablekb=0`, `fs=1`
    - `loop=1`, `playlist=<videoId>` 제거
  - iframe 클릭 차단(`pointer-events:none`) 제거 -> 기본 YouTube 컨트롤 직접 사용 가능
  - 커스텀 버튼/링크 제거
    - `service-opening-audio-toggle-btn`
    - `service-opening-playback-toggle-btn`
    - `service-opening-video-link`
  - 강제 하트비트 루프 제거
    - `setInterval` 기반 강제 재생 로직 제거
  - 재생/음소거 처리 단순화
    - `inView + gesture` 기반으로만 `play/pause + mute/unmute` 동기화

- 빌드
  - 명령: `npm run build`
  - 결과: `pass`

- 이미지 빌드/푸시
  - 이미지: `966543711258.dkr.ecr.ap-northeast-2.amazonaws.com/ticketrush/frontend:20260301233022`
  - digest: `sha256:1df719f2304c62df2f1374b26f84cf93390b2469228216520996d73bdaaa94ad`

- AWS 반영
  - 대상 인스턴스: `i-04f003f8cf4c65b44`
  - `/opt/ticket-rush/.env` 반영값: `FRONTEND_IMAGE_TAG=20260301233022`
  - compose 상태: `ticket-rush-frontend` 재생성 후 `Up`

- 실서비스 자동검증(텍스트 증빙)
  - 명령:
    - `npx playwright test tmp-playwright/opening-video-regression.spec.js --reporter=line --workers=1`
    - `npx playwright test tmp-playwright/opening-video-moretext-check.spec.js --reporter=line --workers=1`
  - 결과:
    - `opening-video-regression.spec.js` -> `1 passed (13.1s)`
    - `opening-video-moretext-check.spec.js` -> `1 passed (7.8s)`
  - 네트워크 증거(새로고침 포함):
    - 1차 로드: `youtubeEmbedRequests=1`, `mediaRequests=7`
    - 새로고침 후: `youtubeEmbedRequests=2`, `mediaRequests=10`
  - 코드 스캔 증거:
    - `setInterval`, 커스텀 버튼 클래스 검색 결과: `NO_MATCH_FOUND`

### 2026-03-01 23:15 KST - 배포/검증 결과 (superseded)
- 코드 변경
  - `workspace/apps/frontend/ticket-web-app/src/pages/service/ServiceUrgencyBannerSection.tsx`
  - `workspace/apps/frontend/ticket-web-app/src/styles.css`
- 핵심 변경
  - iframe 직접 상호작용 차단(`pointer-events: none`)으로 YouTube 하단 추천/더보기 UI 트리거 차단
  - 커스텀 제어 버튼 2종 유지: `음소거/해제`, `재생/일시정지`
  - 자동재생 루프가 수동 일시정지 상태를 덮어쓰지 않도록 `isOpeningPlaybackPaused` 가드 적용

- 빌드
  - 명령: `npm run build`
  - 결과: `pass`

- 이미지 빌드/푸시
  - 이미지: `966543711258.dkr.ecr.ap-northeast-2.amazonaws.com/ticketrush/frontend:20260301230402`
  - digest: `sha256:741bd1ad25326d384cac9fcfff6507e5d5cc739cbb05592b74f6f4d6e9355756`

- AWS 반영
  - 대상 인스턴스: `i-04f003f8cf4c65b44`
  - `/opt/ticket-rush/.env` 반영값: `FRONTEND_IMAGE_TAG=20260301230402`
  - compose 상태: `ticket-rush-frontend` 재생성 후 `Up`

- 실서비스 자동검증(텍스트 증빙)
  - 명령:
    - `npx playwright test tmp-playwright/opening-video-check.spec.js --reporter=line --workers=1`
  - 결과: `1 passed (10.0s)`
  - 네트워크 증거:
    - `youtubeEmbedRequests=1`
    - `mediaRequests=8` (`googlevideo.com/videoplayback` 또는 `youtubei/v1/player`)
  - UI 상태 증거:
    - iframe `pointer-events=none`
    - 스크롤+휠 후 오디오 버튼 `음소거 해제` -> `음소거` 전환 확인
    - 재생 버튼 `일시정지` -> `재생` -> `일시정지` 전환 확인
    - 영상 영역 클릭 후 페이지 DOM에서 `동영상 더보기` 텍스트 미검출
