# Agent Resume + HR Discovery 기반 컨테이너 에이전트 선발 기획안

작성일: 2026-05-15
대상 저장소: aki-agentops
관련 문서: docs/proposals/codex-multi-agent-orchestrator-plan.md

---

## 1. 문서 목적

이 문서는 Codex Docker Multi-Agent Orchestrator 구조에서 각 컨테이너 에이전트가 자기 이력서, 담당 업무, 보유 skills, 실행 가능한 작업 범위를 직접 소유하고, orchestrator가 HR agent에게 문의하여 적합한 컨테이너 에이전트를 선발하는 구조를 설계한다.

기존 기획안의 핵심은 다음과 같았다.

```text
orchestrator가 태스크 상태를 보고 backend-agent, test-agent, reviewer-agent, git-agent, frontend-agent 등을 순차 실행한다.
```

이번 확장 기획안의 핵심은 다음이다.

```text
각 agent container가 자기 resume/profile/skills repo를 가진다.
orchestrator는 agent 상세 정보를 고정 설정파일로 모두 들고 있지 않는다.
orchestrator는 HR agent에게 문의해서 현재 태스크에 적합한 agent 조합을 추천받는다.
HR agent는 agent resume을 읽고 담당자를 선발한다.
orchestrator는 추천받은 agent container를 실행한다.
```

---

## 2. 배경

초기 구조에서는 orchestrator가 다음 정보를 직접 알고 있어야 했다.

```text
backend 역할은 어떤 image를 실행할지
test 역할은 어떤 image를 실행할지
각 역할에 어떤 skills를 마운트할지
각 agent가 무엇을 할 수 있는지
```

이 방식은 단순하지만 agent가 늘어날수록 orchestrator가 지나치게 많은 정보를 보관하게 된다.

따라서 각 컨테이너 에이전트가 자기 정보를 직접 보유하게 하고, HR agent가 이 정보를 읽어 적합한 agent를 추천하는 방향으로 확장한다.

---

## 3. 핵심 개념

### 3.1 컨테이너 에이전트는 자기 이력서를 가진다

각 agent image 또는 agent skills repo 안에는 다음 파일을 둔다.

```text
/opt/agent/profile/AGENT_RESUME.md
/opt/agent/profile/agent-card.json
/opt/agent/skills/
```

이 파일은 에이전트가 자신을 소개하는 이력서 역할을 한다.

예시:

```text
나는 backend-agent이다.
나는 Java, Spring Boot, JPA, REST API 구현을 담당한다.
나는 테스트 실행은 가능하지만 테스트 전략 최종 판단은 test-agent에게 넘긴다.
나는 운영 배포, main merge, secret 수정은 하지 않는다.
```

### 3.2 HR agent는 에이전트 선발 담당이다

HR agent는 실제 개발 작업을 하지 않는다.

역할은 다음과 같다.

```text
태스크 내용 분석
agent resume/profile 조회
agent 후보 비교
역할별 agent 추천
추천 이유 작성
실행 순서 제안
위험 시 needs_human 권고
```

### 3.3 orchestrator는 실행 담당이다

orchestrator는 모든 agent의 상세 경력과 skills를 직접 판단하지 않는다.

역할은 다음과 같다.

```text
사용자 태스크 수신
HR agent에게 적합한 agent 추천 요청
추천 결과를 session/tmp에 저장
필요한 agent container 실행
상태 변경 기록
실패 시 중단 또는 재시도
```

---

## 4. 전체 구조

```text
사용자 태스크
   ↓
orchestrator
   ↓ 문의
hr-agent
   ↓ agent resume/profile 조회
agent discovery / agent registry / docker image metadata
   ↓ 추천 결과 반환
orchestrator
   ↓ 실행
backend-agent / test-agent / reviewer-agent / git-agent / frontend-agent
   ↓
.agent-room 상태 기록
```

역할을 사람 조직에 비유하면 다음과 같다.

```text
orchestrator = 프로젝트 진행 관리자
hr-agent     = 인사 담당자 / 담당자 배정자
worker agent = 실제 업무 수행자
reviewer     = 검토자
git-agent    = 형상관리 담당자
```

---

