# HR Agent 기반 에이전트 인사고과 및 생애주기 관리 기획안

작성일: 2026-05-15
대상 저장소: aki-agentops
관련 문서:

```text
docs/proposals/codex-multi-agent-orchestrator-plan.md
docs/proposals/agent-resume-and-hr-discovery-plan.md
```

---

## 1. 문서 목적

이 문서는 컨테이너 기반 Codex 멀티 에이전트 시스템에서 HR agent가 각 컨테이너 에이전트의 성과를 평가하고, 점수와 상태를 기반으로 배정 우선순위, 배정 제한, 재교육, 신규 agent container 생성 권고까지 관리하는 구조를 설계한다.

기존 구조에서는 HR agent가 다음 역할을 담당했다.

```text
agent resume/profile 조회
태스크에 적합한 agent 선발
담당자 추천
```

이번 확장에서는 HR agent 역할을 다음까지 넓힌다.

```text
성과 평가
점수 관리
배정 제한
watchlist/probation/suspended 관리
retraining 요청
신규 agent 생성 권고
우수 agent의 경험과 skills를 신규 agent 생성 시 반영
```

단, HR agent는 기술 지식 자체를 수정하지 않는다.

기술 지식, troubleshooting, skills, agent resume 업데이트 초안은 skill-maintainer-agent가 담당한다.

---

## 2. 역할 분리

최종 역할 분리는 다음과 같다.

```text
orchestrator
  실행 관리자
  상태 전이 관리
  컨테이너 실행

hr-agent
  인사/배정/성과평가/배정제한/신규 agent 생성 권고

worker-agent
  backend/test/frontend/infra 등 실제 작업 수행
  자기 repo에 경험 로그와 트러블슈팅 초안 작성

reviewer-agent
  작업 결과와 기술 정확성 검토
  코드 리뷰 및 위험 요소 확인

skill-maintainer-agent
  경험 기록을 skills/troubleshooting/profile 업데이트 후보로 정리
  부족한 skills 보강 PR 작성
  우수 agent의 지식과 패턴을 신규 agent seed 자료로 정리

git-agent
  각 agent repo에 branch/commit/PR 생성

human
  최종 merge 승인
  자동화 정책 조정
```

중요한 원칙:

```text
HR agent는 평가와 배정을 담당한다.
skill-maintainer-agent는 지식과 skills 업데이트를 담당한다.
reviewer-agent는 기술 검토를 담당한다.
orchestrator는 실행을 담당한다.
```

---

## 3. HR agent의 인사고과 기능

HR agent는 각 에이전트의 작업 결과를 기반으로 점수를 관리한다.

평가 데이터는 다음 출처에서 수집한다.

```text
.agent-room/events.jsonl
.agent-room/assignments.jsonl
.agent-room/reviews/*.md
.agent-room/test-results/*.json
각 agent repo의 memory/experience logs
각 agent repo의 troubleshooting records
각 PR 결과
CI/E2E 결과
needs_human 발생 기록
```

HR agent는 이 데이터를 기반으로 다음을 판단한다.

```text
이 agent가 특정 작업을 잘 수행하는가
최근 성과가 떨어지고 있는가
같은 실수를 반복하는가
어려운 작업을 성공적으로 처리했는가
테스트/리뷰 통과율이 어떤가
자동 배정해도 되는가
재교육이 필요한가
새 agent가 필요한가
```

---

## 4. 성과 점수 모델

각 agent는 성과 점수를 가진다.

예시:

```json
{
  "agent_id": "aki-backend-agent",
  "role": "backend",
  "score": 82,
  "status": "active",
  "completed_tasks": 24,
  "success_count": 19,
  "failure_count": 5,
  "test_pass_rate": 0.79,
  "review_pass_rate": 0.83,
  "rollback_count": 1,
  "needs_human_count": 3,
  "recent_failures": [
    "테스트 누락",
    "예외 처리 미흡"
  ],
  "strengths": [
    "Spring Boot API 구현",
    "JPA Repository 작성"
  ],
  "weaknesses": [
    "동시성 케이스 고려 부족"
  ],
  "last_evaluated_at": "2026-05-15T10:00:00+09:00"
}
```

점수는 단순 성공/실패만으로 계산하지 않는다.

