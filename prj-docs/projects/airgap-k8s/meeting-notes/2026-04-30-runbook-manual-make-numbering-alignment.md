# 2026-04-30-runbook-manual-make-numbering-alignment

## Decision
- 루트 실행순서, 장별 매뉴얼, `Makefile` 타깃 번호를 같은 체계로 맞춘다.
- 루트 실행순서는 `00-01`, `01-01`, `01-02`, `01-03`, `02-01`, `03-01` 형식을 사용한다.
- 장별 상세 절차는 루트 번호를 상속해 `01-01.1`, `01-03.4`, `02-01.5`, `03-01.7` 형식을 사용한다.

## Why
- 기존 `1`, `2`, `3`와 `5.1`, `6.1`, `01-03-up` 같은 표기가 섞여 보여 단계 매칭이 어려웠다.
- 번호가 같아야 대화, 매뉴얼, `make` 실행문을 같은 기준으로 추적할 수 있다.

## Applied Scope
- `manual/01-전체-실행-순서.md`
- `manual/01-인터넷-불가능-네트워크-환경-및-리눅스-기본-구성/README.md`
- `manual/01-인터넷-불가능-네트워크-환경-및-리눅스-기본-구성/02-쿠버네티스-설치용-자산-다운로드.md`
- `manual/02-사용자-및-네트워크-설정/README.md`
- `manual/03-쿠버네티스-클러스터-구성/README.md`
- `Makefile`
- `scripts/run-offline-assets-flow.sh`
- `scripts/run-offline-assets-clear.sh`
