# Progress Checklist Template

## Kickoff
- [ ] Scope and constraints 확인
- [ ] 관련 파일/로그 탐색
- [ ] 변경 설계 확정
- [ ] 코드 수정
- [ ] 검증(`lint/typecheck/build`) 실행
- [ ] 결과 보고(변경/검증/리스크)

## Mid-Progress Update
- 현재 단계: `[~] <step>`
- 방금 완료: `[x] <step>`
- 다음 단계: `[ ] <step>`
- 이슈/리스크: `<none | blocked reason>`

## Completion Summary
- 최종 상태:
  - [x] Scope and constraints 확인
  - [x] 관련 파일/로그 탐색
  - [x] 변경 설계 확정
  - [x] 코드 수정
  - [x] 검증 실행
  - [x] 결과 보고
- 검증 결과:
  - `npm run lint`: pass
  - `npm run typecheck`: pass
  - `npm run build`: pass
- 증빙:
  - 변경 파일: `<path list>`
  - 커밋: `<hash>`
  - 배포: `<tag/url>`