반드시 난이도와 반복 실패 여부를 반영한다.

```text
쉬운 작업 성공 = 소폭 가점
어려운 작업 성공 = 큰 가점
쉬운 작업 반복 실패 = 큰 감점
어려운 작업 실패 = 소폭 감점 또는 중립
보안 위험 행동 = 큰 감점
같은 실수 반복 = 누적 감점
좋은 troubleshooting 기록 = 가점
재사용 가능한 skill 후보 생성 = 가점
```

---

## 5. 가점 기준

HR agent는 다음 경우에 가점을 줄 수 있다.

```text
태스크 완료
테스트 통과
리뷰 통과
재작업 없이 완료
E2E 통과
난이도 높은 작업 성공
좋은 troubleshooting 기록 생성
재사용 가능한 skill 후보 생성
다른 agent가 참고할 수 있는 notes 작성
예외 상황을 명확히 기록
보안정보 없이 안전하게 기록
```

예시:

```json
{
  "task_id": "TASK-041",
  "agent_id": "aki-backend-agent",
  "difficulty": "hard",
  "result": "success",
  "score_delta": 8,
  "reason": "난이도 높은 Redis 동시성 문제를 테스트 통과 상태로 해결"
}
```

---

## 6. 감점 기준

HR agent는 다음 경우에 감점을 줄 수 있다.

```text
테스트 실패
리뷰 실패
같은 실수 반복
불필요한 파일 수정
요구사항과 다른 구현
보안정보 노출 시도
민감한 파일 수정 시도
main merge 위험 작업 시도
작업 결과 설명 부족
다음 agent가 이해하기 어려운 notes 작성
needs_human 반복 발생
```

예시:

```json
{
  "task_id": "TASK-052",
  "agent_id": "aki-backend-agent",
  "difficulty": "normal",
  "result": "review_failed",
  "score_delta": -6,
  "reason": "예외 처리 누락과 테스트 누락이 반복됨"
}
```

---

## 7. 난이도 가중치

점수를 공정하게 만들기 위해 태스크 난이도를 반영한다.

```text
easy
normal
hard
critical
```

예시 정책:

```text
easy 성공: +1
normal 성공: +3
hard 성공: +6
critical 성공: +10

easy 실패: -5
normal 실패: -4
hard 실패: -2
critical 실패: -1 또는 needs_human
```

이렇게 해야 어려운 일을 맡은 agent가 불리해지지 않는다.

반대로 쉬운 일을 반복 실패하는 agent는 빠르게 watchlist에 올라갈 수 있다.

---

## 8. 에이전트 상태 모델

HR agent는 각 agent의 상태를 관리한다.

```text
active
  정상 배정 가능

watchlist
  성과 저하 또는 반복 실패 관찰 대상

probation
  제한적 배정만 허용
  단독 배정 금지
  reviewer 동반 필수

suspended
  자동 배정 금지
  HR agent가 일반 태스크에 추천하지 않음

retraining
  skill-maintainer-agent가 부족한 skills 보강 PR 생성
  재교육/보강 이후 probation으로 복귀 가능

retired
  더 이상 사용하지 않음

replacement_requested
  새 agent container 생성 권고
```

---

## 9. 단계별 성과 저하 처리

성과가 떨어지는 agent는 바로 폐기하지 않는다.

다음 단계를 거친다.

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

이 단계는 agent를 단순 폐기하기보다 먼저 개선 기회를 주기 위한 구조다.

---

## 10. watchlist 단계

watchlist는 성과 저하를 감지하는 단계다.

진입 조건 예시:

```text
최근 5개 작업 중 3개 이상 review_failed
최근 5개 작업 중 3개 이상 test_failed
needs_human 발생 증가
같은 유형의 실수 반복
score 55~70 구간 진입
```

watchlist 상태에서는 자동 배정은 가능하지만 HR agent가 선정 이유에 경고를 남긴다.

예시:

```text
aki-backend-agent는 현재 watchlist 상태이다.
최근 예외 처리 누락이 반복되었으므로 reviewer-agent 동반을 권장한다.
```

---

## 11. probation 단계

probation은 제한 배정 단계다.

조건:

```text
score 40~55 구간
watchlist 상태에서 개선 없음
반복 실패 지속
```

