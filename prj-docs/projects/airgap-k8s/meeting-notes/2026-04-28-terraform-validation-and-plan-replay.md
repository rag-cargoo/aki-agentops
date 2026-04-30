# Meeting Notes: Terraform Validation and Plan Replay

## 안건 1: Terraform 현재 상태를 문서 기준과 다시 맞출지 검토
- Created At: 2026-04-28 09:02:00
- Updated At: 2026-04-28 09:10:00
- Status: DONE
- 검토사항:
  - `task.md`, `tasks/02-환경-준비.md`, `manual/02-환경-준비.md`에는 `terraform init/validate/plan`이 아직 미실행으로 남아 있었다.
  - 실제 워크스페이스에는 로컬 전용 `terraform.tfvars`, `.terraform.lock.hcl`, `tfplan`, `terraform.tfstate`가 이미 존재했다.
  - 추가 확인 결과 `terraform.tfstate.backup`에는 실제 생성됐던 VPC, subnet, SG, bastion, `k8s-master`, `k8s-worker1` 상태와 output 값이 남아 있었다.
  - 현재 `terraform.tfstate`는 같은 lineage에서 resource 수 `0`인 빈 state다.
- 결정사항:
  - 현재 인프라 단계 상태는 `값 미확정`이 아니라 `apply/destroy 1회 수행 후, 현재는 destroy 완료 상태`로 본다.
  - 로컬 실값(`admin_cidr`, `ami_id`, `key_pair_name`)은 계속 `terraform.tfvars`에만 두고, 추적 문서에는 존재 여부와 검증 결과만 남긴다.
  - 직전 세션의 `apply -> destroy` 이력은 로컬 state 산출물과 사용자 확인을 함께 근거로 본다.

## 안건 2: Terraform baseline을 지금 다시 검증할지 결정
- Created At: 2026-04-28 09:02:00
- Updated At: 2026-04-28 09:10:00
- Status: DONE
- 검토사항:
  - `make tf-validate`를 다시 실행해 현재 코드 기준 유효성을 확인할 필요가 있었다.
  - `make tf-plan`을 다시 실행해 bastion/public subnet, private node/private subnet, NAT 부재 조건이 실제 계획에 유지되는지 확인할 필요가 있었다.
- 결정사항:
  - `make tf-validate`는 성공했다.
  - `make tf-plan`은 성공했고 결과는 `13 to add, 0 to change, 0 to destroy`다.
  - 계획상 bastion만 public IP를 받고, `k8s-master`, `k8s-worker1`은 private subnet에만 배치되며, private route table에는 NAT 경로가 없다.
  - 현재 plan이 다시 `13 to add`로 나오는 것은 현재 state가 destroy 이후 빈 상태이기 때문이라고 본다.
- 후속작업:
  - 담당: Codex + User
  - 기한: 미정
  - 상태: TODO
  - 내용:
    - 다음 실습에서 인프라를 다시 올릴지(`make tf-apply`) 결정
    - 인프라 재생성 전 제출 매뉴얼 기준 증빙 항목을 한 번 더 점검