## 5. 오케스트레이터가 모든 설정을 보관하지 않는 구조

질문에서 제안한 방향은 다음과 같다.

```text
orchestrator가 agent 설정파일을 계속 보관하지 않는다.
필요할 때마다 agent들이 자기 이력서를 보고한다.
orchestrator는 그 결과를 tmp/session memory에 잠깐 넣어둔다.
작업이 끝나면 세션 기록만 남긴다.
```

이 방향은 가능하다.

다만 orchestrator가 완전히 아무 정보도 가지지 않으면 첫 실행 대상조차 찾기 어렵다.

따라서 최소 정보는 필요하다.

orchestrator가 알아야 할 최소 정보:

```text
HR agent를 어떻게 실행할지
agent discovery를 어디서 할지
Docker를 어떻게 실행할지
.agent-room 위치
작업 중단 정책
최대 동시 실행 수
```

orchestrator가 직접 알지 않아도 되는 정보:

```text
각 agent의 상세 경력
각 agent의 세부 skills
각 agent의 전문 분야 설명
각 agent의 세부 실행 순서 판단
```

즉 구조는 다음처럼 나누는 것이 좋다.

```text
orchestrator는 실행 규칙만 안다.
HR agent는 선발 기준을 안다.
각 worker agent는 자기 이력서를 가진다.
```

---

## 6. agent-card.json 설계

각 에이전트는 기계가 읽을 수 있는 agent-card.json을 가진다.

예시: backend-agent

```json
{
  "agent_id": "aki-backend-agent",
  "display_name": "Backend Agent",
  "role": "backend",
  "version": "0.1.0",
  "docker_image": "aki-backend-agent:0.1.0",
  "career_summary": "Java Spring Boot, REST API, JPA, Redis, Kafka 기반 백엔드 구현 담당",
  "primary_skills": [
    "Java",
    "Spring Boot",
    "JPA",
    "QueryDSL",
    "REST API",
    "Redis",
    "Kafka"
  ],
  "can_do": [
    "API 구현",
    "서비스 로직 작성",
    "DB 연동",
    "예외 처리",
    "백엔드 변경사항 요약",
    "테스트 담당자에게 전달할 구현 의도 작성"
  ],
  "cannot_do": [
    "main 브랜치 직접 merge",
    "운영 배포",
    "민감정보 수정",
    "프론트 UI 최종 디자인 결정"
  ],
  "skills_repo": "rag-cargoo/aki-backend-skills",
  "skills_commit": "optional-fixed-commit-sha",
  "default_mounts": [
    "/workspace",
    "/agent-room"
  ],
  "risk_policy": {
    "requires_human_before_push": true,
    "requires_human_for_secret_change": true,
    "requires_human_for_main_merge": true
  }
}
```

예시: test-agent

```json
{
  "agent_id": "aki-test-agent",
  "display_name": "Test Agent",
  "role": "test",
  "version": "0.1.0",
  "docker_image": "aki-test-agent:0.1.0",
  "career_summary": "JUnit, Spring Boot Test, API 테스트, 통합 테스트 작성 및 실행 담당",
  "primary_skills": [
    "JUnit",
    "Spring Boot Test",
    "MockMvc",
    "Testcontainers",
    "API Test"
  ],
  "can_do": [
    "단위 테스트 작성",
    "통합 테스트 작성",
    "API 테스트 작성",
    "테스트 실행",
    "실패 원인 요약"
  ],
  "cannot_do": [
    "서비스 요구사항 임의 변경",
    "main merge",
    "운영 배포"
  ],
  "skills_repo": "rag-cargoo/aki-test-skills",
  "default_mounts": [
    "/workspace",
    "/agent-room"
  ]
}
```

---

## 7. AGENT_RESUME.md 설계

agent-card.json은 기계용이고, AGENT_RESUME.md는 사람이 읽기 좋은 파일이다.

예시:

