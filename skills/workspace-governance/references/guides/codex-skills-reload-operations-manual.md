# Codex Skills Reload 운영 매뉴얼

> 목적: 세션 시작/진행 중 스킬 리로드와 프로젝트 타겟 전환을 안전하게 운영하기 위한 사람용 표준 가이드.
> 범위: `skills/bin/codex_skills_reload/` 및 관련 런타임 스냅샷(`.codex/runtime/`).

---

## 0. 30초 요약 (초보자용)

1. 시작할 때 이것만 실행:
`./skills/bin/codex_skills_reload/session_start.sh`
2. 멀티 프로젝트면 먼저 선택:
`./skills/bin/codex_skills_reload/set_active_project.sh --list`
`./skills/bin/codex_skills_reload/set_active_project.sh <project-root>`
3. 스킬 수정/추가 후에도 동일:
`스킬스 리로드해줘` 또는 `./skills/bin/codex_skills_reload/session_start.sh` 재실행
4. 상태 확인 파일:
`.codex/runtime/codex_session_start.md`

---

## 1. 왜 이 구조를 만들었나

1. 세션이 바뀌면 대화 메모리가 끊길 수 있어, 규칙/스킬을 매번 일관되게 재로딩하기 위해.
2. 멀티 프로젝트 환경에서 잘못된 프로젝트 규칙이 섞이는 사고를 방지하기 위해.
3. 리로드 중간 결과 파일이 문서 트리에 섞이지 않도록 `.codex/runtime/`에 분리하기 위해.

---

## 2. 빠른 시작 (운영자 기준)

1. 세션 시작:
`./skills/bin/codex_skills_reload/session_start.sh`
2. 멀티 프로젝트에서 타겟 선택:
`./skills/bin/codex_skills_reload/set_active_project.sh --list`
`./skills/bin/codex_skills_reload/set_active_project.sh <project-root>`
3. 리로드 요청 문구:
`스킬스 리로드해줘`

---

## 3. 스크립트 역할 (건드리기 전 반드시 확인)

| 스크립트 | 역할 | 임의 수정/삭제 리스크 |
|---|---|---|
| `skills/bin/codex_skills_reload/session_start.sh` | 단일 진입점. skills/project 스냅샷 생성 후 세션 상태 문서 생성 | 시작 보고가 깨지고, Active Project 안내가 누락됨 |
| `skills/bin/codex_skills_reload/skills_reload.sh` | 로드된 `SKILL.md` 목록 스냅샷 생성 | 스킬 목록 검증 불가 |
| `skills/bin/codex_skills_reload/project_reload.sh` | 프로젝트 탐색 + Active Project 스냅샷 생성 | 프로젝트 규칙 오적용 가능 |
| `skills/bin/codex_skills_reload/set_active_project.sh` | Active Project 지정/조회 | 멀티 프로젝트 운영 실패 |
| `skills/bin/create-backup-point.sh` | 위험 작업 전 백업 브랜치/태그 생성 | 복구 지점 상실 |
| `skills/bin/sync-skill.sh` | 런타임 스킬 링크 동기화 | 런타임이 최신 스킬을 못 읽을 수 있음 |

권장 원칙:
1. 위 스크립트는 목적을 모르면 수정하지 않는다.
2. 수정 후에는 반드시 `bash -n` 문법 체크 + `session_start.sh` 실행 검증을 한다.

---

## 4. 세션 중 운영 규칙

### 4.1 사용자가 스킬을 수정/추가한 경우
1. 사용자 지시: `스킬스 리로드해줘`
2. 에이전트 수행:
`./skills/bin/codex_skills_reload/session_start.sh`
3. 확인:
`.codex/runtime/codex_session_start.md`

### 4.2 에이전트가 스킬을 수정한 경우
1. 수정 직후 동일하게 `session_start.sh` 재실행
2. `Startup Checks`가 모두 `OK`인지 보고
3. 경고가 있으면 즉시 해결 명령을 같이 제시

---

## 5. 내부 동작 원리

1. `session_start.sh`가 내부적으로 `skills_reload.sh` + `project_reload.sh`를 순서대로 호출
2. 결과를 `.codex/runtime/`에 생성
3. 생성된 세 파일:
`codex_skills_reload.md`, `codex_project_reload.md`, `codex_session_start.md`
4. 에이전트는 이 스냅샷을 읽고 첫 응답에서 다음을 보고:
- Startup Checks
- Loaded Skills
- Active Project
- 멀티 프로젝트 전환 가이드

---

## 6. 멀티 프로젝트 표준 절차

1. 목록 확인:
`./skills/bin/codex_skills_reload/set_active_project.sh --list`
2. 타겟 지정:
`./skills/bin/codex_skills_reload/set_active_project.sh <project-root>`
3. 재동기화:
`./skills/bin/codex_skills_reload/session_start.sh`

---

## 7. 런타임 스냅샷 파일 정책

1. 위치: `.codex/runtime/`
2. 성격: 일회성/재생성 가능 캐시
3. Git 정책: 커밋 대상 아님 (`.gitignore` 제외 처리)
4. 운영 원칙: 수동 편집 금지, 스크립트로만 생성

---

## 8. 변경 시 체크리스트

1. 경로 변경 시 `AGENTS.md`와 관련 가이드 경로를 함께 수정했는가?
2. `bash -n skills/bin/codex_skills_reload/*.sh` 통과했는가?
3. `./skills/bin/codex_skills_reload/session_start.sh` 실행 결과가 `OK`인가?
4. 멀티 프로젝트 전환 명령이 여전히 동작하는가?
5. 사이드바 링크가 사람 기준으로 찾기 쉬운 위치에 있는가?

---

## 9. 권장 추가 개선

1. `pre-commit` 훅으로 스킬 변경 시 `session_start.sh` 자동 실행
2. CI에서 `session_start.sh` dry-run 검증
3. 신규 프로젝트 생성 스크립트에 `PROJECT_AGENT.md` 템플릿 자동 주입
