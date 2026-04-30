# 전체 실행 매뉴얼의 .env 경로 명시 보강

## 결정
- `.env`는 현재 쉘 위치 기준이 아니라 프로젝트 루트 `airgap-k8s/.env`에 생성된다는 점을 매뉴얼에 명시한다.
- `make sync-env` 출력에도 `.env` 절대 경로를 함께 표시한다.

## 반영 위치
- `workspace/infra/airgap/kubernetes/airgap-k8s/manual/01-전체-실행-순서.md`
- `workspace/infra/airgap/kubernetes/airgap-k8s/manual/01-인터넷-불가능-네트워크-환경-및-리눅스-기본-구성/02-쿠버네티스-설치용-자산-다운로드.md`
- `workspace/infra/airgap/kubernetes/airgap-k8s/manual/03-쿠버네티스-클러스터-구성/README.md`
- `workspace/infra/airgap/kubernetes/airgap-k8s/scripts/sync-env-from-terraform.sh`
