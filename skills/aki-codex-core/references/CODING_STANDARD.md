#  코딩 표준 및 원칙 (Coding Standards)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-08 23:32:34`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 1. 하드코딩 금지 (NO HARD-CODING) - [CRITICAL]
> - 2. 모듈화 및 재사용성 (Modularity)
> - 3. 주석 및 문서화 (Documentation)
> - 4. 보안 및 시크릿 관리 (Security & Secrets)
> - 5. 의존성 관리 (Dependency Management)
> - 6. 테스트 전략 (Testing Strategy)
<!-- DOC_TOC_END -->

이 문서는 모든 결과물에 적용되는 **절대적인 품질 기준**입니다.

##  1. 하드코딩 금지 (NO HARD-CODING) - [CRITICAL]
*   **원칙**: API 키, DB 비밀번호, 파일 절대 경로, 서버 IP 등은 **절대로** 소스 코드 내부에 문자열로 박아두지 마십시오.
*   **해결책**:
    *   `src/.env` 파일을 통한 환경변수 주입
    *   `config.yaml` 등 외부 설정 파일 사용
    *   Terraform `variables.tf` 사용
*   **예외**: 단위 테스트(Unit Test)를 위한 Mock 데이터는 허용.

## 2. 모듈화 및 재사용성 (Modularity)
*   3번 이상 반복되는 로직은 반드시 함수나 모듈로 분리하십시오.
*   하나의 함수는 하나의 역할만 수행해야 합니다 (SRP).

## 3. 주석 및 문서화 (Documentation)
*   "무엇을(What)" 하는지가 아니라 **"왜(Why)"** 했는지를 주석으로 남기십시오.
*   공개 API 함수는 반드시 Docstring을 작성하십시오.

##  4. 보안 및 시크릿 관리 (Security & Secrets)
*   **Git Ignore**: 모든 프로젝트 생성 시 즉시 `.gitignore`를 생성하고 `.env`, `*.pem`, `*.key` 등의 보안 파일을 포함시키십시오.
*   **환경변수**: 민감 정보는 반드시 환경변수로 관리하며, 예제 파일(`.env.example`)을 제공하여 필요한 변수 목록을 명시하십시오.

##  5. 의존성 관리 (Dependency Management)
*   **Lock File 필수**: 재현성을 보장하기 위해 패키지 매니저의 락 파일(`package-lock.json`, `poetry.lock`, `go.sum`, `terraform.lock.hcl`)은 **반드시 Git에 커밋**해야 합니다.
*   **버전 명시**: `latest` 태그 사용을 지양하고, 가능한 구체적인 버전을 명시하십시오.

##  6. 테스트 전략 (Testing Strategy)
*   **선택적 테스트 (Optional)**: 모든 코드에 테스트를 강제하지 않습니다.
*   **핵심 로직**: 복잡도가 높거나 비즈니스적으로 중요한 로직(결제, 계산 등)에 한해 단위 테스트 작성을 권장합니다.
*   **사후 검증**: `walkthrough.md`에 실행 결과만 잘 남겨도 충분합니다.
