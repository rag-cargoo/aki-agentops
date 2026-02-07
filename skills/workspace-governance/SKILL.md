---
name: workspace-governance
description: |
  워크스페이스 전역 거버넌스 및 개발 표준 수호 스킬.
  프로젝트 구조 관리 및 문서 전문 작업을 github-pages-expert에 위임합니다.
  (최신 업데이트: 2026-02-07 16:02:15 | session_start 기반 리로드/보고 규칙 강화)
---

# 워크스페이스 전역 거버넌스 (Global Governance)

이 스킬은 워크스페이스 내 모든 프로젝트의 일관된 품질과 거버넌스를 보장합니다.

##  핵심 5대 원칙 (Core Principles)

1. **실시간 버전 증명 (Real-time Versioning)**: 스킬 지침 수정 시, 반드시 `description`의 타임스탬프를 **현재의 실제 시간(YYYY-MM-DD HH:mm:ss)**으로 즉시 갱신하여 로드된 지식의 최신성을 보장한다.
2. **데이터 무결성 절대 사수**: 기존 파일 수정 시 `write_file` 사용 금지, `replace` 도구 활용.
3. **문서 전문성 위임**: 시각적 스타일링 및 무손실 복구 작업은 `github-pages-expert`에 위임.
4. **하드코딩 금지**: 모든 설정은 환경 변수나 설정 파일을 통해 주입.
5. **계층 구조 엄수**: 패키지 경계(`api`, `domain`, `global`)를 엄격히 유지.

##  완료 정의 (Definition of Done)
에이전트는 모든 작업을 마무리하기 전 아래 3단계를 완수했는지 스스로 검증해야 한다.
- **구현**: 코딩 표준(하드코딩 금지 등)을 준수하여 로직을 완성했는가?
- **검증**: `scripts/api/`의 테스트 스크립트를 실행하고 결과 로그를 확보했는가?
- **문서화**: 지식 문서(Failure-First 적용)와 API 명세(6단계 표준)를 현행화했는가?

##  작업 워크플로우
- 1단계: 타임스탬프 갱신을 통한 최신 지식 장착 증명.
- 2단계: `github-pages-expert`를 통한 문서 무결성 확보.
- 3단계: [코드+문서+테스트] 패키지 완결성 검증.

##  세션 시작 가이드
- "스킬스 리로드해줘" 요청 시, `./skills/bin/codex_skills_reload/session_start.sh`를 실행하고 `workspace/codex_session_start.md` 기준으로 아래를 보고해야 합니다.
- `Startup Checks` (Skills Snapshot / Project Snapshot / Skills Bin Integrity)
- `Loaded Skills` 전체 목록
- `Active Project` 정보와 멀티 프로젝트 전환 안내
