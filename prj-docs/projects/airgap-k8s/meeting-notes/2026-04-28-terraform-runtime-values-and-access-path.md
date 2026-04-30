# Meeting Notes: Terraform Runtime Values and SSH Access Path

## 안건 1: `terraform.tfvars` 실값 확정 전 상태 기록
- Created At: 2026-04-28 03:20:00
- Updated At: 2026-04-28 03:20:00
- Status: DOING
- 검토사항:
  - 다음 값이 확정되어야 `terraform.tfvars`를 채우고 `make tf-init`, `make tf-validate`, `make tf-plan`으로 이어갈 수 있다.
    - `aws_region`
    - `availability_zone`
    - `vpc_cidr`
    - `public_subnet_cidr`
    - `private_subnet_cidr`
    - `admin_cidr`
    - `ami_id`
    - `key_pair_name`
  - 현재 `manual/02-환경-준비.md`와 `tasks/02-환경-준비.md`도 위 값이 정해지기 전까지는 실제 결과값을 채우지 않는 기준으로 작성돼 있다.
- 현재 상태:
  - 아직 값 확정 전이다.
  - 따라서 `terraform/terraform.tfvars` 생성 및 `plan` 검증은 보류한다.
  - 현재 AWS CLI 인증과 기본 region은 확인했다.
  - 로컬에 보유한 개인키 존재 여부는 확인했지만, 현재 작업 region에서는 대응되는 EC2 key pair가 등록돼 있지 않은 상태다.
- 후속작업:
  - 담당: Codex + User
  - 기한: 미정
  - 상태: TODO
  - 내용:
    - 사용할 AWS region / AZ / AMI / key pair inventory 확인
    - VPC / subnet CIDR 초안 확정
    - bastion 관리자 접근용 `admin_cidr` 확정
    - 기존 AWS key pair 이름을 `terraform.tfvars`에 반영

## 안건 2: key pair 없이 바로 SSH 가능한지 검토
- Created At: 2026-04-28 03:20:00
- Updated At: 2026-04-28 03:20:00
- Status: DONE
- 검토사항:
  - 현재 Terraform 초안은 `compute.tf`에서 `bastion`, `k8s-master`, `k8s-worker1` 모두 `key_name = var.key_pair_name`을 사용한다.
  - `variables.tf`에서 `key_pair_name`은 기본값 없는 필수 문자열이다.
  - 현재 초안에는 `iam_instance_profile`, SSM 관련 IAM 권한, VPC endpoint, EC2 Instance Connect 관련 리소스가 없다.
  - 따라서 이 프로젝트의 현재 상태는 `bastion SSH -> private node SSH` 경로를 전제로 한다.
- 결정사항:
  - 현재 `airgap-k8s` 초안 기준으로는 `key pair 없이 그냥 SSH`는 지원하지 않는다.
  - 예전에 사용했던 keyless 접속 경험이 있다면, 그건 일반 SSH가 아니라 `SSM` 또는 별도 접속 보조 경로였을 가능성이 높다.
  - 가장 빠른 진행 경로는 현 초안대로 `key_pair_name`을 확정하고 bastion 기반 SSH 구조를 유지하는 것이다.
- 대안:
  - `SSM` 기반 keyless 접속으로 바꾸려면 Terraform 범위를 확장해야 한다.
  - 최소 필요 변경:
    - EC2 IAM role / instance profile
    - SSM agent 사용 가능한 AMI 기준 고정
    - private subnet용 SSM 관련 VPC endpoint 또는 그에 준하는 통신 경로
    - 보안그룹/매뉴얼/접속 절차 전면 수정
  - `EC2 Instance Connect`도 가능성은 있지만, 그것도 현재 초안에는 없고 추가 구성 작업이 필요하다.

## 안건 3: SSH 키 취급 방식 정리
- Created At: 2026-04-28 03:45:00
- Updated At: 2026-04-28 03:45:00
- Status: DONE
- 결정사항:
  - SSH 개인키(`*.pem`)는 레포와 문서에 저장하지 않는다.
  - 실제 값은 로컬 전용 `terraform.tfvars`에만 둔다.
  - `terraform.tfvars`는 Git 추적에서 제외한다.
  - Terraform은 기존 AWS key pair를 그대로 사용하고, `key_pair_name`만 로컬 `terraform.tfvars`에 기록한다.
- 이유:
  - 개인키와 계정별 실값 노출을 피할 수 있다.
  - 제출용 코드에는 예시 템플릿만 남기고, 실제 값은 로컬 파일에만 둘 수 있다.
