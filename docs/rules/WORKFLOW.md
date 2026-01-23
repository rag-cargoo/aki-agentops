# 프로젝트 워크플로우 가이드 (Project Workflow)

## 1. 아키텍처 개요 (Architecture)
이 워크스페이스는 **멀티 프로젝트(Multi-Project)** 구조를 지원하도록 설계되었습니다.
에이전트는 **글로벌 컨텍스트(Root)**와 **로컬 컨텍스트(Sub-Project)**를 명확히 구분해야 합니다.

### 🏛️ 디렉토리 구조 표준
```
/
├── task.md                 # [Global Anchor] 어떤 프로젝트를 작업할지 결정하는 관제탑
├── docs/
│   └── rules/              # [Global Rules] 모든 프로젝트에 적용되는 불변의 법칙
│       └── WORKFLOW.md
└── projects/               # [Project Modules] 실제 프로젝트들이 위치하는 곳
    ├── default/            # [Sub-Project 1]
    │   ├── prj-docs/       # ★ 각 프로젝트는 독자적인 문서 세트를 가짐
    │   │   ├── task.md     # [Local Anchor] 이 프로젝트의 작업 현황
    │   │   ├── TODO.md     # [Live Tasks] 버그, 핫픽스, 단기 작업 목록
    │   │   ├── ROADMAP.md  # 이 프로젝트의 장기 목표
    │   │   └── ...
    │   └── src/            # 이 프로젝트의 소스 코드
    └── backend-api/        # [Sub-Project 2]
        └── ...
```

## 2. 작업 프로세스 (Process)

### 1단계: 타겟 설정 (Routing)
1.  세션이 시작되면 **루트의 `task.md`**를 최우선으로 확인합니다.
2.  `Active Target`에 지정된 **서브 프로젝트의 `task.md`**로 이동합니다.

### 2단계: 로컬 컨텍스트 로드 (Context Loading)
1.  서브 프로젝트의 `prj-docs/task.md`를 읽어 현재 상태를 파악합니다.
2.  `prj-docs/TODO.md`를 읽어 **당장 처리해야 할 이슈/버그**를 확인합니다.
3.  `prj-docs/ROADMAP.md` 등을 참조하여 장기 계획을 확인합니다.
3.  **주의**: 다른 프로젝트의 문서는 절대로 혼동하여 참조하지 않습니다.

### 3단계: 실행 및 기록 (Execution)
1.  기능 구현 후, **해당 서브 프로젝트의 `prj-docs/` 내 문서**만 업데이트합니다.
2.  루트의 `task.md`는 프로젝트를 전환할 때만 수정합니다.

## 3. 새로운 프로젝트 추가 방법
1.  `projects/` 하위에 새 폴더를 만듭니다. (예: `projects/mobile-app`)
2.  내부에 `prj-docs` 폴더를 만들고 필수 문서 5종(`task.md`, `TODO.md`, `ROADMAP.md` 등)을 생성합니다.
3.  루트 `task.md`의 `Project Index`에 새 프로젝트를 등록합니다.