정책:

```text
단독 배정 금지
reviewer-agent 동반 필수
easy 또는 normal 작업만 배정
hard/critical 작업 배정 금지
작업 완료 후 반드시 review 필요
```

예시:

```text
aki-backend-agent는 probation 상태이므로 Redis 동시성 문제 단독 배정 불가.
aki-reviewer-agent와 함께 배정하거나 다른 agent를 우선 추천한다.
```

---

## 12. suspended 단계

suspended는 자동 배정 금지 단계다.

조건:

```text
score < 40
보안 위험 행동
민감정보 기록 시도
main merge 위험 작업 시도
probation 이후에도 개선 없음
```

정책:

```text
일반 태스크 자동 배정 금지
HR agent 추천 후보에서 제외
retraining 또는 replacement 판단 대상으로 전환
```

예시:

```json
{
  "agent_id": "aki-old-backend-agent",
  "status": "suspended",
  "reason": "최근 Redis 관련 작업 3회 연속 실패 및 테스트 누락 반복",
  "auto_assignment_allowed": false
}
```

---

## 13. retraining 단계

retraining은 agent를 폐기하기 전에 부족한 skills를 보강하는 단계다.

흐름:

```text
HR agent가 반복 실패 패턴 감지
↓
부족 skill 영역 식별
↓
skill-maintainer-agent에게 보강 요청
↓
skill-maintainer-agent가 해당 agent repo에 skill/troubleshooting 보강 PR 생성
↓
reviewer-agent가 기술 검토
↓
git-agent가 PR 생성
↓
human merge
↓
agent 상태를 probation으로 복귀시켜 재평가
```

예시:

```markdown
# Retraining Request

## 대상
aki-backend-agent

## 문제
최근 10개 태스크 중 4개에서 Redis lock 처리 실패.
동시성 테스트 누락 반복.

## 보강 필요 skills
- Redis Lock
- Redisson
- Spring Transaction
- Race Condition Test

## 요청
skill-maintainer-agent는 aki-backend-agent repo에 Redis 동시성 troubleshooting 문서와 테스트 패턴 skill 후보를 추가한다.
```

---

## 14. replacement_requested 단계

retraining 이후에도 개선되지 않거나, 기존 agent의 범위를 넘어서는 전문성이 필요하면 신규 agent container 생성을 권고한다.

예시:

```markdown
# Replacement Recommendation

## 대상
aki-backend-agent

## 사유
최근 10개 태스크 중 6개에서 테스트 실패.
특히 Redis 동시성 처리와 예외 처리에서 반복 실패.

## 권고
기존 backend-agent를 즉시 폐기하지는 않는다.
다만 Redis/Concurrency 전담 agent를 새로 생성하는 것을 권장한다.

## 신규 agent 후보
aki-redis-concurrency-agent

## 필요한 skills
- Redis Lock
- Redisson
- Distributed Lock
- Spring Transaction
- Race Condition Test
- Deadlock 분석
```

---

## 15. 우수 agent 성과 반영

성과가 좋은 agent는 신규 agent 생성 시 seed 자료로 사용한다.

좋은 agent의 다음 자료를 추출한다.

```text
성공한 troubleshooting 기록
반복적으로 통과한 작업 패턴
reviewer-agent가 좋게 평가한 코드/문서 패턴
test_passed 비율이 높은 구현 방식
다른 agent에게 재사용 가능한 skill 후보
작업 notes 작성 방식
실패를 줄이는 체크리스트
```

이 자료는 신규 agent를 만들 때 다음에 반영한다.

```text
신규 agent의 AGENT_RESUME.md
신규 agent의 agent-card.json
신규 agent의 skills/
신규 agent의 troubleshooting/
신규 agent의 lessons-learned/
신규 agent의 default workflow
```

즉 우수 agent의 경험은 조직 전체의 자산이 된다.

---

## 16. 신규 agent 생성 시 성과 데이터 반영

새 agent container를 생성할 때 HR agent는 단순히 빈 agent를 만들라고 권고하지 않는다.

기존 우수 agent의 점수, 성공 패턴, 검증된 skills 자료를 반영하도록 요청한다.

흐름:

