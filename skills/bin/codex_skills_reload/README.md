# Codex Skills Reload Runtime

`skills/bin/codex_skills_reload/`는 리로드 로직의 실제 구현 디렉토리다.

## Scripts
1. `session_start.sh` - 단일 진입 리로드 및 상태 보고 문서 생성
2. `skills_reload.sh` - 스킬 목록 스냅샷 생성
3. `project_reload.sh` - 활성 프로젝트 스냅샷 생성
4. `set_active_project.sh` - 활성 프로젝트 지정/조회

## Notes
1. 기본 진입점은 `./skills/bin/codex_skills_reload/session_start.sh`다.
2. 멀티 프로젝트 전환은 `./skills/bin/codex_skills_reload/set_active_project.sh`를 사용한다.
