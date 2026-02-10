# 에이전트 사고 시 Git 백업 및 복구 플레이북 (사례 포함)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-08 23:32:34`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 1. 사고 사례 요약 (먼저 읽기)
> - 2. 실제 타임라인 및 판단 근거
> - 3. 실제 복구 절차 (이번 사고에서 사용)
> - 4. 표준 백업 전략 (항상 적용)
> - 5. 장애 발생 시 복구 의사결정
> - 6. 작업 전 체크리스트
> - 7. 운영 메모
<!-- DOC_TOC_END -->

> Purpose: 에이전트 작업 중 문서/커밋이 훼손되었을 때, 사례를 먼저 읽고 즉시 복구할 수 있도록 표준 절차를 제공한다.
> Scope: GitHub Pages를 `main` 브랜치로 운영하는 본 저장소 기준.
> Last Updated: 2026-02-07

---

## 1. 사고 사례 요약 (먼저 읽기)

- 사고 일시: 2026-02-07 (KST)
- 현상:
  - 다수 문서가 축약/요약되며 상세 내용이 대량 삭제됨
  - `main` 최신 포인터가 정상 상태를 가리키지 않음
- 핵심 지표:
  - `workspace/apps/backend/ticket-core-service/prj-docs/knowledge/동시성-제어-전략.md`
  - 정상 구간: 639줄 (`b9775f6`, `dd782ec`)
  - 훼손 구간: 174줄 (`04940f7`)
- 결론:
  - 최신 포인터 유지형 복구가 아니라, `main` 자체를 정상 커밋으로 되돌리는 방식이 필요했음

---

## 2. 실제 타임라인 및 판단 근거

| 시각 (KST) | 커밋 | 판단 |
| :--- | :--- | :--- |
| 2026-02-07 04:34 | `b9775f6` | 상세 문서가 보존된 정상 지점 |
| 2026-02-07 06:06 | `dd782ec` | 정상 지점 (실제 복구 기준점으로 채택) |
| 2026-02-07 06:35 | `e657a6b` | 핵심 문서 분량 급감 시작 구간 |
| 2026-02-07 12:09 | `04940f7` | 훼손된 최신 포인터 |

판단 기준은 "메시지"가 아니라 실제 파일 내용/라인 수 비교다.

---

## 3. 실제 복구 절차 (이번 사고에서 사용)

### 3.1 사전 보전

먼저 복구 전에 모든 되돌리기 경로를 고정한다.

```bash
git reflog --date=iso --all
for h in $(git reflog --all --format='%H' | sort -u); do
  git update-ref "refs/backup/reflog/$h" "$h"
done
git branch recovery/current-04940f7 04940f7
git branch recovery/pre-summary-b9775f6 b9775f6
```

### 3.2 `main` 롤백

```bash
git switch main
git reset --hard dd782ec
git push --force-with-lease origin main
```

### 3.3 검증

```bash
git rev-parse --short main
git rev-parse --short origin/main
wc -l workspace/apps/backend/ticket-core-service/prj-docs/knowledge/동시성-제어-전략.md
wc -l workspace/apps/backend/ticket-core-service/prj-docs/api-specs/reservation-api.md
wc -l workspace/apps/backend/ticket-core-service/prj-docs/task.md
```

정상 기준:

- `main == origin/main`
- 동시성 제어 전략: 639줄
- reservation-api: 281줄
- task: 62줄

---

## 4. 표준 백업 전략 (항상 적용)

### 4.1 원칙

- 위험 작업 전에는 반드시 백업 브랜치 + 안정 태그를 동시에 만든다.
- 백업 포인트는 로컬만 두지 말고 원격에도 푸시한다.
- 백업 이름은 시간/의미/커밋을 포함해 사람이 즉시 판단 가능하게 한다.

### 4.2 표준 명령

```bash
./skills/aki-codex-core/scripts/create-backup-point.sh --label pre-work --push
```

생성 예시:

- 브랜치: `backup/20260207-124632-pre-work-dd782ec`
- 태그: `stable-20260207-124632-pre-work-dd782ec`

---

## 5. 장애 발생 시 복구 의사결정

### 5.1 1순위: `revert` (히스토리 보전)

이미 `main`에 병합된 변경이 문제지만 히스토리는 유지해야 할 때 사용.

```bash
git switch main
git revert -m 1 <merge_commit_sha>
git push origin main
```

### 5.2 2순위: 안정 태그로 강복구 (`reset --hard`)

최신 포인터 자체가 훼손되어 `main` 기준선을 즉시 되돌려야 할 때 사용.

```bash
git switch main
git reset --hard <stable-tag-or-commit>
git push --force-with-lease origin main
```

### 5.3 3순위: reflog 기반 포렌식 복구

안정 태그/브랜치가 없거나 판단이 어려우면, reflog와 파일 분량 비교로 정상 지점을 재선정한다.

---

## 6. 작업 전 체크리스트

- [ ] `main` 현재 해시 확인 (`git rev-parse --short main`)
- [ ] 백업 포인트 생성 (`create-backup-point.sh --push`)
- [ ] 핵심 문서 라인 수 스냅샷 확보 (`wc -l`)
- [ ] 작업 후 `git diff --stat`로 비정상 대량 삭제 여부 확인
- [ ] `main` 반영 전 복구 명령이 즉시 실행 가능한지 확인

---

## 7. 운영 메모

- 이 플레이북은 "에이전트 사고 대응" 전용이다.
- 기술 기능 버그(백엔드 로직 결함) 트러블슈팅 문서와 분리해 운영한다.
- 사례가 추가될 때마다 본 문서 하단에 날짜/커밋/복구 결과를 누적 기록한다.
