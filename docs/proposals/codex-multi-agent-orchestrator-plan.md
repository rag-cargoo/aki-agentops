# Codex Docker Multi-Agent Orchestrator 기획안

작성일: 2026-05-15
대상 저장소: aki-agentops
문서 목적: Codex CLI를 Docker 컨테이너 기반 멀티 에이전트 구조로 실행하고, 태스크 상태 변화에 따라 다음 담당 에이전트가 자동 실행되는 작업 시스템을 설계한다.

관련 확장 문서:

```text
docs/proposals/agent-resume-and-hr-discovery-plan.md
```

위 확장 문서는 각 컨테이너 에이전트가 자기 이력서, 담당 업무, 보유 skills repo를 직접 소유하고, orchestrator가 HR agent에게 문의하여 적합한 에이전트를 선발하는 구조를 다룬다.

---

## 1. 배경

현재 Codex CLI를 로컬 WSL 환경에서 사용하면서 AGENTS.md, skills, workflows, scripts를 기반으로 작업을 표준화하고 있다.

기존 방식은 단일 에이전트가 프로젝트를 분석하고 수정하는 구조에 가깝다. 그러나 실제 개발 흐름은 백엔드 구현, 테스트 작성, 리뷰, 커밋/PR, 프론트 반영, E2E 검증처럼 여러 역할이 순차적으로 이어진다.

이 문서는 Codex CLI를 Docker 컨테이너 단위로 분리하여 각 역할별 에이전트를 실행하고, orchestrator가 상태 변경을 감지하여 다음 에이전트를 자동 실행하는 구조를 기획한다.

추가로, agent가 많아질수록 orchestrator가 모든 agent의 세부 정보와 skills를 직접 보관하는 방식은 복잡해질 수 있다. 따라서 장기적으로는 각 agent가 자기 resume/profile을 보유하고, HR agent가 태스크에 적합한 agent를 추천하는 동적 선발 구조로 확장한다.

---

## 2. 목표

이 시스템의 목표는 다음과 같다.

1. Codex 실행 환경을 Docker 이미지로 표준화한다.
2. 역할별 에이전트 컨테이너를 분리한다.
3. backend, test, reviewer, git, frontend, e2e 같은 담당 역할을 나눈다.
4. 태스크 상태 변경을 기준으로 다음 에이전트 실행을 자동화한다.
5. 각 에이전트가 필요한 skills만 로드하거나 참조하게 한다.
6. Git worktree를 사용하여 작업 충돌을 줄인다.
7. GitHub Issue, branch, PR 흐름과 연동할 수 있게 한다.
8. 실패 시 무리하게 다음 단계로 넘기지 않고 needs_human 상태로 멈춘다.
9. 각 컨테이너 에이전트가 자기 resume/profile/skills repo를 보유하도록 확장한다.
10. orchestrator가 HR agent에게 문의하여 적합한 agent를 동적으로 선발할 수 있게 한다.

---

## 3. 핵심 아이디어

컨테이너 1개를 에이전트 1개로 본다.

```text
backend-agent   = 백엔드 구현 담당 컨테이너
test-agent      = 테스트 코드 작성 및 실행 담당 컨테이너
reviewer-agent  = diff 검토 및 위험 요소 확인 담당 컨테이너
git-agent       = 커밋, 이슈 상태 업데이트, PR 생성 담당 컨테이너
frontend-agent  = API 변경사항 기반 프론트 연동 담당 컨테이너
e2e-agent       = Playwright 등 E2E 검증 담당 컨테이너
hr-agent        = agent resume/profile 기반 담당자 선발 컨테이너
orchestrator    = 상태 감지 및 다음 컨테이너 실행 담당
```

각 에이전트는 직접 다음 에이전트를 호출하지 않는다.

각 에이전트는 자기 작업 결과만 기록한다.

다음 실행은 orchestrator가 결정한다.

agent 선발이 필요한 경우 orchestrator가 직접 모든 후보를 판단하지 않고 HR agent에게 문의한다.

---

## 4. 전체 구조

기본 실행 흐름은 다음과 같다.

