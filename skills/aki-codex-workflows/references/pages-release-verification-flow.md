# Pages Release Verification Flow

## When
- `develop -> main` 병합 직전
- 문서 구조/사이드바/링크 변경이 포함된 릴리즈 직전

## Why
- 메인 전환 전에 문서 사이트 배포 리스크(404/깨짐/소스 브랜치 오설정)를 차단한다.
- 릴리즈 시점에 Pages 상태를 객관적으로 판정한다.

## Order
1. 배포 기준 브랜치 점검
   - Owner Skill: `aki-codex-workflows`
   - 현재 Pages source branch/path와 릴리즈 대상 브랜치를 확인한다.
2. 사이드바/문서 링크 정합성 점검
   - Owner Skill: `aki-github-pages-expert`
   - `github-pages/sidebar-manifest.md` 링크와 문서 경로 무결성을 점검한다.
3. 배포 상태 확인
   - Owner Skill: `aki-mcp-github` (`repos` context)
   - Pages 상태(`built`/오류)를 확인한다.
4. 주요 문서 접근 확인
   - Owner Skill: `aki-github-pages-expert`
   - 핵심 엔트리(README, SKILLS, Active Project 문서) 접근성/404를 검증한다.
5. 릴리즈 Go/No-Go 판정
   - Owner Skill: `aki-codex-workflows`
   - 판정과 보류 사유를 명시해 보고한다.

## Condition
- Pages 상태가 `built`가 아니면:
  - 기본 정책 `Stop`으로 릴리즈 보류
- 링크 깨짐/404가 발견되면:
  - 수정 후 재검증(`Retry`) 완료 전 병합 금지
- source branch 전환이 필요한 경우:
  - 전환 전/후 상태를 모두 기록한다.

## Done
- Completion:
  - 릴리즈 전 Pages 배포 검증 절차 전체 수행
- Verification:
  - Pages 상태 정상 + 핵심 링크 접근 성공 + 사이드바 정합성 통과
- Evidence:
  - Pages 상태 조회 결과
  - 링크 점검 결과
  - Go/No-Go 판정 로그
