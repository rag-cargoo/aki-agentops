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

### 2. 문서 분류 및 사이드바 운영 표준 (Sidebar Policy)

Docsify 사이드바(`sidebar-manifest.md`)는 프로젝트의 **실제 물리적 폴더 구조(Physical Tree)를 1:1로 완벽하게 투영**해야 한다.

*   **물리적 동기화**: 사이드바의 대분류와 소분류는 실제 루트 디렉토리의 `skills/`, `workspace/apps/` 등의 계층 구조와 일치해야 한다.
*   **경로 투명성**: 사용자가 사이드바만 보고도 "이 문서는 실제 어디에 위치한 파일이다"라고 직관적으로 알 수 있어야 한다.
*   **명칭 일관성**: 폴더 명칭과 사이드바 메뉴 명칭을 최대한 통일한다. (예: `skills/` 폴더 -> `SKILLS` 메뉴)

---

## 3. API 명세 표준 규격 (API Documentation Standard)

## 3. AI 협업 및 복제 가이드 (AI Context Porting)

### 🚀 새 프로젝트 부트스트랩 (Bootstrap)
새로운 레포지토리에 아래 항목을 복사하면 별도의 프롬프트 없이도 일관된 개발 문화가 이식됩니다.
1.  **`management/` 폴더 전체**: AI가 규칙과 지식을 로드함.
2.  **`index.html`, `.nojekyll`, `sidebar-manifest.md`**: 문서화 시스템.

---

## 5. 지식 문서 관리 표준 (Engineering Knowledge Standard)

단순한 기술 나열을 지양하고, 의사결정의 근거와 엔지니어링 철학이 담긴 고품질 문서를 지향한다.

*   **실패 사례 분석 필수 (Failure-First)**: 성공한 결과뿐만 아니라, 시행착오 과정과 실패의 원인(Antipattern)을 상세히 기록하여 기술적 함정을 명시한다.
*   **Before & After 코드 대조**: '나쁜 예시(Bad Practice)'와 '모범 사례(Best Practice)'를 코드로 직접 대조하여 기술적 우위를 증명한다.
*   **엔지니어링 철학(The Why) 기술**: 하드코딩 배제, 자율적 시스템 설계 등 기술 선택 뒤에 숨겨진 설계 의도와 철학을 반드시 포함한다.
- **생략 없는 코드 박제**: 문서 내 예시 코드는 생략(`...`) 없이 100% 동작하는 형태를 유지하여 즉시 참조 가능하게 한다.
- **서사적 연결**: 현재 기술의 한계를 짚고, 왜 다음 기술(예: 락 → 대기열)로 나아가야 하는지에 대한 논리적 서사를 남긴다.
- **API 명세서 표준 템플릿 (Rigid Template)**: 
    프론트엔드 작업자와의 원활한 협업을 위해 모든 API 문서는 아래 **6단계 구조**를 반드시 준수해야 한다.
    1. **Endpoint**: `[METHOD] /url` 명시.
    2. **Description**: 기능의 비즈니스 목적 설명.
    3. **Parameters (Table)**: Location, Field, Type, Required, Description 필수 포함.
    4. **Request Example**: 실제 호출 가능한 JSON 예시 수록.
    5. **Response Summary (Table)**: HTTP 상태 코드 및 각 응답 필드 명세.
    6. **Response Example**: 성공 및 실패 상황의 실제 JSON 응답 예시 수록.

---

## 6. [부록] 기술 가이드 (Docsify Spec)
*   **사이드바 로딩**: `loadSidebar: true` (파일명 `sidebar-manifest.md` 추천).
*   **경로 규칙**: 404 방지를 위해 반드시 **상대 경로**를 사용하십시오.