# 프로젝트 문서 SoT 경계 정책 (Project Doc SoT Boundary Policy)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 23:01:31`
> - **Updated At**: `2026-02-17 23:01:31`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 1. 기본 원칙
> - 2. 문서 분류
> - 3. Target/Surface 적용 범위
> - 4. Sidecar 반입 허용 조건
> - 5. 외부 프로젝트(클론) 운영 규칙
> - 6. 예외 전환 절차 (프로젝트 문서 SoT를 sidecar로 이동)
> - 7. 종료 체크리스트
<!-- DOC_TOC_END -->

## 1. 기본 원칙
1. 프로젝트 기능/제품 문서는 해당 프로젝트 레포가 SoT다.
2. `AKI AgentOps`는 운영 sidecar 문서를 기본 SoT로 관리한다.
3. 기본 운영에서는 프로젝트 문서를 `AKI AgentOps`로 일괄 이관하지 않는다.

## 2. 문서 분류
1. Project-Resident Docs:
   - 프로젝트 레포 내부 문서(`README`, 제품/API 명세, 프로젝트 내부 가이드)
2. Sidecar-Managed Docs:
   - `AKI AgentOps`의 프로젝트 운영 문서(`task`, `meeting-notes`, 거버넌스, 인덱스)
3. Pages Publication Docs:
   - GitHub Pages에서 사용자 탐색용으로 제공되는 문서

## 3. Target/Surface 적용 범위
1. `AKI AgentOps`가 관리하는 문서는 `Target/Surface` 정책을 적용한다.
2. 외부 프로젝트 원본 문서에는 `Target/Surface` 메타를 강제하지 않는다.
3. 원본 문서와 sidecar 문서가 공존할 경우, 어느 쪽이 SoT인지 명시해야 한다.

## 4. Sidecar 반입 허용 조건
다음 조건 중 하나 이상을 만족할 때만 프로젝트 원본 문서를 sidecar로 반입한다.
1. GitHub Pages 공개 탐색을 위한 고정 경로가 필요할 때
2. 원본 접근성/보존성 이슈로 snapshot 문서가 필요할 때
3. 사용자/팀이 "문서 SoT를 sidecar로 전환"한다고 명시적으로 결정했을 때

## 5. 외부 프로젝트(클론) 운영 규칙
1. 기본값: 코드/문서는 외부 프로젝트 레포에 유지한다.
2. `AKI AgentOps`에는 프로젝트 등록 정보와 운영 추적만 기록한다.
3. 기본 반입 단위:
   - `project-map.yaml` 등록
   - sidecar `README`/`task`/`meeting-notes` 생성
   - 원본 레포 링크 연결

## 6. 예외 전환 절차 (프로젝트 문서 SoT를 sidecar로 이동)
1. 범위 결정:
   - 왜 반입/전환이 필요한지 이슈/회의록에 기록
2. 경계 정렬:
   - 프로젝트 레포: 코드 중심
   - sidecar: 문서/운영 중심
3. 경로 정합:
   - README/스크립트/내비게이션의 문서 경로를 새 SoT에 맞게 갱신
4. 상태 동기화:
   - 프로젝트 이슈/PR, sidecar task/meeting-notes를 상호 링크

## 7. 종료 체크리스트
1. SoT 위치가 문서에 명시되어 있다.
2. 잘못된 옛 경로(`삭제된 upstream path`)가 남아있지 않다.
3. sidecar 운영 문서(`task`, `meeting-notes`) 상태가 GitHub 이슈 상태와 일치한다.
