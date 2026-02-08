---
name: workspace-governance
description: |
  워크스페이스 전역 거버넌스 및 개발 표준 수호 스킬.
  프로젝트 구조 관리 및 문서 전문 작업을 github-pages-expert에 위임합니다.
  (최신 업데이트: 2026-02-08 23:06:35 | 문서 메타(생성/수정 시각) 및 상단 목차 표준 추가)
---

# 워크스페이스 전역 거버넌스 (Global Governance)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-08 23:32:34`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 핵심 5대 원칙 (Core Principles)
> - 완료 정의 (Definition of Done)
> - 작업 워크플로우
> - 세션 시작 가이드
> - pre-commit 운영 원칙
<!-- DOC_TOC_END -->

이 스킬은 워크스페이스 내 모든 프로젝트의 일관된 품질과 거버넌스를 보장합니다.

##  핵심 5대 원칙 (Core Principles)

1. **실시간 버전 증명 (Real-time Versioning)**: 스킬 지침 수정 시, 반드시 `description`의 타임스탬프를 **현재의 실제 시간(YYYY-MM-DD HH:mm:ss)**으로 즉시 갱신하여 로드된 지식의 최신성을 보장한다.
2. **데이터 무결성 절대 사수**: 기존 파일 수정 시 전체 덮어쓰기보다 `apply_patch` 기반 부분 수정을 우선하고, 필요 시 shell 치환 후 diff로 무결성을 확인한다.
3. **문서 전문성 위임**: 시각적 스타일링 및 무손실 복구 작업은 `github-pages-expert`에 위임.
4. **하드코딩 금지**: 모든 설정은 환경 변수나 설정 파일을 통해 주입.
5. **계층 구조 엄수**: 패키지 경계(`api`, `domain`, `global`)를 엄격히 유지.
6. **문서 추적성 필수**: 관리 대상 문서는 상단에 `Created At`/`Updated At`과 상단 목차를 유지하고, 변경 시 `Updated At`을 즉시 갱신한다.

##  완료 정의 (Definition of Done)
에이전트는 모든 작업을 마무리하기 전 아래 3단계를 완수했는지 스스로 검증해야 한다.
- **구현**: 코딩 표준(하드코딩 금지 등)을 준수하여 로직을 완성했는가?
- **검증**: 실제 존재하는 프로젝트 테스트 명령(예: `make test`, `./gradlew test`) 또는 동등한 CI 검증을 실행하고 결과를 확인했는가?
- **문서화**: 지식 문서(Failure-First 적용)와 API 명세(6단계 표준)를 현행화했는가?

##  작업 워크플로우
- 1단계: 타임스탬프 갱신을 통한 최신 지식 장착 증명.
- 2단계: `github-pages-expert`를 통한 문서 무결성 확보.
- 3단계: [코드+문서+테스트] 패키지 완결성 검증.

##  세션 시작 가이드
- "스킬스 리로드해줘" 요청 시, `./skills/bin/codex_skills_reload/session_start.sh`를 실행하고 `.codex/runtime/codex_session_start.md` 기준으로 아래를 보고해야 합니다.
- `Startup Checks` (Skills Snapshot / Project Snapshot / Skills Bin Integrity)
- `Loaded Skills` 전체 목록
- `Active Project` 정보와 멀티 프로젝트 전환 안내

##  pre-commit 운영 원칙
- 기본 모드는 `quick`이며, 일상 커밋에서 개발 속도를 우선한다.
- 중요 커밋(마일스톤/릴리즈/대규모 리팩토링 완료)은 사용자 확인 후 `strict` 모드로 전환해 강한 체인 검증을 수행한다.
- 모드 전환은 `skills/bin/precommit_mode.sh` 또는 `CHAIN_VALIDATION_MODE=strict git commit ...`로 수행한다.
- 프로젝트별 strict 규칙은 `<project-root>/prj-docs/precommit-policy.sh`에 등록하며, `strict`에서 정책 미커버 경로가 있으면 커밋을 차단한다.
- 작업 완료 보고에는 반드시 `현재 pre-commit 모드`와 `모드 변경 명령`을 함께 안내한다.
