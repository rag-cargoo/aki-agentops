# clear 타깃과 오프라인 자산 단계 경계

## 결정
- 재현 테스트를 위해 `clear` 타깃을 둔다.
- `clear`는 재생성 가능한 산출물만 지운다.
- 인프라 삭제는 `clear`가 아니라 `destroy` 용어를 유지한다.

## 추가한 clear 타깃
- `make 03-env-file-clear`
- `make 05-k8s-assets-clear`
- `make 06-bundle-clear`

## 5번과 6번을 분리하는 이유
- `5. 쿠버네티스 설치용 자산 다운로드`
  - 로컬 작업 원본 `assets/offline-assets/`를 만드는 단계
  - 패키지, 이미지, manifest를 실제로 내려받는 단계
- `6. 서버 반입용 번들 생성`
  - 작업 원본을 `delivery/offline-assets/`와 `delivery/offline-assets.tar.gz`로 묶는 단계
  - 서버 전송/반입용 산출물을 만드는 단계

## 의미
- 5번이 끝나면 “내 PC에 자산이 준비된 상태”
- 6번이 끝나면 “서버에 넘길 번들이 준비된 상태”
