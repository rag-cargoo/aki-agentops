# Meeting Notes: Manual Content Restoration and Rule Promotion

## 안건 1: `00` 제출 개요 내용 보강
- Created At: 2026-04-28 03:05:00
- Updated At: 2026-04-28 03:05:00
- Status: DONE
- 검토사항:
  - `00-제출-매뉴얼-개요.md`에 AWS를 왜 이런 방식으로 쓰는지, Markdown을 왜 원본으로 두는지 설명이 약해지면 제출 서문 역할이 약해진다.
- 결정사항:
  - `00` 개요에는 AWS air-gap simulation 이유, Terraform 분리 이유, Markdown 원본 이유를 다시 명시한다.
  - `00`은 제출본 서문 역할을 유지한다.

## 안건 2: 매뉴얼/태스크 규칙을 sidecar rule로 승격할지 결정
- Created At: 2026-04-28 03:05:00
- Updated At: 2026-04-28 03:05:00
- Status: DONE
- 검토사항:
  - 매뉴얼 작성 규칙과 task 생성 규칙이 `00` 문서에만 있으면 운영 기준으로 약하다.
  - 이 규칙은 제출본 설명이 아니라 sidecar 운영 규칙에 가깝다.
- 결정사항:
  - 매뉴얼/태스크/회의록 정렬 기준은 `rules/manual-task-governance.md`로 승격한다.
  - `00` 개요는 요약과 설명만 남기고, 운영 기준의 권위 소스는 새 rule 문서로 둔다.
