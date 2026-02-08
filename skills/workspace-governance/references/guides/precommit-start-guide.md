# Pre-commit Start Guide

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 00:54:04`
> - **Updated At**: `2026-02-09 01:38:36`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 1. 모드 지시 방법
> - 2. 내부 검사 흐름
> - 3. 모드별 검사 수준
> - 4. Ticket Core Service에서 strict 시 추가 검증
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
./skills/bin/precommit_mode.sh status
./skills/bin/precommit_mode.sh quick
./skills/bin/precommit_mode.sh strict
```

- 1회성 strict 강제:
```bash
CHAIN_VALIDATION_MODE=strict git commit -m "..."
```

---

## 2. 내부 검사 흐름

> [!TIP]
> 실제 pre-commit 훅은 아래 순서로 동작합니다.

1. staged 파일 확인 (`git diff --cached --name-only`)
2. `AGENTS.md`, `skills/*`, `*/prj-docs/PROJECT_AGENT.md` 변경 시:
   - `skills/bin/codex_skills_reload/*.sh` 문법 검사
   - `./skills/bin/codex_skills_reload/session_start.sh` 실행
3. 모드 결정:
   - `CHAIN_VALIDATION_MODE` 환경변수 우선
   - 없으면 `.codex/runtime/precommit_mode` 값 사용
   - 둘 다 없으면 `quick`
4. 정책 엔진 실행:
   - `skills/bin/validate-precommit-chain.sh --mode <quick|strict>`
   - 전역 정책: `skills/precommit/policies/*.sh`
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

## 4. Ticket Core Service에서 strict 시 추가 검증

> [!WARNING]
> 아래 조건 중 하나라도 불만족하면 커밋이 차단됩니다.

1. `build/`, `.gradle/` 산출물 staged 금지
2. `knowledge/*.md` 품질 토큰 검증
   - Failure-First
   - Before/After
   - Execution Log
3. `api-specs/*.md` 6-Step 토큰 검증
   - Endpoint / Description / Parameters / Request Example / Response Summary / Response Example
4. 프로젝트 기준선 존재 검증
   - `README.md`, `prj-docs/PROJECT_AGENT.md`, `prj-docs/task.md`, `prj-docs/meeting-notes/README.md`, `prj-docs/rules/`
5. 코드/설정/API 스크립트 변경 시 동반 문서 세트 staged 요구
   - `task.md`, `api-specs/*.md`, `knowledge/*.md`, `scripts/http/*.http`, `scripts/api/*.sh`
6. 신규 문서 추가 시 `sidebar-manifest.md` 동시 staged 요구
7. 런타임 API 스크립트 변경 시:
   - `scripts/api/run-api-script-tests.sh` 실제 실행
   - `prj-docs/api-test/latest.md` 최신 리포트 staged 및 최신 상태 요구

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
./skills/bin/precommit_mode.sh strict
git commit -m "..."
./skills/bin/precommit_mode.sh quick
```