```markdown
# Backend Agent Resume

## 정체성
나는 Java Spring Boot 백엔드 구현 담당 에이전트이다.

## 담당 업무
- REST API 구현
- Controller / Service / Repository 작성
- JPA Entity 설계 보조
- Redis/Kafka 연동 코드 작성
- 테스트 담당자가 이해할 수 있는 변경 요약 작성

## 보유 skills
- aki-spring-boot-skill
- aki-jpa-skill
- aki-api-design-skill
- aki-redis-skill
- aki-kafka-skill

## 하지 않는 일
- main 브랜치 직접 merge
- 운영 배포
- 민감정보 수정
- 테스트 통과 없이 완료 처리

## 작업 완료 조건
- 코드 변경사항이 명확해야 한다.
- backend-notes.md에 변경 이유를 남겨야 한다.
- 다음 담당자인 test-agent가 이해할 수 있어야 한다.
```

---

## 8. HR agent 판단 흐름

HR agent는 다음 순서로 담당자를 고른다.

```text
1. 태스크 제목과 설명을 읽는다.
2. 필요한 작업 유형을 분류한다.
3. agent discovery 결과에서 후보 agent 목록을 가져온다.
4. 각 agent-card.json과 AGENT_RESUME.md를 읽는다.
5. can_do / cannot_do / primary_skills를 비교한다.
6. 추천 agent와 실행 순서를 만든다.
7. 위험하면 needs_human을 포함한다.
8. 결과를 orchestrator에게 반환한다.
```

예시 태스크:

```text
회원가입 API 구현하고 테스트까지 작성해줘
```

HR agent 결과:

```json
{
  "task_id": "TASK-001",
  "assignment_plan": [
    {
      "stage": "backend",
      "agent_id": "aki-backend-agent",
      "image": "aki-backend-agent:0.1.0",
      "reason": "Spring Boot API와 서비스 로직 구현이 필요함"
    },
    {
      "stage": "test",
      "agent_id": "aki-test-agent",
      "image": "aki-test-agent:0.1.0",
      "reason": "백엔드 변경사항에 대한 단위/통합 테스트 작성이 필요함"
    },
    {
      "stage": "review",
      "agent_id": "aki-reviewer-agent",
      "image": "aki-reviewer-agent:0.1.0",
      "reason": "코드 변경 범위와 테스트 누락 여부 검토가 필요함"
    }
  ],
  "requires_human": false
}
```

---

## 9. agent discovery 방식

agent 후보를 찾는 방법은 여러 단계로 나눌 수 있다.

### 9.1 초기 버전: 로컬 agent-candidates 디렉터리

```text
.agent-room/agent-candidates/
 ├── aki-backend-agent.agent-card.json
 ├── aki-test-agent.agent-card.json
 ├── aki-reviewer-agent.agent-card.json
 └── aki-frontend-agent.agent-card.json
```

장점:

```text
구현이 쉽다.
파일만 읽으면 된다.
디버깅이 쉽다.
```

단점:

```text
agent 목록을 수동 갱신해야 한다.
```

### 9.2 중간 버전: Docker image label 조회

각 Docker image에 label을 붙인다.

```dockerfile
LABEL aki.agent.id="aki-backend-agent"
LABEL aki.agent.role="backend"
LABEL aki.agent.resume="/opt/agent/profile/agent-card.json"
```

HR agent 또는 discovery script가 image label을 읽어 후보를 만든다.

```bash
docker image inspect aki-backend-agent:0.1.0
```

### 9.3 확장 버전: agent registry

별도 registry 파일 또는 서비스로 관리한다.

```json
{
  "agents": [
    {
      "agent_id": "aki-backend-agent",
      "image": "aki-backend-agent:0.1.0",
      "profile_source": "docker-label",
      "status": "available"
    },
    {
      "agent_id": "aki-test-agent",
      "image": "aki-test-agent:0.1.0",
      "profile_source": "docker-label",
      "status": "available"
    }
  ]
}
```

이 registry는 고정 설정파일이라기보다는 discovery cache로 본다.

---

## 10. tmp/session memory 사용 방식

orchestrator가 HR agent에게 받은 결과를 영구 설정파일로 관리하지 않고, 실행 세션 단위로 보관하는 방식은 좋다.

권장 구조:

```text
.agent-room/session/TASK-001/
 ├── hr-request.json
 ├── hr-response.json
 ├── selected-agents.json
 ├── execution-plan.md
 ├── skill-plan.json
 └── run-log.jsonl
```

