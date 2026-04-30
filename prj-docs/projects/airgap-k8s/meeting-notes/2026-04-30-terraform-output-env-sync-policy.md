# Terraform output 기반 .env 동기화 기준

## 결정
- bastion public IP는 현재 고정 IP가 아니므로 Terraform 재적용 시 바뀔 수 있다.
- private IP도 Terraform 코드에서 명시하지 않았으므로 재생성 시 변경될 수 있다.
- 따라서 접속용 IP는 수동 복사하지 않고 Terraform output 기반 스크립트로 `.env`를 갱신한다.

## 반영 위치
- `workspace/infra/airgap/kubernetes/airgap-k8s/scripts/sync-env-from-terraform.sh`
- `workspace/infra/airgap/kubernetes/airgap-k8s/Makefile`
- `workspace/infra/airgap/kubernetes/airgap-k8s/manual/01-전체-실행-순서.md`
- `workspace/infra/airgap/kubernetes/airgap-k8s/manual/03-쿠버네티스-클러스터-구성/README.md`

## 실행 기준
```bash
make sync-env
source scripts/load-project-env.sh
```
