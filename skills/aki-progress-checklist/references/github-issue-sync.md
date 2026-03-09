# GitHub Issue Sync Flow

## 목적
- 로컬 체크리스트 진행 상태를 GitHub issue 코멘트에 누적/갱신한다.
- 동일 이슈에서 중복 코멘트 스팸을 줄이기 위해 `upsert`를 기본값으로 사용한다.

## 입력 파일 권장 포맷
- checklist 파일(`--checklist-file`):

```md
- [x] API 계약 확인
- [x] Admin 폼 수정
- [~] 회귀 테스트
- [ ] 배포 확인
```

- verification 파일(`--verification-file`, optional):

```md
- npm run lint: pass
- npm run typecheck: pass
- npm run build: pass
```

- evidence 파일(`--evidence-file`, optional):

```md
- commit: abcdef1
- frontend image tag: 20260302230358
- deploy target: i-04f003f8cf4c65b44
```

## 실행 예시
```bash
skills/aki-progress-checklist/scripts/checklist-issue-sync.sh \
  --repo rag-cargoo/ticket-web-app \
  --issue 31 \
  --checklist-file /tmp/checklist.md \
  --verification-file /tmp/verify.md \
  --evidence-file /tmp/evidence.md \
  --summary "Admin CRUD form redesign + OAuth fallback"
```

## 모드
- `--mode upsert`(default):
  - 내 계정이 남긴 marker 코멘트가 있으면 수정
  - 없으면 신규 코멘트 생성
- `--mode append`:
  - 항상 새 코멘트 생성

## 운영 주의
1. `gh` CLI 로그인(`gh auth status`)이 필요하다.
2. `--repo` 미지정 시 현재 git remote 기준 저장소를 사용한다.
3. marker 문자열은 동일 유지가 권장된다.