```text
사용자 요청
   ↓
.agent-room/tasks.jsonl 에 태스크 등록
   ↓
orchestrator 감지
   ↓
필요 시 HR agent에게 담당자 추천 요청
   ↓
backend-agent 컨테이너 실행
   ↓
backend_done 상태 기록
   ↓
orchestrator가 test-agent 실행
   ↓
test_passed 상태 기록
   ↓
orchestrator가 reviewer-agent 실행
   ↓
review_passed 상태 기록
   ↓
orchestrator가 git-agent 실행
   ↓
PR 생성 또는 pr_ready 상태 기록
   ↓
orchestrator가 frontend-agent 실행
   ↓
frontend_done 상태 기록
   ↓
orchestrator가 e2e-agent 실행
   ↓
done 또는 needs_human
```

HR agent를 포함한 확장 구조는 다음과 같다.

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

---

## 5. 디렉터리 구조 초안

```text
aki-agentops/
 ├── AGENTS.md
 ├── skills/
 │   ├── aki-backend-skill/
 │   ├── aki-test-skill/
 │   ├── aki-review-skill/
 │   ├── aki-git-skill/
 │   ├── aki-frontend-skill/
 │   └── aki-e2e-skill/
 ├── workflows/
 │   ├── backend-to-test.yaml
 │   ├── test-to-review.yaml
 │   ├── review-to-pr.yaml
 │   └── pr-to-frontend.yaml
 ├── scripts/
 │   ├── agentctl.sh
 │   ├── orchestrator_watch.sh
 │   ├── run_agent_container.sh
 │   ├── resolve_agent_skills.sh
 │   └── update_task_state.sh
 ├── docker/
 │   ├── Dockerfile.codex-runtime
 │   └── docker-compose.agent-room.yml
 └── docs/
     └── proposals/
         ├── codex-multi-agent-orchestrator-plan.md
         └── agent-resume-and-hr-discovery-plan.md
```

프로젝트별 작업 공간 예시는 다음과 같다.

```text
workspace-root/
 ├── project-main/
 ├── project-backend-agent/
 ├── project-test-agent/
 ├── project-reviewer-agent/
 ├── project-frontend-agent/
 └── .agent-room/
     ├── tasks.jsonl
     ├── events.jsonl
     ├── assignments.jsonl
     ├── decisions.md
     ├── hr-decisions.md
     ├── backend-notes.md
     ├── test-notes.md
     ├── review-notes.md
     ├── frontend-notes.md
     ├── agent-candidates/
     ├── session/
     └── locks/
```

---

## 6. 공통 상태 저장소

초기 버전은 파일 기반으로 시작한다.

권장 파일:

```text
.agent-room/tasks.jsonl        태스크 상태
.agent-room/events.jsonl       이벤트 로그
.agent-room/assignments.jsonl  HR agent의 에이전트 배정 결과
.agent-room/decisions.md       결정 사항
.agent-room/hr-decisions.md    담당자 선발 이유
.agent-room/*-notes.md         에이전트별 작업 기록
.agent-room/session/           태스크별 임시 실행 계획과 HR 응답
.agent-room/locks/             동시쓰기 방지용 lock 파일
```

추후 확장 시 Redis 또는 SQLite를 사용할 수 있다.

```text
초기 단계: JSONL + Markdown + flock
중간 단계: SQLite
확장 단계: Redis Streams 또는 Redis Queue
GitHub 연동 단계: Issue, Label, PR 상태와 동기화
```

---

## 7. 태스크 상태 모델

태스크 상태는 명확한 상태 전이로 관리한다.

```text
todo
→ hr_selecting
→ assigned
→ backend_running
→ backend_done
→ test_running
→ test_passed
→ review_running
→ review_passed
→ pr_ready
→ pr_opened
→ frontend_running
→ frontend_done
→ e2e_running
→ e2e_passed
→ done
```

실패 상태도 반드시 둔다.

```text
hr_failed
backend_failed
test_failed
review_failed
merge_conflict
needs_human
```

needs_human은 자동화가 더 진행되면 위험한 상황에서 멈추기 위한 상태다.

예시:

```json
{
  "id": "TASK-001",
  "title": "회원가입 API 구현",
  "owner": "backend",
  "status": "backend_done",
  "next": "test",
  "branch": "agent/backend/TASK-001",
  "worktree": "../project-backend-agent",
  "updated_at": "2026-05-15T10:00:00+09:00"
}
```

