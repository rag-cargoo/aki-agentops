# 프로젝트 워크플로우 가이드 (Project Workflow)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-09 09:49:46`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 1. 아키텍처 개요 (Architecture)
> - 2. 작업 프로세스 (Standard Process)
> - 3. 새로운 프로젝트 추가 방법
<!-- DOC_TOC_END -->

## 1. 아키텍처 개요 (Architecture)

이 워크스페이스는 **멀티 프로젝트(Multi-Project)** 구조를 지원하도록 설계되었습니다.
에이전트는 **글로벌 컨텍스트(Root)**와 **로컬 컨텍스트(Sub-Project)**를 명확히 구분해야 합니다.

###  디렉토리 구조 표준
* 상세 구조는 **[STRUCTURE.md](/skills/aki-codex-core/references/STRUCTURE.md)**를 참조하십시오.

###  Governance 구조
```
skills/
├── aki-codex-core/            # 코어 원칙/책임 경계
├── aki-codex-session-reload/  # 세션 시작/리로드 운영
├── aki-codex-precommit/       # pre-commit 체인/정책
└── aki-github-pages-expert/   # 문서 렌더링/무손실 점검
```

---

## 2. 작업 프로세스 (Standard Process)

### 1단계: 타겟 설정 및 컨텍스트 로딩
1. `AGENTS.md`를 읽고 `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`를 실행해 Skills/Project 상태를 동기화합니다.
2. `.codex/runtime/codex_session_start.md`와 `.codex/runtime/codex_project_reload.md`의 Active Project를 기준으로 `README.md`, `prj-docs/PROJECT_AGENT.md`, `prj-docs/task.md`를 읽어 현재 상태와 우선순위를 파악합니다.
3. 코어 스킬 분해 작업이면 `references/checkpoints/CORE_SKILLS_REFACTOR_BRANCH_CHECKPOINT.md`를 먼저 확인합니다.

### 2단계: 구현 및 기록
1. **[코딩 표준](/skills/aki-codex-core/references/CODING_STANDARD.md)**을 엄수하여 기능을 구현합니다.
2. 작업 중 발생하는 중요한 결정 사항은 즉시 메모합니다.

### 3단계: 실행 및 기록 (Execution & Reporting)

####  에이전트 안전 수칙 (Safety Protocol) - 기본 원칙
1. **파괴적 변경 전 검사 (Check Before Overwrite)**:
    *   기존 파일을 `write_file`로 덮어쓰기 전에, 반드시 `read_file`로 **전체 내용을 먼저 읽어야 합니다.**
    *   기존 내용 중 보존해야 할 핵심 정보(규칙, 다이어그램, 히스토리 등)가 누락되지 않도록 주의하십시오.
    *   **삭제**는 사용자의 명시적 동의가 있거나, 내용이 다른 곳으로 완벽히 이동되었음이 확인된 경우에만 수행합니다.
2. **변경 내역 보고**:
    *   주요 문서나 설정을 변경할 때는 "무엇을 삭제하고 무엇을 남겼는지" 사용자에게 명확히 보고해야 합니다.

#### 완료 및 문서 현행화 (Sync & Review) 
모든 구현이 끝난 후, **커밋(Commit) 전**에 반드시 아래 사항을 점검합니다.
1. **문서 동기화**: 구현된 코드가 `README`, `knowledge` 등 기존 문서의 설명과 일치하는가?
2. **규칙 현행화**: 기존 규칙(`RULES`)이 현실과 맞지 않다면, **규칙 문서를 먼저 수정**하십시오.
3. **사이드바 갱신**: 새 문서(`.md`)가 생성되었다면 반드시 `sidebar-manifest.md`에 링크를 추가하십시오.
4. **스킬 네이밍 점검**: 스킬 추가/리네임이 있으면 `./skills/aki-codex-core/scripts/check-skill-naming.sh`를 실행하십시오.

### 4단계: 문서화 표준 (Documentation Policy)

####  일반 지식 문서
*   작성 위치: `prj-docs/knowledge/` 또는 `prj-docs/troubleshooting/`
*   트리거: 사용자가 요청하거나 중요한 기술적 의사결정을 기록할 때.

####  AI 컨텍스트 문서 (AI Context Rules)
*   **Global Context (`skills/aki-codex-core/references/`)**:
    *   라이브러리/워크플로우/표준 등 **재사용 가능한 정보**.
*   **Local Context (`prj-docs/ai-context/`)**:
    *   해당 프로젝트 고유의 설계, 레거시 설명 등 **재사용 불가능한 정보**.
*   **작성 규칙**:
    *   원본이 외국어인 경우: `파일명-original.md` + `파일명-ko.md` (요약)
    *   메타데이터 필수 (한글 문서 상단):
        ```markdown
        > **Source**: [URL/출처]
        > **Purpose**: [이 문서가 필요한 이유]
        > **Date**: [작성일]
        ```

### 5단계: 보고 및 커밋
1. **커밋 메시지**: 반드시 **한글**로 작성하며, 변경 이유와 내역을 명확히 요약합니다.
2. **진행 상황 기록**: 작업 내용을 프로젝트의 `prj-docs/task.md`에 상세히 기록하고 상태를 업데이트합니다.

---

## 3. 새로운 프로젝트 추가 방법
1. `workspace/<category>` 하위에 프로젝트 폴더를 생성합니다.
2. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/init_project_docs.sh <project-root>`를 실행해 기준선 문서(`README.md`, `PROJECT_AGENT.md`, `task.md`, `meeting-notes/README.md`)와 `prj-docs` 골격을 자동 생성합니다.
3. `./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh <project-root>` 및 `sidebar-manifest.md` 등록으로 활성 타겟과 문서 링크를 동기화합니다.
