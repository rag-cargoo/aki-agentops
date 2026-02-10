# 코어 스킬 리팩터링 브랜치 안전 체크포인트 (Checkpoint)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 09:49:46`
> - **Updated At**: `2026-02-09 17:53:22`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 목적
> - 작업 범위
> - 체크포인트 게이트
> - 비채택 구조 원칙
> - skill-creator 생성 규칙
> - 완료 기록 규칙
<!-- DOC_TOC_END -->

> [!NOTE]
> `feature/core-skills-refactor` 브랜치에서 코어 스킬 분해/이관 작업을 수행할 때 적용하는 안전 기준 문서.

## 목적
- 브랜치 단위 리팩터링에서 범위 이탈, 구조 충돌, 기록 누락을 예방한다.
- 코어 스킬 분해 작업을 병합 가능한 상태로 유지한다.

## 작업 범위
1. 기준 브랜치:
   - `feature/core-skills-refactor`
2. 주요 인스코프 경로:
   - `skills/aki-codex-*/**`
   - `skills/aki-github-pages-expert/**`
   - `sidebar-manifest.md`
   - `workspace/agent-skills/codex-runtime-engine/prj-docs/meeting-notes/**`
   - `workspace/agent-skills/codex-runtime-engine/prj-docs/task.md`
3. 아웃오브스코프 기본값:
   - `workspace/apps/**` 런타임 코드/도메인 로직
   - 코어 분해와 무관한 외부 스킬 구조 변경

## 체크포인트 게이트
1. 브랜치/백업 게이트:
   - `git status --short`
   - `git rev-parse --abbrev-ref HEAD`로 브랜치 확인
   - 위험 작업 전 `./skills/aki-codex-core/scripts/create-backup-point.sh pre-change-core-skills-refactor`
2. 구조 게이트:
   - 중첩 스킬 디렉토리 금지 확인
   - 점검 예시: `find skills -type d -path 'skills/*/skills/*'`
3. 품질 게이트:
   - `./skills/aki-codex-core/scripts/check-skill-naming.sh`
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
   - `bash skills/aki-codex-precommit/scripts/validate-precommit-chain.sh --mode quick`
   - `bash skills/aki-codex-precommit/scripts/validate-precommit-chain.sh --mode strict`
4. 링크/문서 게이트:
   - `sidebar-manifest.md` 링크 동기화
   - 회의록 + `task.md` 역기록
   - 이슈 코멘트/라벨 상태 동기화

## 비채택 구조 원칙
1. `skills/<hub>/skills/<module>` 형태의 중첩 구조는 채택하지 않는다.
2. 로더가 인식하는 단위(`skills/<skill-name>/SKILL.md`)와 일치하는 평면 구조를 유지한다.
3. 책임 분리는 디렉토리 중첩이 아니라 스킬 분리 + 문서 링크로 해결한다.

## skill-creator 생성 규칙
1. 신규 스킬은 `skill-creator` 기반으로 시작한다.
2. `scripts/`, `references/`, `assets/`는 필요 범위만 채택한다.
   - `scripts/`: 반복 실행 로직이 실제로 존재할 때만 유지
   - `references/`: `SKILL.md`에 담기 어려운 상세 런북이 있을 때만 유지
   - `assets/`: 재사용 템플릿/정적 자산이 있을 때만 유지
3. 생성 후 미사용 디렉토리는 커밋 전 제거한다.

## 완료 기록 규칙
1. 회의록 안건의 `상태`/`진행기록`을 갱신한다.
2. `task.md`의 `현재 완료`/`다음 작업`을 정리한다.
3. GitHub 이슈에 결과 코멘트를 남기고 `status:done` + close 처리한다.
