# Project Agent: <Service Name> (Rules)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-17 17:28:03`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Mandatory Load Order
> - Project Rules
> - Done Criteria
<!-- DOC_TOC_END -->

## Scope
이 문서는 `<project-root>` 경로의 프로젝트에만 적용된다.
다른 프로젝트에는 이 규칙을 전파하지 않는다.

## Mandatory Load Order
1. `<project-root>/README.md`
2. `<project-root>/prj-docs/task.md`
3. `<project-root>/prj-docs/meeting-notes/README.md`
4. `<project-root>/prj-docs/rules/`

## Project Rules
1. 프로젝트 기준선 문서/디렉토리(`README.md`, `prj-docs/PROJECT_AGENT.md`, `prj-docs/task.md`, `prj-docs/meeting-notes/README.md`, `prj-docs/rules/`)는 항상 존재해야 한다.
2. 문서 변경 시 기존 상세 내용을 삭제/요약하지 않고 구조화 중심으로 수정한다.
3. API/도메인 변경 시 관련 `api-specs/*.md`와 `task.md`를 함께 현행화한다.
4. 문서 신규 생성/이동 시 `github-pages/sidebar-manifest.md` 링크를 즉시 동기화한다.
5. 프로젝트 고유 결정은 `prj-docs/knowledge/`에 근거와 함께 기록한다.
6. 임시 산출물(`*.log`, `*.tmp`, 대시보드 HTML/스크린샷)은 `.codex/tmp/<tool>/<run-id>/`에 저장하고, 영구 증빙 파일(`*.md`, `*.json`)만 프로젝트 문서 경로에 유지한다.
7. pre-commit 체인은 `.codex/tmp/` 밖에 임시 산출물이 stage되면 warning을 출력한다(차단 아님).

## Done Criteria
1. 코드, 테스트, 문서(`task.md`, 필요 시 API 명세)가 서로 모순 없이 정합성을 가진다.
2. GitHub Pages에서 문서 링크/렌더링이 깨지지 않는다.
