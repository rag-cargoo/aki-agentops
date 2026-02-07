# Skills Bin Guide

`skills/bin/`은 스킬 시스템의 공용 운영 스크립트 전용 디렉토리다.

## What Goes Here
1. 세션/리로드/타겟 전환 같은 공통 제어 스크립트
2. 여러 스킬에서 함께 쓰는 운영 스크립트

리로드 관련 스크립트는 `skills/bin/codex_skills_reload/`에 집중 배치한다.
`skills/bin/*.sh`의 리로드 엔트리는 호환용 래퍼로 유지한다.

## What Should Not Go Here
1. 특정 스킬 내부 로직 전용 스크립트
2. 도메인 전용 검증 스크립트

해당 스크립트는 각 스킬의 `skills/<skill-name>/scripts/`에 둔다.

## Current Core Scripts
1. `create-backup-point.sh`
2. `session_start.sh` (wrapper)
3. `set_active_project.sh` (wrapper)
4. `skills_reload.sh` (wrapper)
5. `project_reload.sh` (wrapper)
6. `sync-skill.sh`
7. `codex_skills_reload/` (실제 리로드 구현)

## Safety
1. 세션 시작 시 `./skills/bin/session_start.sh`가 `skills/bin` 무결성을 점검한다.
2. 스크립트를 수정/추가했다면 `chmod +x skills/bin/*.sh` 후 재실행한다.
