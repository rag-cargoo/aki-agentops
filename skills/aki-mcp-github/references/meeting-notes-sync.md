# Meeting Notes Sync Flow

## 목표
- 회의록의 실행 항목을 GitHub 이슈/프로젝트/PR 추적으로 일관되게 반영한다.
- 세션마다 동일 절차로 동작해 누락/중복을 줄인다.

## 입력 형식
- 입력 파일: `workspace/**/prj-docs/meeting-notes/*.md`
- 최소 필드:
  1. 안건 제목
  2. 상태(`TODO|DOING|DONE`)
  3. 결정사항
  4. 후속작업(담당/기한/상태)
- 여러 파일이 있으면 최신 날짜 파일을 기본 대상으로 선택한다.

## 사전 조건
1. GitHub MCP 서버 연결
2. 필요 toolset 준비(`context`, `repos`, `issues`, `projects`, `pull_requests`, `labels`)
3. 대상 저장소(owner/repo) 확정

## 실행 절차
1. 회의록에서 안건 단위를 파싱하고 실행 가능한 후속작업을 추출한다.
2. 항목별 기존 이슈/PR 중복 여부를 검색한다.
3. 같은 범위 이슈가 있으면 기존 이슈를 갱신하고, closed면 reopen 후 갱신한다.
4. 같은 범위가 없을 때만 새 이슈를 생성한다(예외 경로).
5. 새 이슈 생성 시 "기존 이슈 재오픈이 아닌 이유"를 코멘트/PR 본문에 남긴다.
6. 라벨 정책을 적용한다(없으면 생성, 있으면 재사용).
7. 프로젝트를 사용할 경우 생성/갱신 이슈를 프로젝트 상태와 동기화한다.
8. PR 링크가 있으면 이슈-PR 상호 참조를 정리한다.
9. 회의록 원문에 Issue/PR 링크를 역기록한다.

## 매핑 규칙
1. `TODO`:
   - 기본: 기존 이슈 재개/갱신 우선, 없으면 생성(open)
2. `DOING`:
   - 기본: Issue 유지(open) + 진행 코멘트/상태 갱신
3. `DONE`:
   - PR merge 완료 시 Issue close
   - PR 미완료 시 close 보류 + 검증 대기 라벨

## 정책/도구
1. 라이프사이클 정책:
   - `references/issue-lifecycle-policy.md`
2. 업서트 스크립트:
   - `skills/aki-mcp-github/scripts/issue-upsert.sh`

## 결과 보고
1. 입력 회의록 파일 경로
2. 생성/갱신/종료된 Issue 목록
3. 연결/갱신된 PR 목록
4. 프로젝트 반영 결과
5. 실패 항목과 재시도 필요 작업
