#  운영 및 자동화 표준 (Operations & Automation Standards)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-08 23:11:27`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 1. Makefile 운영 원칙 (Makefile Standards)
> - 2. 스크립트 관리 표준 (Scripting Standards)
> - 3. 권한 및 실행 표준 (Execution)
> - 4. 스킬 관리 및 동기화 표준 (Skill Management & Sync)
> - 7.  파일 무결성 보호 프로토콜 (File Integrity Protection)
> - 5. 문서 사이트 (GitHub Pages) 관리 표준
<!-- DOC_TOC_END -->

> **Core Philosophy**: "복잡한 수동 명령어를 지양하고, 모든 운영 작업은 명문화된 스크립트와 Makefile을 통해 수행한다."

---

## 1. Makefile 운영 원칙 (Makefile Standards)

명령어 추상화와 자동화를 위해 각 서비스의 루트 디렉토리에 `Makefile`을 배치한다.

*   **배치 위치**: 전사 공통 작업은 프로젝트 루트에, **개별 서비스 전용 작업은 각 서비스 루트**(`workspace/apps/{service}/`)에 Makefile을 둔다.
*   **진입점 일원화**: 빌드, 테스트, 배포, 권한 설정 등은 개별 명령어를 외울 필요 없이 `make [명령어]` 체계로 관리한다.
*   **Help 제공**: `make help` (또는 기본 `make`) 실행 시 가용한 모든 명령어 리스트와 설명을 출력해야 한다.
*   **추상화**: 복잡한 `docker-compose` 명령어 나 `curl` 명령 등은 사용자가 알 필요 없게 Makefile 뒤로 숨긴다.

---

## 2. 스크립트 관리 표준 (Scripting Standards)

모든 스크립트는 `scripts/` 폴더 하위의 용도별 디렉토리에 관리한다.

### 폴더 분류 체계
*   **`api/`**: 쉘 스크립트(.sh) 기반의 자동화 테스트.
*   **`http/`**: IDE용 HTTP Client(.http) 기반의 개발자 실시간 테스트.
*   **`bench/`**: 성능 및 부하 테스트.
*   **`common/`**: 공통 환경 변수(`env.sh`).

### 스크립트 작성 필수 요건
1.  **가이드 주석 필수**: [목적, 설정 안내, 필수 환경] 명시.
2.  **안전 장치 (Safety First)**: 모든 `.sh` 스크립트 상단에 `set -e`(오류 발생 시 즉시 종료) 및 `set -u`(미정의 변수 사용 시 종료)를 포함한다.
3.  **테스트 격리 및 자가 완결성 (Self-Contained)**: 
    *   테스트 실행 전 **필요한 데이터(유저 등)를 API로 직접 생성**한다.
    *   테스트 종료 후 **생성된 데이터를 삭제(Cleanup)**하여 DB 정합성을 유지한다.
3.  **설정의 중앙화**: `scripts/common/env.sh` 사용.
4.  **가시성 확보**: 실행 직후 현재 환경 변수값 출력.


---

## 3. 권한 및 실행 표준 (Execution)

*   **자동 권한 부여**: 신규 스크립트 추가 시 `make setup` 명령어에 `chmod +x` 로직을 추가하여 팀원이 즉시 사용할 수 있게 한다.
*   **경로 독립성**: `$(dirname "$0")` 등을 사용하여 스크립트가 어디서 호출되든 파일 시스템 경로 문제가 발생하지 않도록 한다.

---

## 4. 스킬 관리 및 동기화 표준 (Skill Management & Sync)

에이전트 지능을 확장하는 스킬(Skill)은 개발 소스와 런타임 연결을 분리하여 관리한다.

### 스크립트 배치 원칙 (중요)

*   **공용 운영 스크립트**: `skills/bin/`에만 둔다. (예: `session_start.sh`, `set_active_project.sh`)
*   **리로드 런타임 구현**: `skills/bin/codex_skills_reload/`에 집중 배치한다.
*   **스킬 내부 전용 스크립트**: 각 스킬의 `skills/<skill-name>/scripts/`에 둔다.
*   **삭제/수정 안전성**: 세션 시작 시 `./skills/bin/codex_skills_reload/session_start.sh`가 `skills/bin` 무결성을 자동 점검한다.

### 런타임 분리의 이유

*   **시스템 인식**: 런타임은 일반적으로 프로젝트 로컬의 `.gemini/skills/` 경로를 참조한다.
*   **실시간 동기화 (Symbolic Link)**: 개발 소스(`skills/`)와 런타임 경로를 심볼릭 링크로 연결하면 수정사항 반영이 빠르다.
*   **지식 갱신 제어**: 링크와 별개로, 실제 세션에서 어떤 스킬을 읽을지는 리로드 문서(`.codex/runtime/codex_skills_reload.md`) 기준으로 제어한다.



### 동기화 워크플로우 (Link & Reload Workflow)



1.  **연결 (Link)**: `./skills/bin/sync-skill.sh`를 실행한다. (최초 1회 또는 신규 스킬 추가 시)



2.  **기록 (Log)**: 스킬 내용 수정 시, `SKILL.md` 상단의 `description` 필드에 **상세 타임스탬프(YYYY-MM-DD HH:mm:ss)**와 변경 요약을 반드시 기록한다. 이는 `/skills list`를 통한 버전 검증의 기준이 된다.



3. **수정 (Edit)**: `skills/` 하위의 문서를 자유롭게 수정한다.