---

## 8. 이벤트 로그 모델

각 에이전트는 자기 작업이 끝나면 events.jsonl에 이벤트를 기록한다.

```jsonl
{"time":"2026-05-15T10:00:00+09:00","task":"TASK-001","event":"hr_selecting","agent":"hr"}
{"time":"2026-05-15T10:01:00+09:00","task":"TASK-001","event":"agent_assigned","agent":"hr"}
{"time":"2026-05-15T10:02:00+09:00","task":"TASK-001","event":"backend_started","agent":"backend"}
{"time":"2026-05-15T10:20:00+09:00","task":"TASK-001","event":"backend_done","agent":"backend"}
{"time":"2026-05-15T10:22:00+09:00","task":"TASK-001","event":"test_started","agent":"test"}
{"time":"2026-05-15T10:35:00+09:00","task":"TASK-001","event":"test_passed","agent":"test"}
```

이 이벤트를 orchestrator가 읽고 다음 단계를 실행한다.

---

## 9. 역할별 에이전트 정의

### 9.1 hr-agent

역할:

- 태스크 내용 분석
- agent resume/profile 조회
- agent 후보 비교
- 역할별 agent 추천
- 추천 이유 작성
- 실행 순서 제안
- 위험 시 needs_human 권고

출력:

- selected-agents.json
- assignments.jsonl
- hr-decisions.md

상세 설계는 다음 문서를 따른다.

```text
docs/proposals/agent-resume-and-hr-discovery-plan.md
```

### 9.2 backend-agent

역할:

- API, 서비스 로직, DB 연동 구현
- 변경 범위 기록
- 테스트 담당자가 이해할 수 있도록 구현 의도 작성
- 완료 후 backend_done 또는 backend_failed 상태 기록

입력:

- TASK ID
- 요구사항
- 관련 backend skill
- 프로젝트 worktree

출력:

- 코드 변경
- backend-notes.md
- events.jsonl
- tasks.jsonl 상태 변경

### 9.3 test-agent

역할:

- backend 변경사항 분석
- 단위 테스트, 통합 테스트, API 테스트 작성
- 테스트 실행
- 실패 원인 정리
- 통과 시 test_passed 상태 기록

출력:

- 테스트 코드
- test-notes.md
- test_passed 또는 test_failed

### 9.4 reviewer-agent

역할:

- git diff 검토
- 위험한 변경 확인
- 불필요한 변경 제거 권고
- 보안, 예외처리, 테스트 누락 확인
- 통과 시 review_passed 기록

출력:

- review-notes.md
- review_passed 또는 review_failed

### 9.5 git-agent

역할:

- 변경 파일 확인
- 커밋 메시지 작성
- 이슈 체크리스트 업데이트
- 브랜치 push
- PR 생성 또는 PR 초안 작성

주의:

- 초기 버전에서는 실제 push/PR 생성 전 needs_human 또는 pr_ready로 멈추는 옵션을 둔다.
- 안정화 이후 자동 PR 생성으로 확장한다.

### 9.6 frontend-agent

역할:

- backend API 변경사항 확인
- 타입, API client, UI 연동 수정
- 프론트 테스트 실행
- 완료 후 frontend_done 기록

### 9.7 e2e-agent

역할:

- Playwright 등 E2E 테스트 실행
- 사용자 플로우 검증
- 실패 시 재현 절차 기록
- 성공 시 e2e_passed 기록

---

## 10. orchestrator 역할

orchestrator는 전체 자동화의 중심이다.

역할:

1. tasks.jsonl 또는 Redis/SQLite 상태를 감시한다.
2. 특정 상태가 되면 다음 에이전트를 결정한다.
3. 담당자 선발이 필요하면 HR agent에게 문의한다.
4. HR agent의 추천 결과를 session/tmp와 assignments 로그에 저장한다.
5. 필요한 skills를 계산하거나, agent container가 자기 skills를 사용하도록 실행한다.
6. 프로젝트 worktree와 .agent-room을 컨테이너에 마운트한다.
7. 역할별 Codex prompt를 생성한다.
8. Docker 컨테이너를 실행한다.
9. 성공/실패 이벤트를 기록한다.
10. 실패 시 재시도하거나 needs_human 상태로 멈춘다.

