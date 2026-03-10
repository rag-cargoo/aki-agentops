# Architecture Rule (spring-boot-playground sidecar)

## Rule
- 학습 프로젝트는 기능 단위로 작게 추가하고, 각 단계마다 실행/검증 가능한 상태를 유지한다.
- 외부 인프라(Redis/Kafka)는 docker-compose 기준 로컬 재현 가능해야 한다.
- 문서와 코드 증빙은 동일 세션에서 함께 갱신한다.

## Layer Guideline
1. `web`: controller + request/response
2. `service`: integration logic
3. `config`: infra/client/topic bean
