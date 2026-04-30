# 루트 실행순서 문서 요약화와 Make 타깃 정리

## 결정
- 루트 `manual/01-전체-실행-순서.md`는 요약 런북으로 유지한다.
- 세부 `tf-init`, `tf-validate`, `tf-plan`, `tf-apply` 절차는 `manual/01` 상세 매뉴얼에 둔다.
- 루트 런북에서는 한 줄 실행용 `make tf-up`을 사용한다.

## 반영 위치
- `workspace/infra/airgap/kubernetes/airgap-k8s/Makefile`
- `workspace/infra/airgap/kubernetes/airgap-k8s/manual/01-전체-실행-순서.md`

## 비고
- `make tf-up`은 `init -> validate -> plan -> apply` 순서로 실행한다.
- 상세 매뉴얼은 장별 README에서 계속 관리한다.
