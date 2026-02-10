# Skill Naming Policy

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 09:43:13`
> - **Updated At**: `2026-02-09 16:20:00`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 적용 범위
> - 기본 규칙
> - 예외 규칙
> - 자동 점검
> - 신규 스킬 생성 체크리스트
<!-- DOC_TOC_END -->

> [!NOTE]
> 사용자 제작 스킬의 이름 충돌을 방지하고 출처를 명확히 하기 위한 기준 문서.

## 적용 범위
- 저장소 내 `skills/<skill-name>/SKILL.md` 구조를 따르는 로컬 스킬
- 세션 로더(`session_start.sh`)로 로드되는 스킬 목록 전체

## 기본 규칙
1. 사용자 제작 스킬은 디렉토리 이름에 `aki-` prefix를 사용한다.
2. `SKILL.md`의 `name:` 필드는 디렉토리 이름과 동일하게 유지한다.
3. 역할이 드러나는 명사형 이름을 사용한다.

## 예외 규칙
1. 외부/시스템 스킬은 원래 이름을 유지한다.
   - `find-skills`
   - `skill-creator`
   - `skill-installer`
2. 레거시 공용 스킬은 호환성 목적의 예외로 허용한다.
   - `java-spring-boot`

## 자동 점검
1. 명령:
   - `./skills/aki-codex-core/scripts/check-skill-naming.sh`
   - 소스: `skills/aki-codex-core/scripts/check-skill-naming.sh`
2. 정책:
   - `aki-` prefix 미준수 스킬이 예외 목록에 없으면 실패(exit 1)
3. pre-commit 연동:
   - `skills/aki-codex-precommit/policies/core-workspace.sh`가 스킬 변경 시 자동 호출

## 신규 스킬 생성 체크리스트
1. `skill-creator`로 스킬 골격 생성
2. 디렉토리/`name:`를 `aki-<skill-name>` 규칙으로 정렬
3. `./skills/aki-codex-core/scripts/check-skill-naming.sh` 실행
4. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh` 실행 후 로드 결과 확인
