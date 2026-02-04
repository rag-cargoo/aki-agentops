# 🏗️ 프로젝트 구조 및 표준 (Project Structure & Standards)

> **Core Philosophy**: "사람과 AI가 모두 이해할 수 있는 명확한 계층 구조를 지향한다."
> 이 문서는 전사 관리 영역(Management), 표준 계층(Layers), 그리고 문서화 운영 표준을 정의합니다.

---

## 1. 폴더 구조 원칙 (Directory Structure)

### 0. Management 구조 (Global)
이 폴더는 프로젝트의 **'헌법'**이자 **'AI의 두뇌'**입니다. 새 프로젝트를 시작할 때 **이 폴더만 복사**하면 팀의 규칙이 즉시 이식됩니다.

```
management/
├── rules/               # [불변] 프로젝트 규칙
│   ├── WORKFLOW.md      # 협업 및 커밋 규칙
│   ├── STRUCTURE.md     # (본 문서) 구조 및 문서 표준
│   ├── ARCHITECTURE_RULES.md # 설계 원칙
│   └── CODING_STANDARD.md    # 코드 스타일 표준
├── ai-context/          # [Global] 재사용 가능한 AI 리소스 (Library, Framework)
│   ├── backend/         # 백엔드 (Java, Spring, DB...)
│   ├── frontend/        # 프론트엔드 (React, TS...)
│   ├── infra/           # 인프라 (Docker, AWS...)
│   └── integrations/    # 외부 연동 (Payment, Auth...)
├── knowledge-index.md   # 전체 지식 문서 색인
└── troubleshooting-index.md # 트러블슈팅 사례 색인
```

### 1. 표준 계층 (Standard Layers)
모든 프로젝트는 `workspace/` 하위에서 아래 분류 중 하나에 속해야 합니다.

*   **📱 Apps (`apps/`)**: 최종 사용자용 서비스 및 API 서버 (예: `ticket-core-service`).
*   **🏛️ Infra (`infra/`)**: 클라우드 리소스 및 인프라 프로비저닝 코드 (Terraform, Docker 등).
*   **☸️ Manifests (`manifests/`)**: K8s, Helm 등 배포 설정 파일.

### 2. 프로젝트 내부 표준 구조 (Project Internal)
각 서비스(Apps) 폴더 내부는 반드시 다음 구조를 따릅니다.

```
{service-name}/
├── src/                  # 실제 소스 코드
├── prj-docs/             # [필수] 프로젝트 전용 관리 문서
│   ├── task.md           # 현재 작업 현황판
│   ├── TODO.md           # 단기 할 일 목록
│   ├── ROADMAP.md        # 장기 발전 계획
│   ├── knowledge/        # [선택] 기술 지식 기록 (사용자 요청 시)
│   ├── troubleshooting/  # [선택] 트러블슈팅 사례 (사용자 요청 시)
│   └── ai-context/       # [선택] 서비스 전용 AI 컨텍스트
└── build.gradle          # 빌드 설정
```

---

## 2. 문서 분류 및 사이드바 운영 표준 (Sidebar Policy)

Docsify 사이드바(`sidebar-manifest.md`)는 정보의 위계(Hierarchy)를 명확히 표현해야 합니다.

### 📐 3단 계층 구조 (The 3-Tier Hierarchy)
1.  **PROJECT GOVERNANCE**: 전사 공통 규칙 (`management/rules/*`).
2.  **WORKSPACE**: 각 서비스별 현황 및 기술 지식 (`workspace/.../prj-docs/*`).
3.  **OPERATIONS & MANUALS**: 시스템 운영 및 도구 사용법.

### 🎨 스타일 가이드 (Visual Style)
*   **Clean Style**: 사이드바 메뉴에는 **이모지를 사용하지 않습니다.**
*   **Separator**: 대분류 사이에는 구분선(`---`)을 넣어 시각적으로 분리합니다.
*   **Header**: 대분류 제목은 **대문자(UPPERCASE)**로 표기합니다.

---

## 3. AI 협업 및 복제 가이드 (AI Context Porting)

### 🚀 새 프로젝트 부트스트랩 (Bootstrap)
새로운 레포지토리에 아래 항목을 복사하면 별도의 프롬프트 없이도 일관된 개발 문화가 이식됩니다.
1.  **`management/` 폴더 전체**: AI가 규칙과 지식을 로드함.
2.  **`index.html`, `.nojekyll`, `sidebar-manifest.md`**: 문서화 시스템.

---

## 4. [부록] 기술 가이드 (Docsify Spec)
*   **사이드바 로딩**: `loadSidebar: true` (파일명 `sidebar-manifest.md` 추천).
*   **경로 규칙**: 404 방지를 위해 반드시 **상대 경로**를 사용하십시오.