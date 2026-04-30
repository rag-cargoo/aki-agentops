# AWS Simulation and VM Execution Boundary

## Summary
- 과제 대상은 온프레미스(폐쇄망) Kubernetes다.
- AWS Terraform은 `01. 인터넷 불가능 네트워크 환경 및 리눅스 기본 구성` 장에서 폐쇄망을 재현하는 대체 실습 방식으로만 사용한다.
- 실제 설치 절차는 `02` 이후부터 VM 기준으로 진행해도 과제 취지와 충돌하지 않는다.

## Decision
1. `01` 장은 AWS Terraform 또는 VM 방식으로 폐쇄망 환경을 설명할 수 있다.
2. `02` 장 이후의 사용자 설정, 네트워크 설정, Kubernetes 설치, 서비스 배포는 VM 기준으로 진행한다.
3. AWS는 최종 대상이 아니라 실습용 시뮬레이션 환경으로만 설명한다.
4. 제출 매뉴얼은 온프레미스/VM 기준 절차를 우선으로 쓰고, AWS는 대체 재현 방식으로만 남긴다.

## Why This Is Acceptable
- 과제 핵심은 클라우드 사용 여부가 아니라 `폐쇄망에서 Kubernetes와 모니터링 서비스를 구축하는 능력`이다.
- VM은 온프레미스 환경에 더 가깝고, `devops`, hostname, `/etc/hosts`, kubeadm, CNI, 서비스 배포 절차를 그대로 재현할 수 있다.
- `02` 이후 절차는 AWS 전용 구성이 아니라 Linux 노드 기준 절차이므로 VM으로 이어가도 기술적으로 동일하다.

## Execution Boundary
- `01`: AWS Terraform 시뮬레이션 또는 VM 폐쇄망 구성
- `02`: VM 노드 사용자 및 네트워크 설정
- `03`: VM 노드 Kubernetes 설치
- `04`: VM 클러스터 서비스 배포
- `05`: VM 클러스터 외부 접근 설정

## Risk Check
- AWS에서 `02` 이후까지 계속 진행해야 한다는 과제 요구는 없다.
- 다만 매뉴얼에 `AWS는 시뮬레이션`, `VM은 실제 설치 대상`이라는 문장을 명시해야 해석 충돌이 없다.
