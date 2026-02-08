# Codex Skills Reload 자동화 도입 배경 및 변경 내역

> 목적: "이번 변경을 왜 했는지"와 "무엇이 추가/변경됐는지"만 빠르게 확인하기 위한 문서.

---

## 0. 결론 요약

이번 변경은 아래 3가지를 도입해 세션/문서/프로젝트 컨텍스트 품질을 안정화한 작업이다.

1. `pre-commit` 로컬 차단(quick/strict 모드)
2. GitHub Actions CI 원격 검증
3. 신규 프로젝트 문서 템플릿 자동 주입

---

## 1. 왜 이 작업을 했나

다음 리스크를 줄이기 위해서다.

1. 문서/규칙 훼손을 늦게 발견해 복구 비용이 커지는 문제
2. 세션마다 로딩 상태가 달라져 같은 요청인데 결과가 달라지는 문제
3. 신규 프로젝트마다 `prj-docs` 구조가 제각각이 되는 문제

사고 사례 근거:
1. `skills/workspace-governance/references/guides/agent-incident-git-backup-restore-playbook.md`
2. 2026-02-07 사고에서 `main` 최신 포인터가 훼손 구간을 가리켜 대량 복구가 필요했음

핵심 목표는 "사고 후 복구"가 아니라 "사고 전 예방"이다.

---

## 2. 이번 변경에서 실제로 한 것

## 2.1 로컬 커밋 전 자동 검증 추가

파일:
- `./.githooks/pre-commit`

사고 예시:
1. 리로드 스크립트를 수정했지만 문법 오류를 놓친 채 커밋
2. 다음 세션에서 `session_start.sh`가 실패해 스킬/프로젝트 로딩이 깨짐

변경 내용:
1. `AGENTS.md`, `skills/**`, `workspace/**/prj-docs/PROJECT_AGENT.md` 변경이 스테이징되면 자동 검증 실행
2. `bash -n skills/bin/codex_skills_reload/*.sh`
3. `./skills/bin/codex_skills_reload/session_start.sh`
4. 정책 엔진 `skills/bin/validate-precommit-chain.sh`로 프로젝트별 규칙을 실행
5. 전역 규칙은 `skills/precommit/policies/*.sh`, 프로젝트 규칙은 `<project-root>/prj-docs/precommit-policy.sh`로 분리
6. 프로젝트 체인 검증은 기본 `quick`, 중요 커밋은 `strict`로 운영
7. `strict` 전환은 사용자 승인 후 수행하도록 운영 정책 고정
8. `strict`에서 정책 미커버 staged 경로는 실패 처리
9. `strict`에서 지식 문서 품질 토큰(Failure-First/Before&After/Execution Log)과 API 6-Step 토큰을 검증

미적용 시:
1. 로컬에서 막을 수 있는 오류가 원격까지 전파됨
2. 문제 발견 시점이 "커밋 전"이 아니라 "세션 시작 후"로 늦어짐

예방 목적:
1. 커밋 이전 실패 노출로 깨진 상태 유입 차단

## 2.2 원격 CI 검증 추가

파일:
- `.github/workflows/codex-skills-reload.yml`

사고 예시:
1. 로컬 환경에서는 통과하지만 클린 환경에서는 실패하는 변경이 merge됨
2. 이후 팀원이 pull 후 동일 스크립트 실행 시 실패

변경 내용:
1. push/PR 시 리로드 스크립트 문법 점검
2. `session_start.sh` 실행 검증
3. `.codex/runtime/*` 스냅샷 생성/형식 확인

미적용 시:
1. "내 로컬만 정상" 상태가 기준이 되어 품질 편차 누적
2. 장애가 리뷰 이후에 발견되어 롤백 비용 증가

예방 목적:
1. 원격 기준 공통 품질 게이트 확보

## 2.3 신규 프로젝트 문서 자동 초기화 추가

파일:
- `skills/bin/codex_skills_reload/init_project_docs.sh`

사고 예시:
1. 신규 프로젝트에서 `PROJECT_AGENT.md` 또는 `task.md`가 누락된 채 시작
2. Active Project 전환 후 로딩 기준이 불완전해 규칙 적용이 흔들림

변경 내용:
1. `prj-docs` 기본 폴더 자동 생성
2. `PROJECT_AGENT.md` 템플릿 자동 주입
3. `task.md`, `TODO.md`, `ROADMAP.md`, `rules/architecture.md` 기본 문서 생성

미적용 시:
1. 프로젝트마다 문서 시작점이 달라지고 누락 파일이 반복 발생
2. 온보딩/핸드오버 시 해석 비용 증가

예방 목적:
1. 신규 프로젝트 최소 운영 품질을 생성 시점에 강제

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
