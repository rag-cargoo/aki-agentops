# 🤖 Workspace Boot Instructions

이 프로젝트는 **엄격한 거버넌스와 고품질 엔지니어링 표준**을 최우선으로 합니다. 새로운 세션의 에이전트는 작업을 시작하기 전 반드시 아래 절차를 수행하십시오.

## 🚨 1순위: 거버넌스 스킬 활성화 (Mandatory)
가장 먼저 `workspace-governance` 스킬을 활성화하여 전역 규칙과 표준 템플릿을 장착하십시오.
- **명령**: `activate_skill(name="workspace-governance")`
- **목적**: [코드-문서-도구] 패키지 완결성 보장 및 하드코딩 원천 차단.

## 2순위: 현재 상태 파악
스킬이 장착된 상태에서 아래 문서를 통해 작업 문맥을 로드하십시오.
- **작업 현황**: `workspace/apps/backend/ticket-core-service/prj-docs/task.md`
- **핵심 지식**: `workspace/apps/backend/ticket-core-service/prj-docs/knowledge/동시성-제어-전략.md`

## 3순위: 즉시 수행 지침
- 현재 아키텍처 리팩토링(Class 전환, 패키지 정규화)과 인프라 안정화가 완료되었습니다.
- **Next Step**: `Step 5: Redis Sorted Set 기반 실시간 대기 순번 시스템` 설계 및 구현에 착수하십시오.
- 모든 작업은 `workspace-governance` 스킬 지침에 따라 패키지 단위로 수행되어야 합니다.