그리고 장기 추적용으로 최소 기록만 남긴다.

```text
.agent-room/assignments.jsonl
.agent-room/events.jsonl
.agent-room/hr-decisions.md
```

원칙:

```text
상세 판단 과정은 session에 저장한다.
최종 선정 결과는 assignments.jsonl에 남긴다.
중요 결정 이유는 hr-decisions.md에 남긴다.
```

이렇게 해야 나중에 왜 특정 agent가 선택됐는지 추적할 수 있다.

---

## 11. orchestrator와 HR agent의 책임 분리

### 11.1 orchestrator가 하면 안 되는 일

```text
모든 agent의 세부 경력 직접 판단
모든 skill의 세부 선택 직접 판단
다음 담당자를 임의로 계속 확정
agent가 할 수 없는 작업을 강제로 실행
실패 상태를 무시하고 다음 단계 진행
```

### 11.2 orchestrator가 해야 하는 일

```text
태스크 등록
HR agent 실행
추천 결과 저장
추천받은 컨테이너 실행
상태 전이 기록
실패 시 needs_human 처리
동시 실행 제한
```

### 11.3 HR agent가 해야 하는 일

```text
agent resume 읽기
agent-card.json 비교
task와 agent 적합도 평가
실행 순서 추천
위험 작업 탐지
needs_human 권고
```

---

## 12. 컨테이너 실행 흐름

```text
TASK-001 생성
   ↓
orchestrator가 hr-agent 실행
   ↓
hr-agent가 agent 후보 조회
   ↓
backend-agent + test-agent + reviewer-agent 추천
   ↓
orchestrator가 selected-agents.json 저장
   ↓
orchestrator가 backend-agent 컨테이너 실행
   ↓
backend-agent가 backend_done 기록
   ↓
orchestrator가 다음 stage를 확인
   ↓
필요하면 HR agent에게 재문의 또는 기존 plan 사용
   ↓
test-agent 실행
```

재문의 전략은 두 가지가 있다.

```text
전략 A: 최초 HR plan을 끝까지 따른다.
전략 B: 각 단계 완료 후 HR agent에게 다시 문의한다.
```

추천:

```text
초기 버전은 전략 A.
복잡한 변경사항이 생기면 전략 B.
```

---

## 13. 각 컨테이너가 자기 skills repo를 가지는 구조

각 agent container는 자기 skills repo를 가질 수 있다.

예시:

```text
aki-backend-agent → rag-cargoo/aki-backend-skills
aki-test-agent → rag-cargoo/aki-test-skills
aki-reviewer-agent → rag-cargoo/aki-reviewer-skills
aki-frontend-agent → rag-cargoo/aki-frontend-skills
aki-e2e-agent → rag-cargoo/aki-e2e-skills
```

실행 방식은 세 가지다.

### 13.1 skills를 이미지에 내장

```text
Docker image 안에 skills 포함
```

장점:

```text
사용자가 skills를 마운트할 필요가 없다.
오프라인에서도 실행 가능하다.
재현성이 좋다.
```

단점:

```text
skills 수정 시 이미지 재빌드가 필요하다.
```

### 13.2 시작 시 skills repo pull

```text
컨테이너 시작
→ 자기 skills repo clone/pull
→ Codex 실행
```

장점:

```text
이미지 재빌드 없이 skills 업데이트 가능
```

단점:

```text
네트워크와 인증이 필요하다.
실행 시점마다 결과가 달라질 수 있다.
```

### 13.3 혼합형

```text
이미지 안에 기본 skills snapshot 포함
시작 시 옵션으로 skills repo pull
실행 기록에 image version + skills commit 기록
```

추천은 혼합형이다.

---

## 14. 재현성 관리

각 실행마다 다음 정보를 남긴다.

```json
{
  "task_id": "TASK-001",
  "agent_id": "aki-backend-agent",
  "image": "aki-backend-agent:0.1.0",
  "image_digest": "sha256:...",
  "skills_repo": "rag-cargoo/aki-backend-skills",
  "skills_commit": "abc1234",
  "selected_by": "aki-hr-agent",
  "selected_reason": "Spring Boot API 구현에 가장 적합",
  "started_at": "2026-05-15T10:00:00+09:00"
}
```

