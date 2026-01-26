# 🏗️ 디렉토리 구조 정의 (Directory Structure)

이 문서는 `Workspace Root` (기본값: `workspace`) 내부의 표준 구조를 정의합니다.

## 0. Management 구조 (Global)
```
management/
├── rules/               # 규칙 문서
│   ├── WORKFLOW.md
│   ├── STRUCTURE.md
│   └── CODING_STANDARD.md
├── ai-context/          # [Global] 재사용 가능한 AI 리소스
│   ├── backend/         # 백엔드 (Java, Spring, DB...)
│   ├── frontend/        # 프론트엔드 (React, TS...)
│   ├── infra/           # 인프라 (Docker, AWS...)
│   └── integrations/    # 외부 연동 (Payment, Auth...)
├── knowledge-index.md
└── troubleshooting-index.md
```

## 1. 표준 계층 (Standard Layers)
모든 프로젝트는 아래의 분류 중 하나에 속해야 합니다.

### 📱 Apps (`apps/`)
*   최종 사용자용 애플리케이션 또는 API 서버.
*   예: `web-frontend`, `backend-api`

### 🏛️ Infra (`infra/`)
*   클라우드 리소스 및 인프라 프로비저닝 코드.
*   예: `terraform-aws`, `ansible-common`

### ☸️ Manifests (`manifests/`)
*   Kubernetes, Helm 등 배포 설정 파일 (GitOps).
*   예: `argocd-apps`, `helm-charts`

## 2. 프로젝트 내부 구조 (Project Internal)
각 서브 프로젝트 폴더 내부는 반드시 다음 구조를 따릅니다.
```
my-project/
├── prj-docs/              # [필수] 프로젝트 관리 문서
│   ├── task.md            # 현황판
│   ├── TODO.md            # 할 일 목록
│   ├── ROADMAP.md         # 장기 계획
│   ├── knowledge/         # [선택] 지식 문서 (사용자 요청 시)
│   ├── troubleshooting/   # [선택] 트러블슈팅 (사용자 요청 시)
│   └── ai-context/        # [선택] AI 전용 컨텍스트 (llms.txt 등)
└── src/ (또는 루트)        # 실제 소스 코드
```

**중요**: `knowledge/`와 `troubleshooting/` 폴더의 문서는 **사용자가 명시적으로 요청할 때만** 작성합니다.
