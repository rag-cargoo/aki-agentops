# 아키텍처 규칙

## 목적
- 이 프로젝트는 `서버 구축 테스트` 과제 대응용 문서/설정 프로젝트다.
- 첫 단계는 과제 범위를 분명히 고정하고, 이후 필요한 설정 파일과 매뉴얼을 필요한 시점에만 추가하는 것이다.
- AWS를 사용할 경우에도 `rules/aws-airgap-simulation-baseline.md`를 우선 기준으로 적용한다.

## 단계 순서
1. 인터넷이 불가능한 네트워크 환경 및 리눅스 기본 구성
2. 사용자 및 네트워크 설정 (`devops`, `sudo`, hostname, `/etc/hosts`)
3. Kubernetes 클러스터 구성 (`master + worker`, Calico, 기본 StorageClass)
4. 서비스 배포 및 모니터링 설정 (`MySQL/MariaDB`, `MongoDB`, `Prometheus`, `Grafana`, `Grafana Alloy`)
5. Prometheus + Grafana 외부 접근 설정
6. 제출물 정리

## 증빙 규칙
- 각 단계 완료 시 아래 3가지를 남긴다.
  - 근거 문서 또는 참고 기준
  - 사용한 명령 또는 설정 파일 경로
  - 남은 리스크 또는 미검증 사항
