# Sidecar Operations Runbook (AKI AgentOps)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 06:03:20`
> - **Updated At**: `2026-02-17 08:40:03`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Purpose
> - Repo Target Guard
> - Security Rules
> - Drift Check
> - Rollback Standard
> - CI Responsibility Split
> - New Project Onboarding
<!-- DOC_TOC_END -->

## Purpose
- sidecar 문서 운영 시 누락되기 쉬운 공통 규칙을 단일 체크리스트로 고정한다.
- 대상: `prj-docs/projects/*` 문서를 쓰는 운영자/에이전트.

## Repo Target Guard
1. Git 명령은 대상 레포를 반드시 명시한다.
```bash
./skills/aki-codex-core/scripts/safe-git.sh --repo /home/aki/2602 status --short
./skills/aki-codex-core/scripts/safe-git.sh --repo workspace/apps/backend/ticket-core-service branch --show-current
```
2. GitHub CLI 명령은 대상 `owner/repo`를 반드시 명시한다.
```bash
./skills/aki-codex-core/scripts/safe-gh.sh --repo rag-cargoo/aki-agentops issue list --state open
./skills/aki-codex-core/scripts/safe-gh.sh --repo rag-cargoo/ticket-core-service pr list
```
3. 명시 없는 `git`, `gh` 직접 실행은 금지하지 않지만 운영 표준에서는 wrapper를 우선한다.

## Security Rules
1. sidecar 문서에 Access Token, Client Secret, Callback code 원문 저장 금지.
2. 필요한 경우 비식별 키(`KAKAO_CLIENT_ID`)와 소스 위치 링크만 남긴다.
3. 외부 공개 저장소 기준으로 문서가 노출된다고 가정하고 작성한다.

## Drift Check
1. 커밋 전 경량 검사:
```bash
bash skills/aki-codex-precommit/scripts/validate-precommit-chain.sh --mode quick
```
2. 중요 변경/머지 직전 강검증:
```bash
bash skills/aki-codex-precommit/scripts/validate-precommit-chain.sh --mode strict --strict-remote
```
3. 전체 문서 원격 정합성 점검:
```bash
bash skills/aki-codex-precommit/scripts/validate-precommit-chain.sh --mode strict --all --strict-remote
```

## Rollback Standard
1. 대규모 변경 전 백업 포인트:
```bash
./skills/aki-codex-core/scripts/create-backup-point.sh pre-change
```
2. 복구(로컬):
```bash
git switch main
git reset --hard <backup-tag-or-sha>
```
3. 복구 후 검증:
```bash
./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh
bash skills/aki-codex-precommit/scripts/validate-precommit-chain.sh --mode quick --all
```

## CI Responsibility Split
1. `AKI AgentOps` CI:
   - 문서/거버넌스/워크플로우 규칙 검증 전용.
2. 제품 레포 CI:
   - 빌드/테스트/배포 파이프라인 전용.
3. sidecar 문서에는 제품 CI 결과 URL만 링크하고, 빌드 산출물은 적재하지 않는다.

## New Project Onboarding
1. 제품 레포를 `workspace/...`에 클론.
2. `prj-docs/projects/project-map.yaml`에 `project_id/code_root/docs_root/repo_remote/default_branch` 등록.
3. `prj-docs/projects/<project-id>/`에 `README.md`, `task.md`, `meeting-notes/README.md`, `PROJECT_AGENT.md` 생성.
4. `set_active_project.sh --list`와 `session_start.sh`로 로드 검증.
5. `sidebar-manifest.md`와 루트 `README.md`에 sidecar 진입 링크 반영.
