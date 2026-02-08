# Codex Skills Reload 운영 매뉴얼

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-08 23:11:27`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 0. 운영 플로우 요약 (세션 시작/세션 중)
> - 1. 왜 이 구조를 만들었나
> - 2. 스크립트 역할 (건드리기 전 반드시 확인)
> - 3. 내부 동작 원리
> - 4. 멀티 프로젝트 표준 절차
> - 5. 런타임 스냅샷 파일 정책
> - 6. 변경 시 체크리스트
> - 7. 자동화 적용 상태
> - 8. pre-commit 모드 정책 (Quick / Strict)
<!-- DOC_TOC_END -->

> 목적: 세션 시작/진행 중 스킬 리로드와 프로젝트 타겟 전환을 안전하게 운영하기 위한 사람용 표준 가이드.
> 범위: `skills/bin/codex_skills_reload/` 및 관련 런타임 스냅샷(`.codex/runtime/`).

---

먼저 읽기:
1. 시작 절차: `skills/workspace-governance/references/guides/codex-skills-reload-start-guide.md`
2. 도입 배경/변경 내역: `skills/workspace-governance/references/guides/codex-skills-reload-automation-rationale-and-changes.md`

---

## 0. 운영 플로우 요약 (세션 시작/세션 중)

| 구분 | 코덱스 자동 트리거(권장) | 수동 실행(터미널) |
|---|---|---|
| 세션 시작 | `AGENTS.md만 읽고 시작해` 또는 `AGENTS.md 확인해줘` | `./skills/bin/codex_skills_reload/session_start.sh` |
| 세션 진행 중(스킬 수정/추가 후) | `스킬스 리로드해줘` | `./skills/bin/codex_skills_reload/session_start.sh` |

공통:
1. 완전 자동 무지시 실행은 아니며, 트리거 한 줄이 필요하다.
2. 상태 확인 파일: `.codex/runtime/codex_session_start.md`
3. 에이전트가 같은 턴에서 스킬을 수정하면 기본적으로 자동 재실행/보고한다.
4. 예외(턴 중단/실패/인터럽트) 시 위 트리거나 수동 실행으로 복구한다.

---

## 1. 왜 이 구조를 만들었나

1. 세션이 바뀌면 대화 메모리가 끊길 수 있어, 규칙/스킬을 매번 일관되게 재로딩하기 위해.
2. 멀티 프로젝트 환경에서 잘못된 프로젝트 규칙이 섞이는 사고를 방지하기 위해.
3. 리로드 중간 결과 파일이 문서 트리에 섞이지 않도록 `.codex/runtime/`에 분리하기 위해.

---

## 2. 스크립트 역할 (건드리기 전 반드시 확인)

| 스크립트 | 역할 | 임의 수정/삭제 리스크 |
|---|---|---|
| `skills/bin/codex_skills_reload/session_start.sh` | 단일 진입점. skills/project 스냅샷 생성 후 세션 상태 문서 생성 | 시작 보고가 깨지고, Active Project 안내가 누락됨 |
| `skills/bin/codex_skills_reload/skills_reload.sh` | 로드된 `SKILL.md` 목록 스냅샷 생성 | 스킬 목록 검증 불가 |
| `skills/bin/codex_skills_reload/project_reload.sh` | 프로젝트 탐색 + Active Project 스냅샷 생성 | 프로젝트 규칙 오적용 가능 |
| `skills/bin/codex_skills_reload/set_active_project.sh` | Active Project 지정/조회 | 멀티 프로젝트 운영 실패 |
| `skills/bin/codex_skills_reload/init_project_docs.sh` | 신규 프로젝트 `prj-docs` 기본 골격 + `PROJECT_AGENT.md` 템플릿 주입 | 초기 프로젝트 문서 누락/편차 발생 |
| `skills/bin/create-backup-point.sh` | 위험 작업 전 백업 브랜치/태그 생성 | 복구 지점 상실 |
| `skills/bin/sync-skill.sh` | 런타임 스킬 링크 동기화 | 런타임이 최신 스킬을 못 읽을 수 있음 |

권장 원칙:
1. 위 스크립트는 목적을 모르면 수정하지 않는다.
2. 수정 후에는 반드시 `bash -n` 문법 체크 + `session_start.sh` 실행 검증을 한다.

---

## 3. 내부 동작 원리

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

## 4. 멀티 프로젝트 표준 절차

1. 목록 확인:
`./skills/bin/codex_skills_reload/set_active_project.sh --list`
2. 타겟 지정:
`./skills/bin/codex_skills_reload/set_active_project.sh <project-root>`
3. 재동기화:
`./skills/bin/codex_skills_reload/session_start.sh`

---

## 5. 런타임 스냅샷 파일 정책

1. 위치: `.codex/runtime/`
2. 성격: 일회성/재생성 가능 캐시
3. Git 정책: 커밋 대상 아님 (`.gitignore` 제외 처리)
4. 운영 원칙: 수동 편집 금지, 스크립트로만 생성

---

## 6. 변경 시 체크리스트

1. 경로 변경 시 `AGENTS.md`와 관련 가이드 경로를 함께 수정했는가?
2. `bash -n skills/bin/codex_skills_reload/*.sh` 통과했는가?
3. `./skills/bin/codex_skills_reload/session_start.sh` 실행 결과가 `OK`인가?
4. 멀티 프로젝트 전환 명령이 여전히 동작하는가?
5. 사이드바 링크가 사람 기준으로 찾기 쉬운 위치에 있는가?
6. 로컬 훅 경로가 `.githooks`로 설정되었는가? (`git config core.hooksPath .githooks`)

---

## 7. 자동화 적용 상태

1. `pre-commit` 훅 적용:
`./.githooks/pre-commit`
2. 훅 활성화(로컬 1회):
`git config core.hooksPath .githooks`
3. CI dry-run 검증:
`.github/workflows/codex-skills-reload.yml`
4. 신규 프로젝트 문서 초기화:
`./skills/bin/codex_skills_reload/init_project_docs.sh <project-root>`
5. pre-commit 정책 엔진:
`./skills/bin/validate-precommit-chain.sh`
6. 전역 정책 레지스트리:
`skills/precommit/policies/*.sh`
7. 프로젝트 정책 레지스트리:
`<project-root>/prj-docs/precommit-policy.sh`

---

## 8. pre-commit 모드 정책 (Quick / Strict)

1. 기본 모드는 `quick`이다. 일상 커밋은 속도를 우선한다.
2. `strict`는 중요 구간에서만 사용한다.
- 마일스톤 완료 직전
- 릴리즈/배포 직전
- API 체인 변경 마무리 커밋
3. `strict` 전환은 사용자 승인 후 수행한다.
4. `strict` 검증 완료 뒤 기본값은 다시 `quick`으로 복구한다.
5. `strict`는 정책 레지스트리에 없는(미커버) staged 경로를 실패 처리한다.
6. `strict`는 지식 문서/ API 명세 문서의 품질 토큰( Failure-First, Before&After, Execution Log, 6-Step )을 검증한다.
7. 에이전트 완료 보고 시 현재 모드와 변경 명령을 함께 고지한다.

운영 명령:
1. 현재 기본 모드 확인:
`./skills/bin/precommit_mode.sh status`
2. 기본 모드 변경:
`./skills/bin/precommit_mode.sh quick`
`./skills/bin/precommit_mode.sh strict`
3. 1회성 strict 강제:
`CHAIN_VALIDATION_MODE=strict git commit -m "..."`
