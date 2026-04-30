# 오프라인 자산 준비를 4.x 하위 단계로 정렬

## 결정
- 오프라인 자산 준비는 루트 실행순서의 `4번` 상위 단계로 묶는다.
- 작업 원본 확인, 다운로드, 다운로드 검증, 번들 생성, 번들 검증은 `4.x` 하위 단계로 정렬한다.
- `Makefile` 타깃도 같은 번호 체계로 맞춘다.

## 반영
- `make 04-01-assets-tree-check`
- `make 04-02-k8s-assets-download`
- `make 04-03-k8s-assets-verify`
- `make 04-02-k8s-assets-clear`
- `make 04-04-bundle-create`
- `make 04-05-bundle-verify`
- `make 04-04-bundle-clear`