4. **반영 (Reload)**: `./skills/bin/codex_skills_reload/session_start.sh`를 실행한다. (권장 단일 진입점)
5. **확인 (Report)**: `.codex/runtime/codex_session_start.md`에서 Skills/Project 상태와 안내문을 확인한다.

### pre-commit 모드 운영 (Quick / Strict)

*   **기본값**: `quick`
    *   routine 커밋에서 문법/경량 검증 중심으로 진행한다.
*   **강화 모드**: `strict`
    *   마일스톤 완료, 릴리즈 직전, API 체인 변경 종료 시 사용한다.
    *   문서/HTTP/API 스크립트/실행 리포트까지 강제 검증한다.
*   **운영 규칙**:
    1. 중요 커밋 전에는 사용자에게 `strict` 전환 여부를 확인한다.
    2. 사용자 승인 후에만 `strict`를 적용한다.
    3. 완료 후 기본값을 `quick`으로 복귀한다.
    4. `strict`는 정책 파일(`skills/precommit/policies/*.sh`, `<project-root>/prj-docs/precommit-policy.sh`)에 없는 staged 경로를 실패 처리한다.
    5. `strict`는 문서 품질 규칙(지식 문서 Failure-First/Before&After/Execution Log, API 명세 6-Step)을 함께 검증한다.
*   **명령어**:
    *   상태 확인: `./skills/bin/precommit_mode.sh status`
    *   기본 모드 설정: `./skills/bin/precommit_mode.sh quick|strict`
    *   1회성 강제 실행: `CHAIN_VALIDATION_MODE=strict git commit -m "..."`
*   **정책 엔진/레지스트리**:
    *   엔진: `skills/bin/validate-precommit-chain.sh`
    *   전역 레지스트리: `skills/precommit/policies/*.sh`
    *   프로젝트 레지스트리: `<project-root>/prj-docs/precommit-policy.sh`







---







## 7.  파일 무결성 보호 프로토콜 (File Integrity Protection)















**이 규칙은 다른 모든 규칙보다 우선한다. 에이전트는 기존 파일을 수정할 때 데이터 손실을 막기 위해 아래 수칙을 생명처럼 지켜야 한다.**















### 7.1. `write_file` 금지 원칙 (Ban Overwrite)







*   **대상**: 이미 존재하는 모든 기술 문서(`.md`) 및 핵심 소스 코드.







*   **규칙**: **기존 파일을 수정할 때 절대 `write_file`을 사용하지 않는다.** `write_file`은 파일 전체를 덮어쓰므로, 에이전트가 기억하지 못하는 부분을 삭제할 위험이 있다.







*   **행동 강령**: 수정이 필요하면 반드시 **`replace` 도구**를 사용하여 해당 부분만 국소적으로 변경한다.















### 7.2. 대규모 수정 시 안전 절차 (Safety Procedure)







불가피하게 파일 전체 구조를 바꿔야 해서 `write_file`을 써야 한다면, 다음 3단계를 따른다.







1.  **백업**: `cp target.md target.md.bak` 명령어로 백업본 생성.







2.  **검증**: 수정 후 `wc -l`로 라인 수를 비교하거나 `git diff`로 삭제된 내용이 없는지 확인.







3.  **복구**: 실수로 내용이 삭제되었다면 즉시 `mv target.md.bak target.md`로 원복.















### 7.3. 내용 보존의 원칙







*   문서를 통합하거나 리팩토링할 때, **기존의 상세 내용(코드, 실험 결과, 트러블슈팅 로그 등)**은 단 한 줄도 삭제하지 않는다.







*   "요약"은 금지되며, "구조화(Structuring)"만 허용된다.



















---

## 5. 문서 사이트 (GitHub Pages) 관리 표준

문서는 "작성하는 것"보다 "쉽게 찾아볼 수 있게 관리하는 것"이 더 중요하다. 모든 문서는 Docsify 기반의 GitHub Pages를 통해 실시간으로 공유된다.

### 운영 원칙
1.  **가시성 보장 (Visibility)**: 새로 생성된 모든 기술 문서(`.md`)는 반드시 `sidebar-manifest.md`에 등록되어야 한다. 등록되지 않은 문서는 "존재하지 않는 문서"로 간주한다.
2.  **즉시 반영 (Immediate Deployment)**: 문서화가 완료되면(설계서, 지식문서 등), 코드 구현 전이라도 즉시 커밋 및 푸시하여 GitHub Pages 사이트에서 팀원들이 즉시 열람할 수 있도록 한다.
3.  **경로 무결성 (Path Integrity)**: 사이드바 링크는 반드시 **루트 기준 절대 경로(`/` 시작)**를 사용한다. (예: `[제목](/workspace/...)`)
3.  **정적 자원 보호**: `index.html`과 `.nojekyll` 파일은 사이트 구동의 핵심이므로 임의로 수정하거나 삭제하지 않는다.
4.  **현행화 동기화**: `task.md`의 상태가 변경되거나 새로운 `knowledge`가 추가될 때, 사이드바의 구조가 논리적으로 타당한지 검토하고 필요시 재배치한다.

### 사이드바(sidebar-manifest.md) 작성 규격
*   **프로젝트 단위 그룹화**: 각 마이크로서비스나 독립 모듈별로 섹션을 분리한다.
*   **중요도 순 배치**: Roadmap, Task 등 현재 진행 상황을 알 수 있는 문서를 상단에 배치한다.
*   **계층 구조**: 들여쓰기(2 spaces)를 사용하여 논리적 깊이를 표현한다.
