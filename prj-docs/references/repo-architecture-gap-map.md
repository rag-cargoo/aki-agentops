# Repository Architecture Gap Map (AKI AgentOps)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 06:03:20`
> - **Updated At**: `2026-02-17 17:14:21`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Gap Map (4축 진단)
> - Phase Rollout
<!-- DOC_TOC_END -->

## Scope
- 본 문서는 `AKI AgentOps` 루트 저장소(구 명칭: `2602`) 아키텍처 진단 결과를 4축으로 정리한다.
- 제품 코드 품질 이슈가 아니라 `레포 경계/운영 방식` 갭을 다룬다.

## Gap Map (4축 진단)

| 진단 축 | 현행 구조 | 문제 근거 | 목표 구조 | 전환 리스크 |
| --- | --- | --- | --- | --- |
| 경계(Repository vs Project) | `AKI AgentOps`가 운영 허브 + 일부 프로젝트 경로를 함께 다룸 | 제품 코드와 거버넌스 변경이 같은 리뷰/훅 컨텍스트에 섞이기 쉬움 | 제품 코드는 독립 레포, `AKI AgentOps`는 sidecar 문서/운영 스크립트 전용 | 경계 전환 중 잘못된 커맨드 대상(`git/gh`)으로 오조작 가능 |
| 문서/내비게이션 | 루트 문서와 프로젝트 문서가 혼재, sidecar 전환 도중 경로 변동 | 구 경로 고정 검사로 CI 실패(`doc-state-sync` 404) 사례 발생 | `project-map.yaml`의 `code_root/docs_root/repo_remote`를 단일 기준으로 사용 | 링크 불일치 시 문서 탐색 단절, 릴리즈 체크 혼선 |
| 운영 자동화 | pre-commit/pre-push가 과거 프로젝트 경로를 참조하던 잔여 규칙 존재 | `strict-remote` 인터페이스 대비 실검증 연결 누락 상태 확인 | 공통 스크립트(`skills/aki-codex-precommit/scripts/check-doc-remote-sync.sh`)로 통일 | 강검증 도입 시 기존 문서 누적 불일치가 한 번에 노출될 수 있음 |
| 실행 책임 | 운영 문서와 제품 구현 작업의 승인/이슈 흐름이 분리 기준 미약 | 같은 범위 후속 작업의 이슈 재사용/재오픈 규칙이 누락되면 추적 단절 | umbrella 이슈 + sidecar task 누적 + 제품 레포 이슈/PR 링크 동기화 | 책임 경계가 문서에만 있고 운영 습관이 따라오지 않으면 재혼합 재발 |

## Phase Rollout
1. Phase A (완료): `ticket-core-service` 외부 레포 분리 + sidecar `docs_root` 도입.
2. Phase B (완료): `strict-remote` 공통 검증 스크립트 도입 및 pre-push 훅 경로 결함 제거.
3. Phase C (진행): 문서 템플릿 `External Sync` 강제와 운영 runbook 확정.
4. Phase D (완료): `safe-git`/`safe-gh` 래퍼 도입 + CI 책임 분리 규칙 runbook 고정.
