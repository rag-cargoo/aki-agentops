# 환경변수 파일과 매뉴얼 변수 사용 기준

## 결정
- SSH 키 경로, bastion IP, master IP, worker IP는 매뉴얼 본문에 하드코딩하지 않는다.
- 프로젝트 루트에 `.env.example`을 두고, 실제 값은 `.env`에만 저장한다.
- `.env`는 git 추적 대상에서 제외한다.
- 매뉴얼 명령은 `${AIRGAP_*}` 환경변수 기준으로 작성한다.

## 반영 위치
- `workspace/infra/airgap/kubernetes/airgap-k8s/.env.example`
- `workspace/infra/airgap/kubernetes/airgap-k8s/scripts/load-project-env.sh`
- `workspace/infra/airgap/kubernetes/airgap-k8s/manual/01-전체-실행-순서.md`
- `workspace/infra/airgap/kubernetes/airgap-k8s/manual/03-쿠버네티스-클러스터-구성/README.md`

## 이유
- 제출 매뉴얼에서 사용자 로컬 키 경로와 실제 IP를 직접 노출하지 않기 위해서다.
- 접속 절차와 반입 절차를 같은 변수 집합으로 관리하기 위해서다.
