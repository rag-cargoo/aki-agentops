# 매뉴얼/태스크 거버넌스 규칙

## 목적
- 이 문서는 `airgap-k8s` 프로젝트의 제출 매뉴얼, sidecar task, 회의록 정렬 기준을 정의한다.
- 제출본 설명 규칙과 내부 운영 규칙이 섞이지 않도록 역할을 분리한다.

## 역할 분리
- `workspace/.../manual/*/README.md`
  - 제출본 장별 원본 문서
- `workspace/.../manual/*/*.md`
  - 제출본 장별 세부 문서
- `workspace/.../delivery/*`
  - 서버 반입용 설치 번들 및 전달 단위
- `prj-docs/projects/airgap-k8s/task.md`
  - 현재 상태 대시보드
- `prj-docs/projects/airgap-k8s/tasks/*.md`
  - 장별 상세 실행 TODO/완료 이력
- `prj-docs/projects/airgap-k8s/meeting-notes/*.md`
  - 날짜 기반 의사결정 이력
- `prj-docs/projects/airgap-k8s/meeting-notes/README.md`
  - 매뉴얼 장 기준 회의록 index

## 매뉴얼 파일 규칙
1. `00-제출-매뉴얼-개요/README.md`는 공통 서문/기준 문서로 유지한다.
2. `주제`는 별도 구축 장으로 만들지 않고 `00-제출-매뉴얼-개요/`에 포함한다.
3. 실제 구축 절차 매뉴얼은 `01-인터넷-불가능-네트워크-환경-및-리눅스-기본-구성/`부터 시작한다.
4. `01~05`는 ClickUp 과제문 `내용`의 작업 순서를 따른다.
5. `06-제출/`은 ClickUp 과제문 `제출` 요구사항을 정리한다.
6. 매뉴얼 장 디렉터리명과 세부 문서 파일명은 번호형 한글을 사용한다.
7. 각 장은 `README.md`를 진입점으로 사용한다.
8. 실행 자산 디렉터리명은 ASCII/영문으로 사용한다.

## 제출 개요에 반드시 남길 내용
1. AWS는 하드웨어 대체 실습 환경이라는 점
2. 설치 절차는 실제 폐쇄망과 동일한 오프라인 기준이라는 점
3. Terraform은 네트워크/서버 재현 범위까지만 담당한다는 점
4. Kubernetes, DB, 모니터링 설치 절차는 Terraform에 숨기지 않는다는 점
5. 최종 제출 직전 Word/HWP/PDF 등으로 변환하되 원본은 Markdown이라는 점
6. `02` 이후 실제 설치 절차는 VM 기준으로 진행할 수 있다는 점