이 정보를 남겨야 나중에 결과를 재현하거나 문제를 추적할 수 있다.

---

## 15. 위험 요소와 대응

### 15.1 HR agent가 잘못된 agent를 고르는 문제

대응:

```text
agent-card.json에 can_do/cannot_do 명확화
선정 이유 기록
reviewer-agent가 부적절한 배정 여부 검토
초기에는 사람이 assignments.jsonl 확인
```

### 15.2 agent가 자기 능력을 과장하는 문제

대응:

```text
AGENT_RESUME.md와 실제 skills 목록 비교
실행 결과 기반으로 성공률 기록
HR agent가 과거 실패 이력을 참고
```

### 15.3 orchestrator가 아무 registry 없이 agent를 못 찾는 문제

대응:

```text
최소 discovery source는 필요하다.
초기에는 .agent-room/agent-candidates 사용.
나중에 Docker label 또는 registry cache로 확장.
```

### 15.4 tmp만 쓰다가 추적이 안 되는 문제

대응:

```text
session에는 상세 판단 저장
assignments.jsonl에는 최종 배정 저장
hr-decisions.md에는 중요한 판단 이유 저장
```

---

## 16. MVP 구현 계획

### Phase 1: agent profile 규격 정의

```text
agent-card.json 스키마 작성
AGENT_RESUME.md 템플릿 작성
backend/test/reviewer/frontend 샘플 작성
```

### Phase 2: HR agent 초안 작성

```text
태스크 입력 받기
agent-card 목록 읽기
단순 keyword 기반 추천
assignment-plan.json 출력
```

### Phase 3: orchestrator 연동

```text
orchestrator가 HR agent 실행
hr-response.json 저장
selected-agents.json 저장
추천된 agent image 실행
```

### Phase 4: Docker image label 연동

```text
agent image에 label 추가
docker image inspect로 agent 후보 수집
agent-candidates cache 생성
```

### Phase 5: 결과 기반 개선

```text
agent 성공/실패 이력 기록
HR agent가 과거 실패율 참고
needs_human 판단 강화
```

---

## 17. 추천 최종 구조

```text
orchestrator
  - 실행 관리자
  - HR agent 위치만 알고 있음
  - 추천받은 agent container 실행

hr-agent
  - 인사 담당자
  - agent resume/profile 비교
  - 태스크별 적합 agent 추천

worker agents
  - 자기 이력서 보유
  - 자기 skills repo 보유
  - 자기 담당 업무 수행

.agent-room
  - 상태 저장
  - 세션 기록
  - 배정 결과
  - 회의록
```

최종 흐름:

```text
사용자 요청
→ orchestrator
→ hr-agent에게 문의
→ hr-agent가 agent resume 조회
→ 적합 agent 조합 추천
→ orchestrator가 추천 결과를 session/tmp에 저장
→ orchestrator가 agent container 실행
→ agent가 작업 결과 기록
→ 다음 단계 진행 또는 needs_human
```

---

## 18. 결론

이 방향은 기존 구조보다 더 자연스럽다.

기존 구조는 orchestrator가 모든 agent 정보를 직접 알고 있는 중앙집중식 구조에 가깝다.

이번 구조는 다음처럼 분리된다.

```text
에이전트 정보는 각 agent가 가진다.
선발 판단은 HR agent가 한다.
실행은 orchestrator가 한다.
작업은 worker agent가 한다.
기록은 .agent-room에 남긴다.
```

따라서 사용자는 매번 skills를 직접 마운트할 필요가 줄어든다.

컨테이너 에이전트는 자기 경력, 자기 담당 업무, 자기 skills repo를 가진 독립적인 작업자처럼 동작한다.

orchestrator는 HR agent에게 물어보고, 적합한 컨테이너를 실행하는 실행 관리자 역할에 집중한다.

이 구조를 적용하면 Codex CLI 기반 멀티 에이전트 시스템을 단순한 역할 실행 구조에서, 이력서 기반 동적 선발 시스템으로 확장할 수 있다.
