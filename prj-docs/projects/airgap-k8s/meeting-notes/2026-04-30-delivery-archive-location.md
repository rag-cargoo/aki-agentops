# 반입 압축본 위치를 delivery 아래로 고정

## 결정
- `offline-assets.tar.gz`는 프로젝트 루트가 아니라 `delivery/` 아래에 둔다.
- 최종 반입 구조는 아래와 같이 고정한다.
  - 작업 원본: `assets/offline-assets/`
  - 반입 디렉터리 번들: `delivery/offline-assets/`
  - 반입 압축본: `delivery/offline-assets.tar.gz`
  - 서버 배치 경로: `/opt/offline-assets`

## 이유
- 루트에 압축본을 두면 작업 원본, 전달 번들, 최종 압축본 경계가 흐려진다.
- `delivery/` 아래에 두면 전달 산출물이 한 곳에 모인다.

## 반영 위치
- `workspace/infra/airgap/kubernetes/airgap-k8s/Makefile`
- `workspace/infra/airgap/kubernetes/airgap-k8s/manual/01-전체-실행-순서.md`
- `workspace/infra/airgap/kubernetes/airgap-k8s/manual/01-인터넷-불가능-네트워크-환경-및-리눅스-기본-구성/02-쿠버네티스-설치용-자산-다운로드.md`
- `prj-docs/projects/airgap-k8s/task.md`
