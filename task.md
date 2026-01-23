# 🌐 글로벌 엔트리 포인트 (Global Entry Point)

## 🚨 [CRITICAL INSTRUCTION] 🚨
**모든 에이전트는 작업 시작 전 반드시 아래 규칙을 숙지하십시오.**
1. **규칙 우선**: [워크플로우 가이드(WORKFLOW.md)](docs/rules/WORKFLOW.md)에 정의된 프로세스를 위반하지 마십시오.
2. **격리 엄수**: 하위 프로젝트의 `prj-docs/` 외에는 작업 내용을 기록하지 마십시오.
3. **상태 확인**: 작업 전 해당 프로젝트의 `TODO.md`와 `task.md`를 반드시 먼저 읽으십시오.

---

이 파일은 **전체 워크스페이스의 관제탑**입니다. 에이전트는 여기서 **어떤 프로젝트**를 작업해야 할지 확인하고 해당 프로젝트의 컨텍스트로 이동해야 합니다.

## 1. 📜 공통 작업 규칙 (The Law)
모든 프로젝트는 반드시 아래 규칙을 따릅니다.
*   **[워크플로우 가이드](docs/rules/WORKFLOW.md)**: 멀티 프로젝트 구조 및 작업 방식 정의

## 2. 🎯 현재 활성 프로젝트 (Active Target)
**현재 선택된 프로젝트가 없습니다.**
*   작업을 시작하려면 `Project Index`에서 프로젝트를 선택하거나, 새로운 프로젝트를 생성하십시오.

---
### 🗂️ 프로젝트 목록 (Project Index)
*   *(등록된 프로젝트 없음)*
*   *예시: [Backend API](projects/backend/prj-docs/task.md)*

**[새 프로젝트 시작하기]**
1. `projects/` 폴더 아래에 새 프로젝트 폴더 생성
2. `prj-docs/` 폴더 생성 및 문서 템플릿(`task.md`, `ROADMAP.md` 등) 작성
3. 이 파일의 Project Index에 링크 추가
