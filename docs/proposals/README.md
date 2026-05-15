# aki-agentops 기획안 문서 목록

작성일: 2026-05-15

이 디렉터리는 Codex CLI 기반 Docker Multi-Agent Orchestrator 구상과 관련된 기획안을 정리한다.

---

## 1. Codex Docker Multi-Agent Orchestrator 기획안

문서:

```text
docs/proposals/codex-multi-agent-orchestrator-plan.md
```

역할:

```text
전체 멀티 에이전트 파이프라인 설계
orchestrator 중심 실행 흐름
backend/test/reviewer/git/frontend/e2e agent 구조
.agent-room 상태 저장소
Git worktree 기반 충돌 방지
GitHub Issue/PR 연동 방향
```

---

## 2. Agent Resume + HR Discovery 기반 선발 기획안

문서:

```text
docs/proposals/agent-resume-and-hr-discovery-plan.md
```

역할:

```text
각 컨테이너 에이전트가 자기 resume/profile/skills repo를 보유하는 구조
HR agent가 agent-card.json과 AGENT_RESUME.md를 보고 담당자를 선발하는 구조
orchestrator가 모든 agent 정보를 직접 보관하지 않고 HR agent에게 문의하는 구조
agent discovery / docker label / registry cache 확장 방향
```

---

## 3. HR Agent 기반 에이전트 인사고과 및 생애주기 관리 기획안

문서:

```text
docs/proposals/hr-agent-performance-lifecycle-plan.md
```

역할:

```text
HR agent가 각 컨테이너 에이전트의 성과 점수를 관리하는 구조
active/watchlist/probation/suspended/retraining/replacement_requested 생애주기
성과 저하 시 재교육 또는 신규 agent 생성 권고
성과 좋은 agent의 검증된 skills/troubleshooting/lessons를 신규 agent seed 자료로 반영하는 구조
```

핵심 상태 전이:

```text
1단계: watchlist
   성과 저하 감지

2단계: probation
   단독 배정 금지, reviewer 동반

3단계: suspended
   자동 배정 금지

4단계: retraining
   skill-maintainer-agent가 부족한 skills 보강 PR 생성

5단계: replacement_requested
   새 agent container 생성 권고
```

---

## 4. 역할별 책임 정리

```text
orchestrator
  실행 관리자
  상태 전이 관리
  컨테이너 실행

hr-agent
  담당자 선발
  성과 평가
  배정 제한
  재교육 요청
  신규 agent 생성 권고

worker-agent
  실제 작업 수행
  자기 repo에 경험 로그와 troubleshooting 초안 작성

reviewer-agent
  코드와 기술 정확성 검토

skill-maintainer-agent
  경험 기록을 skills/troubleshooting/profile 업데이트 후보로 정리
  부족한 skills 보강 PR 생성
  우수 agent 자료를 신규 agent seed pack으로 정리

git-agent
  branch/commit/PR 생성

human
  최종 merge 승인
  위험 작업 승인
```

---

## 5. 최종 방향

최종 목표는 단순히 Codex 컨테이너를 여러 개 실행하는 것이 아니다.

목표는 다음과 같다.

```text
각 agent는 자기 repo와 이력서를 가진다.
각 agent는 자기 경험과 troubleshooting 기록을 쌓는다.
HR agent는 성과를 평가하고 배정한다.
skill-maintainer-agent는 경험을 검증된 skill로 정리한다.
orchestrator는 적합한 컨테이너를 실행한다.
성과가 좋은 agent의 지식은 신규 agent 생성 시 seed 자료로 반영된다.
성과가 낮은 agent는 재교육 또는 교체 흐름을 거친다.
```
