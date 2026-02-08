# Playwright MCP Troubleshooting

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-08 23:11:27`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 1. Browser Opens Then Closes Immediately
> - 2. `Trace/breakpoint trap` or `setsockopt: Operation not permitted`
> - 3. `DISPLAY` or `WAYLAND_DISPLAY` Missing
> - 4. DBus Warning Flood in Logs
> - 5. Browser Missing But Installation Is Prohibited
> - 6. MCP Works But GUI Is Not Visible
> - 7. MCP Tools Fail But GUI Is Visible
> - 8. Optional Only: Playwright Module Not Found
<!-- DOC_TOC_END -->

## 1. Browser Opens Then Closes Immediately

증상:
- 창이 잠깐 떴다가 바로 닫힘

원인:
- 비대화형 셸 종료 시 자식 프로세스에 `SIGHUP` 전달

조치:
```bash
nohup google-chrome --new-window https://www.google.com >/tmp/chrome.log 2>&1 < /dev/null &
```

## 2. `Trace/breakpoint trap` or `setsockopt: Operation not permitted`

증상:
- 브라우저 시작 직후 크래시

원인:
- 실행 샌드박스 정책과 브라우저 제약 충돌

조치:
- 권한 정책(샌드박스/실행 승인) 확인
- 필요 시 승인된 경로에서 실행
- 로그 파일(`/tmp/*.log`) 기준으로 재검증

## 3. `DISPLAY` or `WAYLAND_DISPLAY` Missing

증상:
- GUI 앱이 뜨지 않음

원인:
- WSLg 비활성 또는 세션 변수 누락

조치:
1. `%UserProfile%\\.wslconfig`에 `guiApplications=true` 설정
2. `wsl --shutdown` 후 재접속
3. `echo $DISPLAY`, `echo $WAYLAND_DISPLAY` 확인

## 4. DBus Warning Flood in Logs

증상:
- `Failed to connect to socket /run/user/1000/bus`

해석:
- WSL/컨테이너 환경에서 자주 보이는 경고
- 실행이 정상이라면 치명적이지 않을 수 있음

조치:
- 경고 자체보다 실제 종료 코드와 동작 성공 여부를 우선 판단
- 실패 시에만 추가 조치

## 5. Browser Missing But Installation Is Prohibited

증상:
- `no_browser_found`
- 설치는 정책상 금지 상태

원인:
- `MCP_INSTALL_POLICY=forbid`에서 설치 단계 수행 불가

조치:
1. 기존 브라우저 경로를 `MCP_BROWSER_BIN`으로 지정
2. 설치가 필요한 경우 사용자 승인 후 `MCP_INSTALL_POLICY=allow`로 전환
3. 조직 표준 브라우저(`chromium`, `microsoft-edge-stable` 등)를 우선 사용

## 6. MCP Works But GUI Is Not Visible

증상:
- MCP 명령은 성공하지만 사용자 화면에 창이 안 보임

원인:
- 헤드리스 실행 경로만 성공

조치:
- GUI 스모크(`chrome_gui_smoke.sh`)와 MCP 검증을 분리 실행
- 둘 다 통과해야 "사용자 체감 기준 정상"으로 판정

## 7. MCP Tools Fail But GUI Is Visible

증상:
- 브라우저 창은 뜨지만 MCP 명령(`navigate`, `click`, `type`)이 실패

원인:
- MCP 서버 연결/세션 상태 문제
- 브라우저 실행 경로와 MCP 제어 대상이 불일치

조치:
1. MCP 세션을 새로 시작하고 `navigate`부터 재실행
2. `snapshot`으로 현재 페이지 트리를 먼저 확인
3. GUI 성공 여부와 독립적으로 MCP 결과를 판정

## 8. Optional Only: Playwright Module Not Found

증상:
- `Cannot find module 'playwright'`

해석:
- MCP-only 목적이라면 정상 범주일 수 있음

조치:
- 코드 기반 Playwright 실행이 필요할 때만 아래를 수행
```bash
npm install -D playwright
npx playwright install --with-deps chromium
```
