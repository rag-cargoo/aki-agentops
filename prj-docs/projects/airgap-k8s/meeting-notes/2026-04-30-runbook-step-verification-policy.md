# 루트 실행순서 문서의 단계별 검증 기준

## 결정
- 루트 실행순서 문서에는 실행 명령만 두지 않고, 각 단계마다 `검증` 명령 또는 `검증 기준`을 함께 적는다.
- 반복해서 쓰는 검증은 `Makefile` 타깃 또는 스크립트로 제공한다.
- Terraform 단계 검증은 `make tf-verify`로 노출한다.

## 반영 위치
- `workspace/infra/airgap/kubernetes/airgap-k8s/Makefile`
- `workspace/infra/airgap/kubernetes/airgap-k8s/manual/01-전체-실행-순서.md`
- `prj-docs/projects/airgap-k8s/rules/manual-task-governance.md`
