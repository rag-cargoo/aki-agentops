# 매뉴얼의 사용자 로컬 절대경로 금지

## 결정
- 매뉴얼 본문에는 `/home/...`, `C:\\...` 같은 사용자 로컬 절대경로를 하드코딩하지 않는다.
- 프로젝트 작업 경로는 `cd <프로젝트-루트>`로 표기한다.
- 필요하면 `pwd`, `ls`를 같이 적어 현재 디렉터리가 `airgap-k8s` 루트인지 확인하게 한다.

## 이유
- 사용자마다 프로젝트 clone 경로가 다르다.
- 특정 사용자 경로를 매뉴얼에 박아두면 재현성과 제출 품질이 같이 떨어진다.

## 반영 위치
- `prj-docs/projects/airgap-k8s/rules/manual-task-governance.md`
- `workspace/infra/airgap/kubernetes/airgap-k8s/manual/01-전체-실행-순서.md`
- `workspace/infra/airgap/kubernetes/airgap-k8s/manual/01-인터넷-불가능-네트워크-환경-및-리눅스-기본-구성/02-쿠버네티스-설치용-자산-다운로드.md`
- `workspace/infra/airgap/kubernetes/airgap-k8s/manual/03-쿠버네티스-클러스터-구성/README.md`
