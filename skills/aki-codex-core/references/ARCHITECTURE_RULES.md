#  전사 아키텍처 원칙 (Global Architecture Principles)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-17 17:28:03`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 1. 아키텍처 지향점
> - 2. 서비스별 아키텍처 정의 위치
<!-- DOC_TOC_END -->

이 문서는 모든 프로젝트(서비스)가 공통적으로 지향해야 할 아키텍처 대원칙을 정의합니다.
구체적인 구현 기술 및 레이어링 전략은 **각 서비스별 문서(`prj-docs/knowledge/`)**에 정의합니다.

## 1. 아키텍처 지향점
1.  **서비스 자율성 (Autonomy)**: 각 서비스는 자신의 데이터와 로직을 독립적으로 관리해야 한다.
2.  **명확한 인터페이스 (Explicit Interface)**: 서비스 간 통신은 정의된 API(REST, gRPC, Event)로만 수행한다.
3.  **문서화 의무 (Documentation)**: 각 서비스는 자신의 아키텍처 결정 사항(ADR)을 문서화해야 한다.

## 2. 서비스별 아키텍처 정의 위치
각 프로젝트는 아래 위치에 상세 아키텍처 규칙을 작성하십시오.

*   **위치**: `workspace/apps/{service-name}/prj-docs/knowledge/architecture.md`
*   **포함 내용**:
    *   사용 언어 및 프레임워크
    *   패키지 구조 (Layered, Hexagonal 등)
    *   데이터베이스 설계 원칙