```text
HR agent가 신규 agent 필요 판단
↓
성과 좋은 기존 agent 후보 탐색
↓
성공 패턴과 검증된 skill 자료 수집
↓
skill-maintainer-agent가 신규 agent seed pack 작성
↓
git-agent가 신규 agent repo 생성 또는 초기 구조 PR 생성
↓
Docker image build 정의 생성
↓
신규 agent가 probation 상태로 등록
```

seed pack 예시:

```text
.agent-room/agent-seed-packs/aki-redis-concurrency-agent/
 ├── AGENT_RESUME.md
 ├── agent-card.json
 ├── skills/
 │   ├── redis-lock.md
 │   ├── redisson-pattern.md
 │   └── race-condition-test.md
 ├── troubleshooting/
 │   ├── lock-timeout.md
 │   └── duplicate-request.md
 ├── lessons-learned.md
 └── source-agents.json
```

source-agents.json 예시:

```json
{
  "new_agent_id": "aki-redis-concurrency-agent",
  "created_from": [
    {
      "agent_id": "aki-backend-agent",
      "source": "successful Redis lock troubleshooting records",
      "score_at_extraction": 88
    },
    {
      "agent_id": "aki-reviewer-agent",
      "source": "concurrency review checklist",
      "score_at_extraction": 91
    }
  ],
  "created_reason": "Redis 동시성 관련 작업 수요 증가 및 기존 backend-agent의 반복 실패 보완"
}
```

---

## 17. 신규 agent의 초기 상태

새로 생성된 agent는 바로 active로 두지 않는다.

권장 초기 상태:

```text
probation
```

이유:

```text
새 agent는 아직 실제 작업 성과가 없다.
우수 agent의 자료를 기반으로 만들어졌더라도 검증이 필요하다.
처음에는 reviewer-agent 동반으로 쉬운 작업부터 맡긴다.
```

승격 흐름:

```text
probation
→ 쉬운 작업 3회 성공
→ normal 작업 3회 성공
→ review_pass_rate 기준 충족
→ active 전환
```

---

## 18. agent performance 파일 구조

권장 파일 구조:

```text
.agent-room/hr/
 ├── agent-performance.jsonl
 ├── agent-scoreboard.json
 ├── agent-status.json
 ├── agent-suspensions.json
 ├── retraining-requests/
 ├── replacement-recommendations/
 ├── promotion-recommendations.md
 └── seed-packs/
```

각 agent repo에도 성과 관련 파일을 둘 수 있다.

```text
aki-backend-agent-repo/
 ├── profile/
 │   ├── AGENT_RESUME.md
 │   └── agent-card.json
 ├── skills/
 ├── troubleshooting/
 ├── memory/
 │   └── raw/
 ├── pending-updates/
 ├── maintainer-reviews/
 ├── performance/
 │   ├── score-history.jsonl
 │   ├── strengths.md
 │   ├── weaknesses.md
 │   └── retraining-history.md
 └── CHANGELOG.md
```

---

## 19. HR agent의 배정 판단 예시

태스크:

```text
Redis Lock 장애 분석 및 재발 방지 테스트 작성
```

후보:

```text
aki-backend-agent
  score: 82
  Redis 작업 성공 5회
  status: active

aki-infra-agent
  score: 76
  Redis 운영 경험 있음
  status: active

aki-old-backend-agent
  score: 38
  Redis 관련 최근 3회 실패
  status: suspended
```

HR agent 판단:

```text
선정:
- primary: aki-backend-agent
- support: aki-infra-agent
- reviewer: aki-reviewer-agent

제외:
- aki-old-backend-agent는 suspended 상태이므로 자동 배정 제외

추가 판단:
- Redis 동시성 작업 수요가 많아지고 있으므로 aki-redis-concurrency-agent 신규 생성 검토
```

---

## 20. HR agent와 skill-maintainer-agent 연계

성과가 낮을 때 HR agent가 직접 skill을 수정하지 않는다.

대신 요청을 만든다.

```text
HR agent:
  이 agent는 Redis 작업에서 반복 실패한다.
  Redis lock skill 보강이 필요하다.

skill-maintainer-agent:
  해당 agent repo에 Redis troubleshooting/skill 보강 PR을 만든다.

reviewer-agent:
  보강 내용이 기술적으로 맞는지 검토한다.

git-agent:
  PR 생성한다.

human:
  merge 승인한다.
```

