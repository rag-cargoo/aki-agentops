# 루트 실행순서와 Make 타깃 번호 정렬

## 결정
- 루트 실행순서 문서의 반복 실행 단계는 `Makefile` 고수준 타깃으로 제공한다.
- 고수준 타깃 이름은 실행순서 번호를 앞에 둔다.
- 예: `make 03-tf-up`, `make 03-tf-verify`, `make 05-env-sync`
- 단, `source`처럼 현재 셸 상태를 바꾸는 단계는 `make`로 완전 대체하지 않고 원문 명령으로 유지한다.

## 반영 위치
- `workspace/infra/airgap/kubernetes/airgap-k8s/Makefile`
- `workspace/infra/airgap/kubernetes/airgap-k8s/manual/01-전체-실행-순서.md`
- `prj-docs/projects/airgap-k8s/rules/manual-task-governance.md`
