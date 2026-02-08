# MCP Experience Log

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-08 23:32:34`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 2026-02-08
<!-- DOC_TOC_END -->

> MCP 운영 중 발생한 실제 경험을 누적 기록한다.

---

## 2026-02-08

### Case: WSL에서 Chrome 창이 잠깐 떴다가 닫히는 현상

- Context:
  - WSL2 + WSLg 환경에서 GUI 실행 테스트
  - 비대화형 셸에서 브라우저 실행
- Symptom:
  - `google-chrome --new-window` 실행 직후 창이 닫히는 것처럼 보임
- Root Cause:
  - 셸 세션 종료 시 자식 프로세스가 같이 정리될 수 있음(`SIGHUP` 영향)
- Mitigation:
  - `nohup ... < /dev/null &`로 실행해 세션 분리
- Verification:
  - 프로세스 유지 여부(`pgrep`, `ps`)로 확인

### Case: WSL GUI 옵션 미반영으로 인한 표시 문제

- Context:
  - Windows 측 `.wslconfig` 변경 직후
- Symptom:
  - GUI 앱 표시 불안정/미표시
- Root Cause:
  - `guiApplications=true` 설정 반영 전 상태
- Mitigation:
  - `%UserProfile%\\.wslconfig`에 옵션 반영 후 `wsl --shutdown`
- Verification:
  - WSL 재접속 후 `DISPLAY`, `WAYLAND_DISPLAY` 확인

### Notes

- MCP 제어 성공과 GUI 가시성 성공은 분리해 판정한다.
- 기본 설치 정책은 `MCP_INSTALL_POLICY=forbid`를 유지한다.
