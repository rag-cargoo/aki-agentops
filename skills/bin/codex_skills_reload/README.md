# Codex Skills Reload Runtime

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-08 23:32:34`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scripts
> - Notes
<!-- DOC_TOC_END -->

`skills/bin/codex_skills_reload/`는 리로드 로직의 실제 구현 디렉토리다.

## Scripts
1. `session_start.sh` - 단일 진입 리로드 및 상태 보고 문서 생성
2. `skills_reload.sh` - 스킬 목록 스냅샷 생성
3. `project_reload.sh` - 활성 프로젝트 스냅샷 생성
4. `set_active_project.sh` - 활성 프로젝트 지정/조회
5. `init_project_docs.sh` - 신규 프로젝트 문서 골격 + `PROJECT_AGENT.md` 템플릿 주입

## Notes
1. 기본 진입점은 `./skills/bin/codex_skills_reload/session_start.sh`다.
2. 멀티 프로젝트 전환은 `./skills/bin/codex_skills_reload/set_active_project.sh`를 사용한다.
3. 신규 프로젝트 문서 생성은 `./skills/bin/codex_skills_reload/init_project_docs.sh <project-root>`를 사용한다.
