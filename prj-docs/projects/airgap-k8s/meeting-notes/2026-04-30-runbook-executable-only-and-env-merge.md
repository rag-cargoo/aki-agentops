# 루트 실행순서의 실행 단계만 번호 부여 및 환경변수 단계 병합

## 결정
- 루트 실행순서 문서에는 실행 단계만 번호를 부여한다.
- 참고 문서 링크와 설명성 항목은 `참고` 구역으로 분리한다.
- `.env` 생성, Terraform output 동기화, 현재 셸 로드는 루트 실행순서에서 하나의 단계로 묶는다.

## 반영 위치
- `workspace/infra/airgap/kubernetes/airgap-k8s/manual/01-전체-실행-순서.md`
- `workspace/infra/airgap/kubernetes/airgap-k8s/scripts/project-env-setup.sh`
- `workspace/infra/airgap/kubernetes/airgap-k8s/Makefile`
- `prj-docs/projects/airgap-k8s/rules/manual-task-governance.md`