즉 HR agent는 평가자이자 인사 담당자이고, skill-maintainer-agent는 교육/지식 관리 담당자다.

---

## 21. 승격과 보상

성과가 좋은 agent는 더 중요한 작업에 배정될 수 있다.

상태 예시:

```text
active
senior
lead
specialist
```

승격 기준 예시:

```text
score >= 85
최근 10개 작업 중 8개 이상 성공
review_pass_rate >= 0.85
test_pass_rate >= 0.85
needs_human_count 낮음
재사용 가능한 skill 후보 3개 이상 생성
```

승격된 agent는 다음 권한을 가질 수 있다.

```text
hard 작업 우선 배정
신규 agent seed source로 사용
다른 agent retraining 자료의 기준으로 사용
reviewer-agent와 함께 mentoring 역할 수행
```

단, 자동 권한 확대는 제한한다.

```text
main merge
운영 배포
secret 수정
외부 시스템 write 작업
```

이런 작업은 계속 human 승인이 필요하다.

---

## 22. agent lifecycle 전체 흐름

```text
new agent created
   ↓
probation
   ↓ 성공 누적
active
   ↓ 우수 성과
senior / specialist
   ↓ 성과 저하
watchlist
   ↓ 개선 없음
probation
   ↓ 반복 실패
suspended
   ↓ 보강 가능
retraining
   ↓ 개선됨
probation → active
   ↓ 개선 안 됨
replacement_requested
   ↓ 장기 미사용
retired
```

---

## 23. 안전 정책

성과 점수가 높아도 다음 권한은 자동 부여하지 않는다.

```text
main 브랜치 merge
운영 배포
민감정보 수정
AWS credential 수정
SSH key 수정
결제/비용 발생 작업
외부 서비스 파괴적 변경
```

성과 점수는 배정 우선순위와 재교육 판단에는 사용하지만, 위험 권한 자동 부여에는 사용하지 않는다.

---

## 24. MVP 구현 계획

### Phase 1: 성과 기록 파일 추가

```text
.agent-room/hr/agent-performance.jsonl
.agent-room/hr/agent-scoreboard.json
.agent-room/hr/agent-status.json
```

### Phase 2: 기본 점수 계산

```text
작업 성공/실패 기록
테스트 통과 여부
리뷰 통과 여부
needs_human 발생 여부
```

### Phase 3: 상태 전이 적용

```text
active
watchlist
probation
suspended
```

### Phase 4: retraining 요청 생성

```text
반복 실패 영역 식별
skill-maintainer-agent에게 보강 요청 문서 생성
```

### Phase 5: replacement recommendation 생성

```text
개선 불가 agent 식별
신규 agent 후보 이름 제안
필요 skills 목록 제안
우수 agent seed source 추천
```

### Phase 6: 신규 agent seed pack 생성

```text
우수 agent의 검증된 troubleshooting/skills/lessons 추출
신규 agent용 AGENT_RESUME.md 초안 생성
agent-card.json 초안 생성
skills 초기 디렉터리 생성
```

---

## 25. 결론

HR agent에 인사고과 기능을 넣는 것은 자연스럽다.

HR agent는 단순히 현재 태스크 담당자를 고르는 역할을 넘어서, agent 조직 전체의 성과와 생애주기를 관리할 수 있다.

최종 구조는 다음과 같다.

```text
HR agent
  담당자 선발
  성과 점수 관리
  watchlist/probation/suspended 관리
  retraining 요청
  replacement 권고
  신규 agent 생성 시 우수 agent 자료 반영 요청

skill-maintainer-agent
  부족 skills 보강
  troubleshooting 정리
  신규 agent seed pack 작성

reviewer-agent
  기술 검토

git-agent
  PR 생성

orchestrator
  실행 관리
```

중요한 원칙은 다음이다.

```text
성과가 낮은 agent는 바로 폐기하지 않는다.
watchlist → probation → suspended → retraining → replacement_requested 단계를 거친다.

성과가 좋은 agent의 경험과 skills는 신규 agent 생성 시 seed 자료로 사용한다.

HR agent는 평가와 배정을 담당하고, 기술 업데이트는 skill-maintainer-agent가 담당한다.
```
