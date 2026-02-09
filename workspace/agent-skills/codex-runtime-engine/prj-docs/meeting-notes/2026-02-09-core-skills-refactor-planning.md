# Meeting Notes: Core Skills Refactor Planning

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 07:52:02`
> - **Updated At**: `2026-02-09 17:26:35`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 코어 스킬 구조 재정의
> - 안건 2: 스킬 네이밍 정책 정렬
> - 안건 3: Active Project 운영 원칙 확정
> - 안건 4: 실행 계획 및 안전장치
> - 안건 5: precommit 정책 경로 이관
> - 안건 6: [AGENT-PROPOSAL] Runtime Orchestrator 도입
> - 안건 7: scripts 소유권 이관 + 호환 래퍼 정책
> - 안건 8: skills/bin 호환 래퍼 단계적 폐기 기준
<!-- DOC_TOC_END -->

## 안건 1: 코어 스킬 구조 재정의
- Created At: 2026-02-09 07:52:02
- Updated At: 2026-02-09 09:45:38
- Status: DONE
- 결정사항:
  - 코어를 단일 비대 스킬로 두지 않고 기능별 모듈로 분리한다.
  - 목표 구조는 허브 1개 + 실행 모듈 2개로 정렬한다.
  - 후보 구조:
    - `aki-codex-core` (원칙/허브)
    - `aki-codex-session-reload` (세션 리로드 체인)
    - `aki-codex-precommit` (품질 게이트)
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/1
  - 진행기록: 스캐폴딩 + 책임 매트릭스 공존/이관 계획 + 사이드바 코어 참조 링크 동기화 완료

## 안건 2: 스킬 네이밍 정책 정렬
- Created At: 2026-02-09 07:52:02
- Updated At: 2026-02-09 09:45:38
- Status: DONE
- 결정사항:
  - 사용자 제작 스킬은 `aki-` prefix를 적용해 외부/시스템 스킬과 명확히 구분한다.
  - 외부/시스템 스킬(`find-skills`, `skill-creator`, `skill-installer`)은 기존 이름을 유지한다.
  - 네이밍은 "역할이 한눈에 보이는 명사형"을 우선한다.
- 후속작업:
  - 담당: Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/2
  - 진행기록: `skill-naming-policy.md` 작성 + `check-skill-naming.sh` 자동 점검 스크립트/가이드 연결 완료

## 안건 3: Active Project 운영 원칙 확정
- Created At: 2026-02-09 07:52:02
- Updated At: 2026-02-09 07:52:02
- Status: DONE
- 결정사항:
  - 전역 범위 작업을 하더라도 Active Project는 비우지 않고 유지한다.
  - 기준점은 `workspace/agent-skills/codex-runtime-engine`로 고정한다.
  - 이유: 세션 리로드 스냅샷 경고 방지, 규칙 적용 기준 유지, 문서/회의록 경로 일관성 확보.
- 후속작업:
  - 담당: Agent
  - 기한: 2026-02-09
  - 상태: DONE

## 안건 4: 실행 계획 및 안전장치
- Created At: 2026-02-09 07:52:02
- Updated At: 2026-02-09 09:49:46
- Status: DONE
- 결정사항:
  - 리스크 관리를 위해 `feature/core-skills-refactor` 브랜치에서 분해 작업을 진행한다.
  - 중첩 스킬 디렉토리(`skills/<hub>/skills/<module>`)는 로더 제한으로 채택하지 않는다.
  - 스킬 생성은 `skill-creator`를 사용하고, `scripts/references/assets`는 필요 범위만 채택한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/3
  - 진행기록: 브랜치 체크포인트 문서 + 중첩 구조 미채택 원칙 + skill-creator 생성 규칙 + 회의록/task 역기록 반영 완료

## 안건 5: precommit 정책 경로 이관
- Created At: 2026-02-09 09:33:25
- Updated At: 2026-02-09 09:40:01
- Status: DONE
- 결정사항:
  - `aki-codex-precommit` 스킬 승격 이후 남아 있는 레거시 정책 경로를 정리한다.
  - 정책 파일/검증 스크립트/운영 문서의 경로 표기를 `skills/aki-codex-precommit/policies/*.sh`로 일치시킨다.
  - 정책 검증 로직은 바꾸지 않고 경로 이관과 동작 보존에 집중한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-10
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/4
  - 진행기록: 정책 파일 이관 + `validate-precommit-chain.sh` 경로 갱신 + quick/strict 동작 검증 완료

## 안건 6: [AGENT-PROPOSAL] Runtime Orchestrator 도입
- Created At: 2026-02-09 10:00:31
- Updated At: 2026-02-09 15:56:00
- Status: DONE
- 제안 출처: Agent
> [!IMPORTANT]
> 에이전트 제안 안건: 세션 운영 체크를 선언형으로 표준화하기 위한 자동화 제안.
- 결정사항:
  - `engine.yaml`로 세션/검증 훅 실행 순서를 선언형으로 관리하는 방안을 검토한다.
  - `run-skill-hooks.sh`와 `.codex/runtime` JSON 리포트 포맷을 함께 정의해 실행 결과를 일관되게 남긴다.
  - 기존 `session_start.sh`/pre-commit 체인을 대체하지 않고 점진 도입한다.
  - GitHub Pages 운영은 임시로 `develop` 브랜치 소스로 검증하고, `develop -> main` 최종 병합 직전에 소스를 `main`으로 복귀한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-11
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/5
  - 진행기록: `engine.yaml` + `run-skill-hooks.sh` + JSON 리포트 샘플/README + `aki-codex-session-reload` 공존 원칙 문서화 + 실행 검증 완료

## 안건 7: scripts 소유권 이관 + 호환 래퍼 정책
- Created At: 2026-02-09 16:08:15
- Updated At: 2026-02-09 16:45:56
- Status: DONE
- 결정사항:
  - `skills/bin`은 공용 엔트리포인트 중심으로 축소하고, 스킬 전용 로직은 각 스킬의 `scripts/`로 이관한다.
  - 기존 호출 경로 호환을 위해 `skills/bin`에 얇은 위임 래퍼를 남긴다.
  - 점진 이관 원칙으로 문서/체크 체인/운영 가이드를 단계 동기화한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-11
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/8
  - 진행기록: 소스 스크립트(`aki-codex-core`, `aki-codex-precommit`, `aki-codex-session-reload`) 이관 + `skills/bin` 래퍼 전환 + `runtime_orchestrator` 호환 링크 + 소유권 매핑 문서(`bin-script-ownership-map.md`) + 실행/문서 검증 완료
  - 추가완료: 잔여 `skills/bin` 스크립트(`codex_skills_reload/`, `create-backup-point.sh`, `sync-skill.sh`, `run-project-api-script-tests.sh`)도 각 소유 스킬 `scripts/`로 이관하고 `bin`은 래퍼/링크로 정리 완료

## 안건 8: skills/bin 호환 래퍼 단계적 폐기 기준
- Created At: 2026-02-09 16:33:27
- Updated At: 2026-02-09 17:50:00
- Status: DONE
- 결정사항:
  - 호출 지점(문서, hooks, CI, 운영 명령)을 source 경로로 전환 완료.
  - `skills/bin` 래퍼/링크를 저장소에서 제거한다.
  - 실행 로직의 단일 소스는 각 스킬의 `skills/<aki-skill>/scripts/` 경로만 사용한다.
- 후속작업:
  - 담당: Aki + Agent
  - 기한: 2026-02-12
  - 상태: DONE
  - 이슈: https://github.com/rag-cargoo/2602/issues/10
  - 진행기록: `bin-wrapper-deprecation-inventory.md` + `bin-wrapper-deprecation-checklist.md` 작성, 내부 실행 경로(`.githooks`, `.github/workflows`, precommit strict policy) 전환 완료, `skills/bin` 실제 제거 완료
