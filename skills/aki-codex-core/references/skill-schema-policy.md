# Aki Skill Schema Policy

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-10 04:10:14`
> - **Updated At**: `2026-02-17 17:28:03`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 적용 범위
> - 최소 스키마
> - 섹션 이름 매핑
> - 메타 파일 규칙
> - 비-`aki` 스킬 위임 규칙
<!-- DOC_TOC_END -->

## 적용 범위
- 이 정책은 `skills/aki-*` 스킬에 적용한다.
- 외부/프로젝트 전용 스킬(`skills/java-spring-boot` 등)은 기본 적용 대상이 아니다.

## 최소 스키마
`aki-*` 스킬은 아래 정보를 문서에서 확인 가능해야 한다.
1. 목표(무엇을 해결하는지)
2. 경계(오케스트레이션/권한 분리 기준)
3. 실행 계약(입력/출력/실행 엔트리 또는 운영 대상)
4. 완료/검증 기준(성공/실패 또는 Done 판정)
5. 참고 경로(레퍼런스/스크립트)

## 섹션 이름 매핑
- 목표:
  - `목표`, `핵심 미션`, `Overview`
- 경계:
  - `오케스트레이션 경계`, `권한 경계`, `소유권 경계`
- 실행 계약:
  - `로컬 실행 계약`, `실행 대상`, `운영 대상`, `전용 도구 세트`, `실행 절차`
- 완료/검증:
  - `완료 정의`, `Done`, `산출물 규칙`, `결과 보고`
- 참고:
  - `참고 문서`, `리소스 안내`, `references/*`

## 메타 파일 규칙
1. `skills/aki-*` 스킬은 `agents/openai.yaml`을 기본 제공한다.
2. `agents/openai.yaml`은 최소 `display_name`, `short_description`을 포함한다.
3. 누락된 메타는 스키마 불완전으로 보고 보완한다.

## 비-`aki` 스킬 위임 규칙
1. 비-`aki` 스킬은 Active Project 요구가 있을 때만 사용한다.
2. 사용/검증/운영 기준은 Active Project의 `PROJECT_AGENT.md` + `task.md`에서 위임 관리한다.
3. 코어 전역 운영 지표(리로드/오케스트레이션/품질 게이트)는 `aki-*`를 기준으로 집계한다.