중요 원칙:

```text
에이전트는 다음 에이전트를 직접 실행하지 않는다.
orchestrator만 다음 컨테이너 실행 권한을 가진다.
orchestrator는 agent의 세부 경력 판단을 HR agent에게 위임할 수 있다.
```

---

## 11. orchestrator가 필요한 skills를 포함해서 컨테이너를 띄우는 구조

가능하다.

orchestrator는 태스크 상태, 태스크 유형, 변경 파일, skill index를 기준으로 필요한 skills를 결정할 수 있다.

또는 각 agent container가 자기 skills repo를 보유하도록 만들고, orchestrator는 agent image만 실행할 수 있다.

예시:

```json
{
  "task_id": "TASK-001",
  "stage": "test",
  "changed_files": [
    "src/main/java/com/example/member/MemberService.java",
    "src/main/java/com/example/member/MemberController.java"
  ],
  "required_skills": [
    "aki-test-skill",
    "aki-spring-boot-skill",
    "aki-api-test-skill"
  ]
}
```

orchestrator는 이 정보를 기반으로 컨테이너 실행 시 필요한 skills만 마운트하거나, 전체 skills를 마운트한 뒤 role prompt에서 사용할 skills를 제한할 수 있다.

또는 HR agent가 다음처럼 agent image 자체를 추천할 수 있다.

```json
{
  "stage": "backend",
  "agent_id": "aki-backend-agent",
  "image": "aki-backend-agent:0.1.0",
  "skills_repo": "rag-cargoo/aki-backend-skills",
  "reason": "Spring Boot API 구현과 JPA 연동이 필요한 작업"
}
```

이 경우 사용자는 직접 skills를 마운트하지 않고, agent container가 자기 skills snapshot 또는 skills repo를 사용한다.

방식 A: 전체 skills 마운트, prompt로 사용 범위 제한

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -v "$HOME/aki-agentops/skills:/opt/aki-agentops/skills:ro" \
  -v "$HOME/aki-agentops/workflows:/opt/aki-agentops/workflows:ro" \
  aki-codex-runtime:latest \
  codex "TASK-001 테스트 단계 수행. 사용할 skills: aki-test-skill, aki-spring-boot-skill"
```

장점:

- 구현이 쉽다.
- skills 변경 시 이미지 재빌드가 필요 없다.

단점:

- 컨테이너 안에서 모든 skills가 보인다.
- prompt 규칙이 약하면 관련 없는 skill을 참조할 수 있다.

방식 B: 필요한 skills만 임시 디렉터리에 복사 후 마운트

```text
.agent-runtime/TASK-001/test/skills/
 ├── aki-test-skill/
 ├── aki-spring-boot-skill/
 └── aki-api-test-skill/
```

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -v "$PWD/.agent-runtime/TASK-001/test/skills:/opt/aki-agentops/skills:ro" \
  aki-codex-runtime:latest \
  codex "TASK-001 테스트 단계 수행"
```

장점:

- 컨텍스트와 참조 범위를 줄일 수 있다.
- 역할별 격리가 좋다.

단점:

- resolve_agent_skills.sh 같은 사전 준비 스크립트가 필요하다.

방식 C: 역할별 agent image가 자기 skills를 보유

```text
aki-backend-agent:0.1.0 안에 backend skills 포함
aki-test-agent:0.1.0 안에 test skills 포함
aki-frontend-agent:0.1.0 안에 frontend skills 포함
```

장점:

- 사용자가 skills를 직접 마운트할 필요가 거의 없다.
- 각 컨테이너가 자기 경력과 skills를 가진 독립 agent처럼 동작한다.
- orchestrator는 agent image 실행에 집중할 수 있다.

단점:

- skills 수정 시 image rebuild 또는 시작 시 skills repo pull 전략이 필요하다.
- 재현성을 위해 image version과 skills commit 기록이 필요하다.

추천:

초기 버전은 방식 A로 시작한다.
agent 수가 늘어나면 방식 C와 HR agent 선발 구조로 확장한다.

