# 프로젝트 워크플로우 가이드 (Project Workflow)

## 1. 아키텍처 개요 (Architecture)

이 워크스페이스는 **멀티 프로젝트(Multi-Project)** 구조를 지원하도록 설계되었습니다.
에이전트는 **글로벌 컨텍스트(Root)**와 **로컬 컨텍스트(Sub-Project)**를 명확히 구분해야 합니다.

### 🏛️ 디렉토리 구조 표준
* 상세 구조는 **[STRUCTURE.md](/management/rules/STRUCTURE.md)**를 참조하십시오.

### 📚 Management 구조
```
management/
├── rules/               # 워크플로우 및 대원칙 (불변)
├── guides/              # 프로젝트 운영 가이드 (Manuals)
├── ai-context/          # 전역 AI 컨텍스트
├── knowledge-index.md   
└── troubleshooting-index.md
```

---

## 2. 작업 프로세스 (Standard Process)

### 1단계: 타겟 설정 및 컨텍스트 로딩
1. `AGENTS.md`와 `management/task.md`를 읽어 작업 대상 프로젝트를 확인합니다.
2. 해당 프로젝트의 `prj-docs/task.md`와 `TODO.md`를 읽어 현재 상태와 우선순위를 파악합니다.

### 2단계: 구현 및 기록
1. **[코딩 표준](/management/rules/CODING_STANDARD.md)**을 엄수하여 기능을 구현합니다.
2. 작업 중 발생하는 중요한 결정 사항은 즉시 메모합니다.

### 3단계: 완료 및 문서 현행화 (Sync & Review) ⭐
모든 구현이 끝난 후, **커밋(Commit) 전**에 반드시 아래 사항을 점검합니다.
1. **문서 동기화**: 구현된 코드가 `README`, `knowledge` 등 기존 문서의 설명과 일치하는가? 일치하지 않는다면 문서를 수정하십시오.
2. **규칙 현행화**: 기존 규칙(`RULES`)이 현재의 최적화된 개발 방식과 충돌한다면, **규칙 문서를 먼저 수정**하여 현실을 반영하십시오. (규칙은 팀과 함께 발전합니다.)
3. **사이드바 갱신**: 새 문서(`.md`)가 생성되었다면 반드시 `sidebar-manifest.md`에 링크를 추가하십시오.

### 4단계: 보고 및 커밋
1. **커밋 메시지**: 반드시 **한글**로 작성하며, 변경 이유와 내역을 명확히 요약합니다.
2. **진행 상황 기록**: 작업 내용을 프로젝트의 `prj-docs/task.md`에 상세히 기록하고 상태를 업데이트합니다.

---

## 3. 새로운 프로젝트 추가 방법
1. `workspace/apps` 하위에 서비스 폴더를 생성합니다.
2. `prj-docs` 폴더를 만들고 필수 문서 3종(`task.md`, `TODO.md`, `ROADMAP.md`)을 생성합니다.
3. `management/task.md` 및 `sidebar-manifest.md`에 새 프로젝트를 등록합니다.