## 매뉴얼 작성 규칙
1. `manual/`에는 실제 실행했거나 현재 검증 가능한 절차만 기록한다.
2. 아직 실행하지 않은 명령, 미작성 manifest, 예정 절차는 `prj-docs/projects/airgap-k8s/tasks/*.md`에 둔다.
3. 장별 매뉴얼은 `01-01.1`, `01-03.2`, `02-01.4`, `03-01.7`처럼 `장-상위단계-세부단계` 번호형 실행 절차를 사용한다.
4. 각 실행 절차는 `명령어`와 `한 줄 설명` 위주로 작성한다.
5. `목적`, `사전 준비`, `남은 리스크`, 문서 역할 설명, 거버넌스 문구는 장별 매뉴얼 본문에 넣지 않는다.
6. 작업이 실제로 끝나면 sidecar의 초안 절차를 실행 결과 기준으로 정리해서 `manual/`에 반영한다.
7. 오프라인 자산은 로컬 작업 원본, 반입 번들 경로, 서버 배치 경로를 분리해서 기록한다.
8. 로컬 작업 원본은 `assets/offline-assets/`를 기준으로 한다.
9. 서버 반입용 설치 번들은 `delivery/offline-assets/`를 기준으로 한다.
10. 서버 배치 경로는 `/opt/offline-assets`를 기준으로 한다.
11. 서버 설치 명령은 가능한 한 `/opt/offline-assets/...` 경로를 사용해 작성한다.
12. `01`은 AWS 시뮬레이션 또는 VM 폐쇄망 구성을 다룰 수 있지만, `02` 이후 실제 설치 절차는 VM 기준으로 정리한다.
13. SSH 키 경로, bastion/master/worker IP 같은 실행 환경 값은 매뉴얼에 하드코딩하지 않고 `.env`와 환경변수 예시로만 기록한다.
14. Terraform 재적용 후 변경될 수 있는 IP 값은 수동 복사 대신 Terraform output 기반 스크립트로 `.env`를 갱신한다.
15. 사용자 로컬 절대경로(`/home/...`, `C:\\...` 등)는 매뉴얼 본문에 하드코딩하지 않는다.
16. 프로젝트 작업 경로는 `cd <프로젝트-루트>`로 표기하고, 필요하면 `pwd`, `ls`로 루트 확인 단계를 함께 둔다.
17. 루트 실행순서 문서에는 각 실행 단계마다 `검증` 명령 또는 `검증 기준`을 함께 적는다.
18. 검증이 반복되는 단계는 `Makefile` 타깃 또는 스크립트로 제공하고, 루트 실행순서 문서에서는 그 타깃을 우선 사용한다.
19. 루트 실행순서 문서의 반복 단계는 가능하면 `Makefile` 고수준 타깃으로 노출하고, 타깃 이름은 역할 접두어와 실행순서 번호를 함께 사용한다. 예: `make run-01-01-terraform`, `make step-01-03-02-k8s-assets-download`.
20. 현재 셸 환경을 직접 바꾸는 명령(`source`, `export`, `cd` 결과 유지 등)은 `make`로 완전히 대체하지 않고 원문 명령으로 남긴다.
21. 실행이 아닌 참고/설명/상세 문서 링크는 번호형 실행 단계에 넣지 않고 `참고` 구역으로 분리한다.
22. 하나의 의미 단위로 묶이는 단계는 루트 실행순서에서 합쳐서 보여준다. 예: `.env` 생성, sync, load는 `환경변수 준비 및 로드` 한 단계로 묶는다.
23. `clear` 타깃은 재생성 가능한 산출물만 삭제한다. 인프라 삭제는 `clear`가 아니라 `destroy` 용어를 유지한다.
24. 오프라인 자산 단계는 `다운로드/검증`과 `번들 생성/검증`을 분리한다. 전자는 작업 원본 생성, 후자는 서버 반입본 생성이다.
25. 상위 묶음 타깃과 세부 타깃을 함께 둔다. 루트 실행순서 문서는 상위 묶음 타깃을 우선 사용하고, 상세 매뉴얼에는 세부 타깃을 함께 남긴다.
26. Kubernetes 설치 장(`03`)은 제출 매뉴얼과 ops 모두 `manual-kubeadm/`, `ansible-kubeadm/`, `calico/`, `storageclass/` 구조를 기본으로 사용한다.
27. 수동 설치의 사전점검과 반입 경로는 `manual-kubeadm/01-access-and-transfer`, `manual-kubeadm/02-preflight`가 담당한다.
28. `manual-kubeadm/`은 제출 매뉴얼과 ops 모두 `01-access-and-transfer`부터 `10-cluster-verify`까지 같은 디렉터리명을 사용하고, `ansible-kubeadm/`은 같은 목적의 자동화 단계를 자기 디렉터리 안에서 별도로 관리한다.
29. bastion 실행 원본은 설치 자산과 분리해서 `delivery/ops-runtime.tar.gz`로 묶고, bastion 기준 배치 경로는 `/opt/airgap-k8s-ops`로 기록한다.
30. `.env`는 수동/Ansible 공통 원천값 저장소로 사용하고, inventory/SSH 설정 생성은 `.env` 기반 bootstrap 단계에서 파생 생성한다.
31. 실행 착수 전 bastion/control node/SSH 경로/IP/설치 방식 선택을 먼저 정리할 수 있도록 `manual/00-제출-매뉴얼-개요/03-사전-조사-정보-수집-템플릿.example.yaml`를 유지한다.
32. 세부 `step` 단계는 가능하면 `실행 -> 같은 단계 verify 호출 -> 성공 시 상태 마커 기록` 구조로 구현한다.
33. `all-verify`는 실제 작업을 다시 수행하지 않고, 독립 verify 결과나 상태 마커를 기반으로 현재 단계 상태를 표시한다.
34. 상태 마커는 `.codex/runtime/airgap-k8s-state/` 아래에 `*.done`, `*.failed` 형식으로 기록한다.
35. 단원 내부 스크립트 파일명은 `NN-MM-역할-이름.sh` 형식을 사용한다. 같은 작업 단위의 `run`과 `verify`는 같은 `NN-MM`을 공유하고, helper/diagnostic 스크립트는 실행 우선순위에 맞춰 별도 `NN-MM`을 사용한다.
36. `04` 서비스 배포 전에 `03` 단계에서 기본 StorageClass를 구성한다. 기본 선택지는 폐쇄망 준비물이 작은 `local-path-provisioner`이며, NFS provisioner와 Longhorn은 대안으로 기록한다.

## Task 규칙
1. `task.md`에는 확정된 절차와 실제 착수/완료 항목만 기록한다.
2. 미확정 예상 단계는 `meeting-notes/*.md` 또는 `manual/00-제출-매뉴얼-개요/README.md`에만 남기고 `task.md`에는 올리지 않는다.
3. `Current Items`는 실제 제출 매뉴얼 장 순서에 맞춰 묶는다.
4. sidecar 상세 TODO는 `prj-docs/projects/airgap-k8s/tasks/*.md`에서 같은 장 번호로 맞춘다.
5. 오프라인 자산 관련 sidecar에는 `로컬 원본 경로`, `반입 번들 경로`, `서버 반입 경로`, `압축/해제 방식`을 함께 남긴다.

## 회의록 정렬 규칙
1. 회의록 파일 자체는 날짜 기반 `YYYY-MM-DD-topic.md` 규칙을 유지한다.
2. `meeting-notes/README.md`에서만 `00`, `01`, `02`처럼 매뉴얼 장 번호 기준으로 묶어 보여준다.
3. 회의록을 장별 디렉터리로 쪼개지는 않는다.
