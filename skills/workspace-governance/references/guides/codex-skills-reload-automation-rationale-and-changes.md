# Codex Skills Reload 자동화 도입 배경 및 변경 내역

> 목적: "이번 변경을 왜 했는지"와 "무엇이 추가/변경됐는지"만 빠르게 확인하기 위한 문서.

---

## 0. 결론 요약

이번 변경은 아래 3가지를 도입해 세션/문서/프로젝트 컨텍스트 품질을 안정화한 작업이다.

1. `pre-commit` 로컬 차단
2. GitHub Actions CI 원격 검증
3. 신규 프로젝트 문서 템플릿 자동 주입

---

## 1. 왜 이 작업을 했나

다음 리스크를 줄이기 위해서다.

1. 스크립트/경로가 깨진 상태로 커밋되는 문제
2. 세션마다 로딩 상태가 달라지는 문제
3. 신규 프로젝트마다 `prj-docs` 구조가 제각각이 되는 문제

핵심 목표는 "사고 후 복구"가 아니라 "사고 전 예방"이다.

---

## 2. 이번 변경에서 실제로 한 것

## 2.1 로컬 커밋 전 자동 검증 추가

파일:
- `./.githooks/pre-commit`

변경 내용:
1. `AGENTS.md`, `skills/**`, `workspace/**/prj-docs/PROJECT_AGENT.md` 변경이 스테이징되면 자동 검증 실행
2. `bash -n skills/bin/codex_skills_reload/*.sh`
3. `./skills/bin/codex_skills_reload/session_start.sh`

## 2.2 원격 CI 검증 추가

파일:
- `.github/workflows/codex-skills-reload.yml`

변경 내용:
1. push/PR 시 리로드 스크립트 문법 점검
2. `session_start.sh` 실행 검증
3. `.codex/runtime/*` 스냅샷 생성/형식 확인

## 2.3 신규 프로젝트 문서 자동 초기화 추가

파일:
- `skills/bin/codex_skills_reload/init_project_docs.sh`

변경 내용:
1. `prj-docs` 기본 폴더 자동 생성
2. `PROJECT_AGENT.md` 템플릿 자동 주입
3. `task.md`, `TODO.md`, `ROADMAP.md`, `rules/architecture.md` 기본 문서 생성

---

## 3. 변경으로 기대하는 효과

1. 깨진 스크립트 상태가 커밋 단계에서 선차단된다.
2. 로컬/원격 검증 기준이 동일해진다.
3. 신규 프로젝트 시작 품질이 균일해진다.

---

## 4. 문서 경계 (중복 방지)

이 문서:
1. 도입 배경
2. 변경 내역
3. 기대 효과

운영 매뉴얼:
1. 운영 절차
2. 실행 방법
3. 장애 복구/점검 체크리스트

---

## 5. 참고 문서

1. 운영 절차 상세: `skills/workspace-governance/references/guides/codex-skills-reload-operations-manual.md`
2. 세션 진입 규칙: `AGENTS.md`