---

## 12. skill index 설계

skills를 자동 선택하려면 index 파일이 필요하다.

예시:

```json
{
  "skills": [
    {
      "name": "aki-spring-boot-skill",
      "path": "skills/aki-spring-boot-skill",
      "triggers": ["Spring Boot", "Java", "Controller", "Service", "Repository", "JPA"],
      "file_patterns": ["src/main/java/**/*.java", "build.gradle", "pom.xml"],
      "roles": ["backend", "test", "reviewer"]
    },
    {
      "name": "aki-frontend-skill",
      "path": "skills/aki-frontend-skill",
      "triggers": ["React", "TypeScript", "Vite", "API client", "frontend"],
      "file_patterns": ["src/**/*.tsx", "src/**/*.ts", "package.json"],
      "roles": ["frontend", "reviewer"]
    },
    {
      "name": "aki-playwright-skill",
      "path": "skills/aki-playwright-skill",
      "triggers": ["Playwright", "E2E", "browser", "smoke test"],
      "file_patterns": ["tests/**/*.spec.ts", "playwright.config.ts"],
      "roles": ["e2e", "test"]
    }
  ]
}
```

orchestrator는 다음 조건을 조합해서 skills를 고른다.

```text
role 기반 선택
+ task title/description 키워드
+ 변경 파일 패턴
+ 프로젝트 타입
+ 이전 단계 notes 내용
+ workflow 정의
```

HR agent 확장 구조에서는 skill index 외에도 각 agent의 agent-card.json과 AGENT_RESUME.md를 함께 사용한다.

---

## 13. agent resume / profile 설계

각 컨테이너 에이전트는 자기 이력서를 가진다.

```text
/opt/agent/profile/AGENT_RESUME.md
/opt/agent/profile/agent-card.json
/opt/agent/skills/
```

agent-card.json 예시:

```json
{
  "agent_id": "aki-backend-agent",
  "display_name": "Backend Agent",
  "role": "backend",
  "version": "0.1.0",
  "docker_image": "aki-backend-agent:0.1.0",
  "career_summary": "Java Spring Boot, REST API, JPA, Redis, Kafka 기반 백엔드 구현 담당",
  "primary_skills": ["Java", "Spring Boot", "JPA", "REST API"],
  "can_do": ["API 구현", "서비스 로직 작성", "DB 연동"],
  "cannot_do": ["main 브랜치 직접 merge", "운영 배포", "민감정보 수정"],
  "skills_repo": "rag-cargoo/aki-backend-skills"
}
```

상세 설계는 다음 문서를 따른다.

```text
docs/proposals/agent-resume-and-hr-discovery-plan.md
```

---

## 14. Docker 실행 구조

공통 이미지:

```text
aki-codex-runtime:latest
```

역할별 이미지:

```text
aki-hr-agent:0.1.0
aki-backend-agent:0.1.0
aki-test-agent:0.1.0
aki-reviewer-agent:0.1.0
aki-git-agent:0.1.0
aki-frontend-agent:0.1.0
aki-e2e-agent:0.1.0
```

이미지에 포함할 것:

```text
codex cli
git
gh
jq
yq
bash
curl
node/npm
python3
java/maven/gradle 선택 옵션
kubectl/terraform 선택 옵션
agentctl 기본 스크립트
agent profile/resume 선택 옵션
역할별 skills snapshot 선택 옵션
```

이미지에 포함하지 않을 것:

```text
개인 API key
AWS credential
SSH private key
프로젝트 소스 전체
민감한 회사 정보
```

실행 시 마운트할 것:

```text
/workspace                    에이전트별 worktree
/agent-room                   공통 상태 디렉터리
/opt/aki-agentops/skills      공통 skills 또는 선택적 skills
/opt/aki-agentops/workflows   workflows
/home/codex/.codex            Codex 설정
```

역할별 agent image가 자기 skills를 보유하는 경우, 사용자는 기본적으로 프로젝트와 .agent-room만 마운트해도 된다.

---

## 15. Git worktree 전략

같은 프로젝트 폴더를 여러 에이전트가 동시에 수정하면 충돌 위험이 있다.

따라서 에이전트별 Git worktree를 사용한다.

