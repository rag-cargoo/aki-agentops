# MCP Workspace Ops

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-08 23:32:34`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Tree
> - 1) MCP 목록 선언
> - 2) 설치 정책 게이트
> - 3) 세션 재시작 핸드오프
> - 4) 운영 TODO
> - 5) 경험 로그
<!-- DOC_TOC_END -->

이 디렉토리는 MCP 설치/점검과 세션 재시작 핸드오프를 한 곳에서 관리한다.

## Tree

```text
mcp/
  TODO.md
  manifest/
    mcp-manifest.sh
  references/
    experience-log.md
  runtime/
    SESSION_HANDOFF.md         # 휘발성(로컬) 핸드오프 문서
    archive/                   # 핸드오프 스냅샷 보관
  scripts/
    mcp_sync.sh
    write_session_handoff.sh
    clear_session_handoff.sh
```

## 1) MCP 목록 선언

파일: `mcp/manifest/mcp-manifest.sh`

- MCP 항목은 `mcp_register` 한 줄로 추가한다.
- `check_cmd`는 설치 여부 점검 명령이다.
- `install_cmd`는 자동 설치 명령이다. 자동 설치가 불필요하면 `-`를 사용한다.

## 2) 설치 정책 게이트

`mcp/scripts/mcp_sync.sh`는 정책 기반으로만 설치를 수행한다.

- `forbid` (기본): 누락이어도 설치하지 않음
- `prompt`: TTY 환경에서만 설치 여부 질의
- `allow`: 누락 시 `install_cmd` 자동 실행

예시:

```bash
bash mcp/scripts/mcp_sync.sh
MCP_INSTALL_POLICY=allow bash mcp/scripts/mcp_sync.sh
MCP_INSTALL_POLICY=allow bash mcp/scripts/mcp_sync.sh --name playwright-mcp-browser
```

## 3) 세션 재시작 핸드오프

재시작 전 요약 문서 작성:

```bash
bash mcp/scripts/write_session_handoff.sh \
  --reason "MCP 설치 후 세션 재시작 필요" \
  --done "playwright-mcp-browser 점검 완료" \
  --next "새 세션 시작 후 SESSION_HANDOFF.md 우선 로드"
```

재시작 후 정리:

```bash
bash mcp/scripts/clear_session_handoff.sh
```

`skills/bin/codex_skills_reload/session_start.sh`는
`mcp/runtime/SESSION_HANDOFF.md` 존재 시 `.codex/runtime/codex_session_start.md`에
`Session Handoff` 섹션을 자동 표기한다.

## 4) 운영 TODO

파일: `mcp/TODO.md`

- MCP 운영 개선 아이템(정책/자동화/리팩토링)을 체크리스트로 관리한다.
- 서비스 기능 TODO(`workspace/.../prj-docs/TODO.md`)와 분리한다.

## 5) 경험 로그

파일: `mcp/references/experience-log.md`

- 실제 장애/복구/제약 사례를 누적 기록한다.
- 재발 방지를 위해 증상/원인/해결/검증 명령을 함께 남긴다.
