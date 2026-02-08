# Playwright MCP Setup (Linux / WSL)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-08 23:11:27`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 1. Baseline Check
> - 2. Installation Policy Gate
> - 3. WSL GUI Enablement
> - 4. GUI Smoke Test
> - 5. MCP Functional Check
> - 6. Optional: Install Recipe (Only If Allowed)
> - 7. Optional: Code-Based Playwright Runtime
<!-- DOC_TOC_END -->

## 1. Baseline Check

```bash
bash skills/playwright-mcp/scripts/diagnose_playwright_mcp.sh
```

확인 포인트:
- 브라우저(`google-chrome` 또는 `chromium`) 존재
- WSL이면 `DISPLAY`, `WAYLAND_DISPLAY`, `/mnt/wslg` 확인

## 2. Installation Policy Gate

기본값:
- `MCP_INSTALL_POLICY=forbid` (권장 기본)
- 명시 요청이 없는 자동 설치는 금지

환경별 권장:
1. 회사/보안 통제 환경: `forbid`
2. CI/컨테이너(이미지 고정): `forbid`
3. 개인 개발 PC 초기 세팅: `allow` 가능

예시:
```bash
export MCP_INSTALL_POLICY=forbid
export MCP_BROWSER_BIN=google-chrome
```

## 3. WSL GUI Enablement

Windows `%UserProfile%\.wslconfig`:

```ini
[wsl2]
guiApplications=true
```

적용:

```powershell
wsl --shutdown
```

다시 WSL 접속 후 진단 스크립트를 재실행한다.

## 4. GUI Smoke Test

```bash
bash skills/playwright-mcp/scripts/chrome_gui_smoke.sh https://www.google.com
```

주의:
- 터미널 세션과 분리하려면 `nohup` 기반 실행을 사용한다.
- 일부 환경에서는 실행 세션이 끝나면서 브라우저도 같이 종료될 수 있다.

## 5. MCP Functional Check

MCP 도구에서 최소 순서:
1. `navigate`
2. `snapshot`
3. `click` 또는 `type`
4. `take_screenshot` 또는 `console_messages`

이 순서를 통과하면 "MCP 제어 경로"가 정상이다.

## 6. Optional: Install Recipe (Only If Allowed)

아래는 `MCP_INSTALL_POLICY=allow`이고 사용자 요청이 있을 때만 수행한다.

Ubuntu/WSL 기준:
```bash
sudo apt-get update
sudo apt-get install -y curl ca-certificates gnupg
```

브라우저가 없다면 조직 정책에 맞는 브라우저를 설치한다.
`google-chrome`가 아니어도 `chromium`/`microsoft-edge-stable` 사용 가능.

## 7. Optional: Code-Based Playwright Runtime

기본 목적이 MCP-only라면 이 단계는 생략한다.  
프로젝트에서 Playwright 코드를 직접 실행해야 할 때만 사용한다.

```bash
npm install -D playwright
npx playwright install --with-deps chromium
```