예시:

```bash
git worktree add ../project-backend-agent -b agent/backend/TASK-001
git worktree add ../project-test-agent -b agent/test/TASK-001
git worktree add ../project-frontend-agent -b agent/frontend/TASK-001
```

추천 방식:

```text
backend-agent는 backend worktree에서 작업한다.
test-agent는 backend 변경 브랜치를 기반으로 test worktree를 만든다.
reviewer-agent는 diff를 읽고 검토한다.
git-agent가 최종 브랜치를 정리한다.
frontend-agent는 backend PR 또는 API contract를 기준으로 별도 브랜치에서 작업한다.
```

---

## 16. GitHub Issue/PR 연동

초기에는 로컬 파일 기반으로 상태를 관리한다.

이후 GitHub와 연동한다.

연동 항목:

```text
GitHub Issue = 태스크 단위
Issue Label = 현재 상태
Issue Comment = 에이전트 작업 로그
Branch = agent 작업 결과
Pull Request = 검토 단위
PR Label = stage 상태
Checks = 테스트/E2E 결과
```

예시 라벨:

```text
agent:hr-selected
agent:backend-done
agent:test-passed
agent:review-passed
agent:pr-ready
agent:frontend-needed
agent:needs-human
```

흐름:

```text
hr_selected
→ GitHub Issue label: agent:hr-selected
→ orchestrator가 backend-agent 실행
→ backend_done
→ GitHub Issue label: agent:backend-done
→ orchestrator가 test-agent 실행
→ test_passed
→ label 변경
→ reviewer-agent 실행
→ pr_ready
→ git-agent가 PR 생성
```

---

## 17. 자동화 수준

처음부터 모든 것을 완전 자동화하지 않는다.

초기 자동화 가능:

```text
역할별 Codex 컨테이너 실행
HR agent 기반 담당자 추천
상태 파일 업데이트
테스트 실행
diff 요약
회의록/notes 작성
PR 초안 내용 생성
```

사람 확인 권장:

```text
실제 커밋
실제 push
실제 PR 생성
main merge
운영 배포
민감한 파일 수정
HR agent가 확신하지 못한 담당자 배정
```

안정화 이후 자동화 가능:

```text
테스트 통과 시 자동 커밋
review 통과 시 자동 PR 생성
PR 생성 후 frontend-agent 자동 실행
E2E 통과 시 merge-ready 라벨 부여
```

---

## 18. agentctl 명령 초안

```bash
agentctl init
agentctl task create "회원가입 API 구현" --role backend
agentctl assign TASK-001
agentctl run hr TASK-001
agentctl run backend TASK-001
agentctl run test TASK-001
agentctl run reviewer TASK-001
agentctl watch
agentctl status TASK-001
agentctl logs TASK-001
agentctl stop TASK-001
```

watch 모드:

```bash
agentctl watch
```

역할:

```text
tasks.jsonl 감시
필요 시 HR agent 실행
상태 전이 판단
필요 skills 계산 또는 agent image 선택
컨테이너 실행
events.jsonl 기록
실패 시 needs_human 처리
```

---

## 19. 최소 구현 MVP

MVP 목표:

```text
1. Docker 기반 codexd wrapper 생성
2. .agent-room/tasks.jsonl 생성
3. agent-card.json 샘플 작성
4. HR agent가 backend/test/reviewer 후보 추천
5. backend-agent 실행
6. backend_done 이벤트 기록
7. orchestrator가 test-agent 자동 실행
8. test-agent가 테스트 실행 후 test_passed/test_failed 기록
9. reviewer-agent가 diff 검토
```

MVP에서 제외:

```text
GitHub PR 자동 생성
Redis 연동
프론트 자동 수정
완전 자동 merge
Docker label 기반 discovery
```

---

## 20. 단계별 구현 계획

### Phase 1: 로컬 파일 기반 멀티 에이전트

- codex runtime Dockerfile 작성
- codexd wrapper 작성
- .agent-room 구조 생성
- tasks.jsonl/events.jsonl 포맷 정의
- agent별 prompt 템플릿 작성
- agentctl run 구현

### Phase 2: HR agent + agent resume 도입

