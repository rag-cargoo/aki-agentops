# Meeting Notes: ClickUp Assignment Source Hierarchy Correction

## 안건 1: ClickUp 원문 계층 재확인
- Created At: 2026-04-29 11:30:00
- Updated At: 2026-04-29 11:30:00
- Status: DONE

## 확인 결과
- ClickUp 문서의 실제 제목은 `서버 구축 테스트💯`다.
- 본문은 `서버 구축 테스트` > `🎈문제 1` > `주제` / `내용` / `제출` 구조다.
- `내용` 아래 항목은 번호형 장이 아니라 중첩 bullet 구조다.
- 기존 로컬 `ASSIGNMENT.md`처럼 `1. 주제`, `2. 환경`, `3. 사용자 및 네트워크 설정`으로 재번호화하면 원문 계층과 달라진다.

## 원문 기준 계층
1. `🎈문제 1`
2. `주제`
3. `내용`
   - `인터넷이 불가능한 네트워크 환경`
   - `리눅스 기본 구성`
     - `사용자 및 네트워크 설정`
       - `devops` 사용자 생성 및 sudo 권한 부여
       - 호스트 이름 `k8s-master`, `k8s-worker1` 설정
       - `/etc/hosts`에 각 노드 IP와 이름 등록
   - `Kubernetes 클러스터 구성`
     - `master + worker` 구성
     - 네트워크 플러그인: `Calico` 또는 `Flannel`
   - `서비스 배포 및 모니터링 설정 능력`
     - `MySQL(or MariaDB)`
     - `MongoDB`
     - `Prometheus`
     - `Grafana`
     - `Grafana Alloy`
   - `Prometheus + Grafana 외부 접근 설정`
4. `제출`
   - 서버 구축 과정에 대한 상세한 단계별 매뉴얼 작성본
   - 서버 구축 설정에 사용된 파일 압축 첨부

## 결정사항
- 과제 원문 파일은 ClickUp 본문 계층을 그대로 보존한다.
- 제출 매뉴얼/ops 디렉터리 번호는 원문을 해석한 작업용 번호일 뿐이며, 원문 자체의 번호처럼 표현하지 않는다.
- 이후 구조 보정은 새 트리 생성이 아니라 기존 구조에서 원문 계층과 충돌하는 이름/위치만 최소 수정한다.
