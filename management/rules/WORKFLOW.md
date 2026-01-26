# 프로젝트 워크플로우 가이드 (Project Workflow)

## 1. 아키텍처 개요 (Architecture)
이 워크스페이스는 **멀티 프로젝트(Multi-Project)** 구조를 지원하도록 설계되었습니다.
에이전트는 **글로벌 컨텍스트(Root)**와 **로컬 컨텍스트(Sub-Project)**를 명확히 구분해야 합니다.

### 🏛️ 디렉토리 구조 표준
*   상세 구조는 **[STRUCTURE.md](management/rules/STRUCTURE.md)**를 참조하십시오.
*   `Workspace Root` 경로 설정은 `AGENTS.md`를 따릅니다.

### 📚 Management 구조
```
management/
├── rules/               # 워크플로우 및 규칙
├── ai-context/          # [Global] 전역 AI 컨텍스트 (라이브러리, API 등)
├── knowledge-index.md   # 지식 문서 인덱스
└── troubleshooting-...  # 트러블슈팅 인덱스
```

## 2. 작업 프로세스 (Process)

### 1단계: 타겟 설정 (Routing)
1.  세션이 시작되면 **루트의 `AGENTS.md`**를 통해 구조를 파악합니다.
2.  `management/task.md`를 읽어 **Active Target(작업 중인 프로젝트)**을 확인합니다.
3.  지정된 서브 프로젝트(`workspace/...`)로 이동합니다.

### 2단계: 로컬 컨텍스트 로드 (Context Loading)
1.  서브 프로젝트의 `prj-docs/task.md`를 읽어 현재 상태를 파악합니다.
2.  `prj-docs/TODO.md`를 읽어 **당장 처리해야 할 이슈/버그**를 확인합니다.
3.  구현 시 **[코딩 표준(CODING_STANDARD.md)](management/rules/CODING_STANDARD.md)**을 엄수합니다.
    - 특히 **하드코딩 금지** 원칙을 위반하지 않도록 주의하십시오.

### 3단계: 실행 및 기록 (Execution & Reporting)
1.  기능 구현이 완료되면, **`prj-docs/task.md`의 상태를 반드시 업데이트**합니다.
2.  **`management/task.md`는 건드리지 않습니다.** (프로젝트 전환 시에만 수정)
3.  **지식/트러블슈팅 문서**는 **사용자가 명시적으로 요청할 때만** 작성합니다.
    - 예: "이것을 지식 문서로 작성해줘" / "이것을 트러블슈팅 문서로 작성해줘"
    - 작성 위치: `prj-docs/knowledge/` 또는 `prj-docs/troubleshooting/`
    - 작성 후: 해당 인덱스 파일(`management/knowledge-index.md` 또는 `troubleshooting-index.md`)에 링크 추가

4.  **AI 컨텍스트 문서 (AI Context)** 규칙
    - **Global Context (`management/ai-context/`)**:
        - 라이브러리 공식 문서, API 스펙, 프레임워크 가이드 등
        - **모든 프로젝트에서 재사용** 가능한 정보
    - **Local Context (`prj-docs/ai-context/`)**:
        - 해당 프로젝트 고유의 설계, 레거시 설명 등
        - **재사용 불가능**한 정보
    - **통통 작성 규칙**:
        - 원본이 외국어인 경우: `파일명-original.md` (원본) + `파일명-ko.md` (한글 번역/요약)
        - 원본이 한글인 경우: `파일명.md`
    - **메타데이터 필수 (한글 문서 상단)**:
        ```markdown
        > **Source**: [URL 또는 출처]
        > **Purpose**: [이 문서가 필요한 이유]
        > **Date**: [작성일]
        ```

## 3. 새로운 프로젝트 추가 방법
1.  성격에 따라 `workspace/apps`, `workspace/infra` 중 알맞은 곳에 폴더를 만듭니다.
2.  내부에 `prj-docs` 폴더를 만들고 필수 문서 3종(`task.md`, `TODO.md`, `ROADMAP.md`)을 생성합니다.
3.  `management/task.md`의 `Project Index`에 새 프로젝트를 등록합니다.
