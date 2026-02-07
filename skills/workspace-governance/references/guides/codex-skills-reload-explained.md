# Codex Skills Reload 이해 가이드

> 대상: "왜 이걸 하는지"가 아직 헷갈리는 사용자/운영자  
> 목적: 개념 설명 + 실사용 기준을 한 번에 이해하기

---

## 0. 한눈에 요약

이 작업은 "세션이 바뀌어도, 에이전트가 같은 규칙/같은 프로젝트 컨텍스트로 시작하게 만드는 안전장치"다.

핵심은 3가지다.
1. `pre-commit`: 잘못된 상태를 커밋 전에 차단
2. `CI`: 원격에서도 같은 검증을 재실행
3. `init_project_docs.sh`: 신규 프로젝트 문서 구조를 표준 템플릿으로 자동 생성

---

## 1. 이 작업이 정확히 무엇인가

`skills/bin/codex_skills_reload/session_start.sh`를 중심으로,
세션 시작 시점에 아래를 다시 맞춘다.

1. 어떤 스킬이 로드되어야 하는지
2. 어떤 프로젝트가 Active Project인지
3. 현재 상태를 어떤 파일로 보고할지

결과는 `.codex/runtime/` 아래 3개 스냅샷으로 남는다.
1. `codex_skills_reload.md`
2. `codex_project_reload.md`
3. `codex_session_start.md`

---

## 2. 왜 필요한가 (실무 관점)

아래 사고를 막기 위해 필요하다.

1. 세션 전환 후 이전 대화 맥락이 끊겨 규칙이 누락되는 문제
2. 멀티 프로젝트에서 잘못된 프로젝트 규칙이 섞이는 문제
3. 스크립트/경로 변경 후 검증 없이 커밋되어 다음 세션에서 깨지는 문제

즉, "사고가 나도 빨리 복구"가 아니라, "사고 자체를 사전에 줄이는" 목적이다.

---

## 3. 이번에 적용된 1/2/3 의미

## 3.1 `pre-commit` 훅

파일: `./.githooks/pre-commit`

역할:
1. 스테이징 파일에 `AGENTS.md`, `skills/**`, `PROJECT_AGENT.md` 변경이 있으면 자동 점검
2. `bash -n skills/bin/codex_skills_reload/*.sh` 실행
3. `./skills/bin/codex_skills_reload/session_start.sh` 실행

효과:
1. 깨진 상태의 커밋이 로컬에서 먼저 차단된다.

## 3.2 GitHub Actions CI

파일: `.github/workflows/codex-skills-reload.yml`

역할:
1. push/PR에서 동일 검증 반복
2. 런타임 스냅샷 생성 여부까지 확인

효과:
1. "내 로컬은 됐는데 원격은 실패"를 줄인다.

## 3.3 신규 프로젝트 자동 초기화

파일: `skills/bin/codex_skills_reload/init_project_docs.sh`

역할:
1. `prj-docs` 필수 골격 생성
2. `PROJECT_AGENT.md`를 템플릿에서 자동 주입
3. `task.md`, `TODO.md`, `ROADMAP.md`, `rules/architecture.md` 자동 생성

효과:
1. 프로젝트마다 문서 편차가 줄어든다.
2. 새 프로젝트 시작 품질이 균일해진다.

---

## 4. 언제 무엇을 실행하면 되는가

## 4.1 세션 시작

자동(권장):
- `AGENTS.md만 읽고 시작해`
- `AGENTS.md 확인해줘`

수동:
```bash
./skills/bin/codex_skills_reload/session_start.sh
```

## 4.2 세션 진행 중 (스킬 수정/추가 후)

자동(권장):
- `스킬스 리로드해줘`

수동:
```bash
./skills/bin/codex_skills_reload/session_start.sh
```

## 4.3 신규 프로젝트 만들 때

```bash
./skills/bin/codex_skills_reload/init_project_docs.sh workspace/apps/<domain>/<service>
./skills/bin/codex_skills_reload/set_active_project.sh workspace/apps/<domain>/<service>
./skills/bin/codex_skills_reload/session_start.sh
```

---

## 5. 안 하면 어떤 일이 생기나

1. 세션마다 적용 규칙이 달라져 결과가 흔들릴 수 있다.
2. 잘못된 프로젝트를 대상으로 작업할 가능성이 커진다.
3. 리로드 스크립트가 깨진 채 커밋되어 나중에 더 큰 비용으로 복구하게 된다.
4. 신규 프로젝트마다 문서 구조가 달라져 유지보수 비용이 증가한다.

---

## 6. 문제 생기면 이렇게 복구

1. 훅 경로 확인
```bash
git config --get core.hooksPath
```
기대값: `.githooks`

2. 스크립트 문법 확인
```bash
bash -n skills/bin/codex_skills_reload/*.sh
```

3. 세션 상태 재생성
```bash
./skills/bin/codex_skills_reload/session_start.sh
```

4. 상태 문서 확인
```bash
cat .codex/runtime/codex_session_start.md
```

---

## 7. 관련 문서

1. 운영 기준 상세: `skills/workspace-governance/references/guides/codex-skills-reload-operations-manual.md`
2. 세션 진입 규칙: `AGENTS.md`
