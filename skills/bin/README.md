# Skills Bin Guide

`skills/bin/`은 스킬 시스템의 공용 운영 스크립트 전용 디렉토리다.

## What Goes Here
1. 세션/리로드/타겟 전환 같은 공통 제어 스크립트
2. 여러 스킬에서 함께 쓰는 운영 스크립트

## What Should Not Go Here
1. 특정 스킬 내부 로직 전용 스크립트
2. 도메인 전용 검증 스크립트

해당 스크립트는 각 스킬의 `skills/<skill-name>/scripts/`에 둔다.

## Current Core Scripts
1. `create-backup-point.sh`
2. `session_start.sh`
3. `set_active_project.sh`
4. `skills_reload.sh`
5. `project_reload.sh`
6. `sync-skill.sh`

## Safety
1. 세션 시작 시 `./skills/bin/session_start.sh`가 `skills/bin` 무결성을 점검한다.
2. 스크립트를 수정/추가했다면 `chmod +x skills/bin/*.sh` 후 재실행한다.
