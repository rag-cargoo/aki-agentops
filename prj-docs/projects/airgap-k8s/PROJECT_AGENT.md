# Project Agent: Airgap K8s (Rules)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-04-28 00:06:47`
> - **Updated At**: `2026-04-28 00:28:30`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Mandatory Load Order
> - Project Rules
> - Done Criteria
<!-- DOC_TOC_END -->

## Scope
이 문서는 `airgap-k8s` sidecar 운영 규칙을 정의한다.
루트 `workspace/infra/airgap/kubernetes/airgap-k8s/AGENTS.md`가 이 프로젝트의 기본 진입점이며,
이 문서는 session reload와 sidecar 호환을 위한 보조 규칙 문서로만 사용한다.

## Mandatory Load Order
1. `workspace/infra/airgap/kubernetes/airgap-k8s/AGENTS.md`
2. `workspace/infra/airgap/kubernetes/airgap-k8s/ASSIGNMENT.md`
3. `workspace/infra/airgap/kubernetes/airgap-k8s/README.md`
4. `prj-docs/projects/airgap-k8s/rules/aws-airgap-simulation-baseline.md`
5. `prj-docs/projects/airgap-k8s/rules/manual-task-governance.md`
6. `prj-docs/projects/airgap-k8s/task.md`
7. `prj-docs/projects/airgap-k8s/meeting-notes/README.md`
8. 최신 `prj-docs/projects/airgap-k8s/meeting-notes/*.md`
9. `prj-docs/projects/airgap-k8s/rules/architecture.md`

## Project Rules
1. 루트 `AGENTS.md`가 이 프로젝트의 기본 대가리이며, 작업 시작/문서 우선순위/운영 규칙은 그 문서를 먼저 따른다.
2. `PROJECT_AGENT.md`는 sidecar/session-reload 호환을 위한 보조 문서이며, 루트 `AGENTS.md`와 충돌하는 독자 규칙을 만들지 않는다.
3. 프로젝트 기준선 문서/디렉토리(`AGENTS.md`, `README.md`, `prj-docs/PROJECT_AGENT.md`, `prj-docs/task.md`, `prj-docs/meeting-notes/README.md`, `prj-docs/rules/`)는 항상 존재해야 한다.
4. 과제 원문과 범위는 `workspace/infra/airgap/kubernetes/airgap-k8s/ASSIGNMENT.md`를 기준으로 유지한다.
5. 과제 해석, 작업 순서, 방식 결정은 먼저 `meeting-notes/*.md`에 기록하고 그 다음 실행에 반영한다.
6. 실제 작업이 시작되기 전까지 `task.md`는 과제 원문 체크리스트 중심으로 유지한다.
7. 실제로 필요해지기 전에는 빈 하위 디렉터리를 과하게 만들지 않는다.
8. 아직 직접 재현하지 않은 내용은 `planned`, `reference`, `unverified`로 명시한다.
9. 임시 산출물(`*.log`, `*.tmp`, 스크린샷)은 `.codex/tmp/<tool>/<run-id>/`에 저장하고, 영구 증빙 파일(`*.md`, `*.json`, 실제 설정 파일)만 프로젝트 경로에 유지한다.
10. AWS 실습 환경을 사용할 때는 `rules/aws-airgap-simulation-baseline.md`를 절대 기준으로 적용한다.
11. 제출 매뉴얼, sidecar task, 회의록 정렬 규칙은 `rules/manual-task-governance.md`를 절대 기준으로 적용한다.

## Done Criteria
1. 루트 `AGENTS.md`와 `PROJECT_AGENT.md`의 역할이 충돌하지 않는다.
2. `ASSIGNMENT.md`만 봐도 과제 범위와 제출 요구사항을 바로 이해할 수 있다.
3. `task.md`에 과제 항목별 진행 상태와 다음 작업이 정리돼 있다.
4. 실제 구축에 사용한 설정 파일과 제출용 매뉴얼 범위가 서로 모순 없이 연결된다.
5. AWS 기반 실습을 택하더라도 오프라인 설치 절차와 Terraform 책임 범위가 문서로 분리돼 있다.
