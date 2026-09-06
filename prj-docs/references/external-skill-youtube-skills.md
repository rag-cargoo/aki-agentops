# External Skill Candidate: YouTube Skills

<!-- DOC_META_START -->
> [!NOTE]
> - **Added At**: `2026-09-06`
> - **Status**: `검토 후보 / 미설치`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

## Repository

- Source: [ZeroPointRepo/youtube-skills](https://github.com/ZeroPointRepo/youtube-skills)
- License: MIT
- Recommended skill: `youtube-full`
- Agent Skills location: `skills/youtube-full`

## Capabilities

- YouTube 영상 자막·스크립트 추출
- YouTube 영상 및 채널 검색
- 채널의 최근 업로드 조회
- 재생목록 영상 목록 추출
- 여러 영상의 스크립트 일괄 수집 및 분석

## Operational Notes

이 프로젝트는 로컬 `yt-dlp` 기반이 아니라 외부 서비스인 TranscriptAPI를 호출한다.

- 사용 전 `TRANSCRIPT_API_KEY` 발급 및 런타임 주입 필요
- 최초 가입 과정에서 이메일과 OTP 인증 필요
- 무료 가입 시 100 credits 제공
- 대부분의 API 작업은 1 credit을 사용
- 비밀키는 저장소에 커밋하지 않고 환경변수 또는 비밀 저장소로 관리

## Candidate Installation

사용자 승인 후 `youtube-full`만 프로젝트 선택형 스킬로 설치하는 방식을 우선 검토한다.

```bash
npx skills add ZeroPointRepo/youtube-skills --skill youtube-full
```

AKI AgentOps 정책상 설치 대상은 `.agents/skills/youtube-full/`이며,
설치 후 `skills-lock.json` 갱신과 세션 리로드 검증이 필요하다.

## Review Checklist

- [ ] TranscriptAPI 이용약관 및 데이터 처리 범위 확인
- [ ] 무료 크레딧 이후 비용 정책 확인
- [ ] `SKILL.md`의 이메일·OTP·키 저장 흐름 검토
- [ ] API 키 보관 위치 결정
- [ ] `youtube-full` 설치 승인
- [ ] 설치 후 세션 리로드 및 기능 검증