- agent-card.json 스키마 작성
- AGENT_RESUME.md 템플릿 작성
- backend/test/reviewer/frontend 샘플 작성
- HR agent가 agent-card를 읽고 assignment plan 생성

### Phase 3: orchestrator watch 구현

- 상태 전이 테이블 작성
- todo → hr_selecting → assigned 흐름 추가
- backend_done → test 실행
- test_passed → reviewer 실행
- test_failed → needs_human 또는 backend 재작업
- flock 기반 동시쓰기 방지

### Phase 4: skill resolver 구현

- skill-index.json 작성
- role/file_pattern/keyword 기반 skills 선택
- 전체 skills 마운트 방식에서 시작
- agent image 내장 skills 방식으로 확장
- 필요한 skills만 임시 디렉터리에 복사하는 방식도 지원

### Phase 5: Git worktree 연동

- TASK ID 기반 브랜치 생성
- 에이전트별 worktree 생성
- diff 수집
- reviewer-agent 검토

### Phase 6: GitHub Issue/PR 연동

- Issue 생성/업데이트
- Label 기반 상태 동기화
- PR draft 생성
- PR comment에 agent notes 첨부

### Phase 7: 프론트/E2E 자동화

- backend PR 생성 후 frontend-needed 상태 생성
- frontend-agent 실행
- Playwright smoke/e2e 실행
- merge-ready 상태 기록

---

## 21. 위험 요소

### 21.1 동시 수정 충돌

대응:

- 같은 폴더 동시 수정 금지
- Git worktree 사용
- 공통 파일은 append-only 또는 flock 사용

### 21.2 에이전트 폭주

대응:

- orchestrator만 다음 컨테이너 실행 가능
- 최대 실행 개수 제한
- 재시도 횟수 제한
- needs_human 상태 도입

### 21.3 HR agent의 잘못된 배정

대응:

- agent-card.json의 can_do/cannot_do 명확화
- HR agent의 추천 이유 기록
- assignments.jsonl에 최종 배정 기록
- 초기에는 사람이 배정 결과 확인

### 21.4 잘못된 자동 커밋/PR

대응:

- 초기에는 pr_ready까지만 자동화
- 실제 push/PR은 수동 확인
- 안정화 후 자동 PR 생성 허용

### 21.5 민감정보 노출

대응:

- .ssh, .aws, .env 기본 마운트 금지
- 필요한 작업에서만 read-only 마운트
- secret은 Docker image에 포함하지 않음

### 21.6 skill 선택 오류

대응:

- skill-index.json 관리
- agent-card.json 관리
- agent notes에 사용한 skill 기록
- reviewer가 부적절한 skill 사용 여부 확인

---

## 22. 결론

이 구조는 가능하고, Codex CLI를 단순한 단일 실행 도구가 아니라 역할 기반 자동 작업 시스템으로 확장할 수 있다.

핵심은 다음과 같다.

```text
Docker = 에이전트 실행 격리
Git worktree = 파일 충돌 방지
.agent-room = 공통 상태/회의실
orchestrator = 다음 단계 실행 담당
HR agent = agent resume 기반 담당자 선발
agent resume/profile = 각 컨테이너 에이전트의 경력과 담당 업무
skills = 역할별 작업 규칙과 지식
GitHub = 이슈/PR/협업 상태 관리
```

초기에는 파일 기반으로 작게 시작하고, 이후 Redis/SQLite/GitHub 연동으로 확장하는 것이 현실적이다.

가장 중요한 원칙은 다음이다.

```text
에이전트는 자기 작업만 한다.
에이전트는 자기 경력과 skills를 가진다.
상태만 기록한다.
담당자 선발은 HR agent가 한다.
다음 에이전트 실행은 orchestrator가 한다.
위험하면 needs_human으로 멈춘다.
```

이 원칙을 지키면 백엔드 구현 → 테스트 작성 → 검증 → PR → 프론트 반영 → E2E 검증까지 이어지는 멀티 에이전트 개발 파이프라인을 구성할 수 있다.

또한 agent가 많아져도 orchestrator가 모든 agent 정보를 직접 보관하지 않고, HR agent와 agent resume을 통해 동적으로 담당자를 선발하는 구조로 확장할 수 있다.
