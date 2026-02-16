# Pre-commit Start Guide

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 00:54:04`
> - **Updated At**: `2026-02-17 06:03:20`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 1. 모드 지시 방법
> - 2. 내부 검사 흐름
> - 3. 모드별 검사 수준
> - 4. strict 시 추가 검증(현재 기준)
> - 5. 커밋 성공 조건
> - 6. 실무 권장 패턴
<!-- DOC_TOC_END -->

이 문서는 코덱스 에이전트에게 `quick/strict` 커밋 모드를 지시했을 때 무엇이 어떻게 실행되는지 빠르게 설명합니다.

---

## 1. 모드 지시 방법

> [!NOTE]
> 사용자가 자연어로 모드를 말하면, 에이전트가 해당 모드로 커밋 체인을 수행합니다.

- 예시 지시:
  - `퀵 모드로 커밋해줘`
  - `스트릭트 모드로 커밋해줘`

- 수동 명령:
```bash
git config core.hooksPath .githooks
./skills/aki-codex-precommit/scripts/precommit_mode.sh status
./skills/aki-codex-precommit/scripts/precommit_mode.sh quick
./skills/aki-codex-precommit/scripts/precommit_mode.sh strict
```

- 1회성 strict 강제:
```bash
CHAIN_VALIDATION_MODE=strict git commit -m "..."
```

- 원격 상태 동기화 포함 strict 점검(수동):
```bash
./skills/aki-codex-precommit/scripts/validate-precommit-chain.sh --mode strict --all --strict-remote
```

---

## 2. 내부 검사 흐름

> [!TIP]
> 실제 pre-commit 훅은 아래 순서로 동작합니다.

1. staged 파일 확인 (`git diff --cached --name-only`)
2. `AGENTS.md`, `skills/*`, `*/prj-docs/PROJECT_AGENT.md` 변경 시:
   - `skills/aki-codex-session-reload/scripts/codex_skills_reload/*.sh` 문법 검사
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh` 실행
3. 모드 결정:
   - `CHAIN_VALIDATION_MODE` 환경변수 우선
   - 없으면 `.codex/runtime/precommit_mode` 값 사용
   - 둘 다 없으면 `quick`
4. 정책 엔진 실행:
   - `skills/aki-codex-precommit/scripts/validate-precommit-chain.sh --mode <quick|strict>`
   - 전역 정책: `skills/aki-codex-precommit/policies/*.sh`
   - 프로젝트 정책: `<project-root>/prj-docs/precommit-policy.sh`

---

## 3. 모드별 검사 수준

> [!NOTE]
> `quick`은 일상 커밋, `strict`는 마일스톤/릴리즈 직전 커밋에 사용합니다.

- quick:
  - 경량 검증 중심
  - 실패보다는 힌트/경고 중심 (예: strict에서 필요할 파일군 안내)

- strict:
  - 정책 미커버 staged 경로가 있으면 실패
  - 스크립트 문법/정책 강검증
  - 프로젝트 정책의 품질 규칙까지 함께 검증

---

## 4. strict 시 추가 검증(현재 기준)

> [!WARNING]
> strict 모드에서는 아래 검증이 활성화됩니다.

1. 정책 미커버 staged 경로 차단
2. `.githooks/*.sh`, `skills/**/*.sh`, `mcp/manifest/**/*.sh` 문법 검사
3. `AGENTS.md`/`skills/*`/`*/prj-docs/PROJECT_AGENT.md`/`project-map.yaml` 변경 시 session reload 검증
4. temp-like 산출물(`*.log`, `*.tmp`, 대시보드 HTML/PNG)이 `.codex/tmp/` 밖에서 stage되면 warning 출력
5. `--strict-remote` 사용 시 `task.md`/`meeting-notes/*.md`의 Issue/PR 원격 상태와 TODO/DOING/[ ] 충돌을 검사

---

## 5. 커밋 성공 조건

> [!TIP]
> 아래가 모두 만족되면 최종 커밋이 생성됩니다.

1. pre-commit 훅의 스킬 리로드 검증 통과
2. 정책 엔진(`validate-precommit-chain.sh`) 통과
3. strict일 경우 정책 미커버 경로/품질 규칙/실행 리포트 조건까지 통과

---

## 6. 실무 권장 패턴

1. 평소: `quick` 유지
2. 중요 커밋 직전: 사용자 승인 후 `strict` 전환
3. strict 커밋 완료 후: 기본 모드 `quick` 복귀

```bash
./skills/aki-codex-precommit/scripts/precommit_mode.sh strict
git commit -m "..."
./skills/aki-codex-precommit/scripts/precommit_mode.sh quick
```
