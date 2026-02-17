#  GitHub Pages 배포 및 운영 가이드

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-17 18:07:35`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 단계 목차 (Step Index)
---
> [!TIP]
> - Step 1: 필수 파일 생성 (Root + github-pages)
> - Step 2: GitHub Pages 배포 설정
> - Step 3: 확인
<!-- DOC_TOC_END -->

> **Goal**: GitHub Pages와 Docsify를 사용하여 5분 안에 프로젝트 문서 사이트를 구축하는 방법을 설명합니다.

---

## 1. 준비물 (Prerequisites)
*   GitHub 저장소 (Repository)
*   약간의 Markdown 지식

---

## 2. 단계별 구축 (Step-by-Step)

### Step 1: 필수 파일 생성 (Root + github-pages)
프로젝트 최상위 루트(`/`)에 다음 파일을 생성합니다.

**1. `index.html`**
웹사이트의 뼈대입니다. 아래 코드를 그대로 복사해서 쓰세요.
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Tech Docs</title>
  <link rel="stylesheet" href="//cdn.jsdelivr.net/npm/docsify@4/lib/themes/vue.css">
  <style>
    /* 활성 메뉴 강조 스타일 */
    .sidebar-nav li.active > a {
      color: #42b983 !important;
      font-weight: bold !important;
      background-color: #f3fcf8;
      border-left: 4px solid #42b983;
      padding-left: 10px;
    }
  </style>
</head>
<body>
  <div id="app"></div>
  <script>
    window.$docsify = {
      name: 'Project Docs',
      repo: '', // GitHub URL (선택)
      loadSidebar: 'github-pages/sidebar-manifest.md', // 사이드바 파일 지정
      subMaxLevel: 0, // 사이드바에 페이지 내부 목차 표시 안 함
      sidebarDisplayLevel: 1, // 1레벨만 펼침
      auto2top: true
    }
  </script>
  <script src="//cdn.jsdelivr.net/npm/docsify@4"></script>
  <script src="//cdn.jsdelivr.net/npm/docsify-sidebar-collapse/dist/docsify-sidebar-collapse.min.js"></script>
</body>
</html>
```

**2. `.nojekyll`**
*   빈 파일로 만듭니다.
*   **역할**: GitHub가 `_`로 시작하는 파일(`_sidebar.md` 등)을 무시하지 않게 합니다.

**3. `github-pages/HOME.md`**
*   사이트 홈 페이지 문서입니다.

**4. `github-pages/sidebar-manifest.md`**
*   왼쪽 메뉴를 정의합니다.
*   **중요**: 링크는 반드시 **루트 기준 절대 경로(`/`)**를 사용하세요.
```markdown
* [Home](/github-pages/HOME.md)

* **WORKSPACE**
  * [Current Tasks](/workspace/apps/<domain>/<service>/prj-docs/task.md)
```

### Step 2: GitHub Pages 배포 설정
1.  GitHub 저장소 상단 메뉴의 **Settings** 클릭.
2.  왼쪽 사이드바에서 **Pages** 클릭.
3.  **Build and deployment** 섹션의 **Source**를 `Deploy from a branch`로 선택.
4.  **Branch**에서 `main` (또는 master) 선택하고, 폴더는 **`/ (root)`** 선택.
5.  **Save** 버튼 클릭.

### Step 3: 확인
1.  약 1~2분 후, 상단에 생성된 URL(`https://아이디.github.io/레포명/`)로 접속.
2.  화면이 잘 나오면 성공!

---

## 3. 트러블슈팅 (Troubleshooting)

### Q1. 404가 떠요.
*   **원인**: 브라우저가 옛날 경로를 기억하고 있거나, 파일명에 오타가 있음.
*   **해결**: `Ctrl + F5` (강력 새로고침) 또는 시크릿 모드에서 확인하세요.

### Q2. 메뉴를 눌렀는데 깨진 페이지가 나와요.
*   **원인**: 링크 경로 문제.
*   **해결**: `github-pages/sidebar-manifest.md`에서 모든 링크 앞에 `/`를 붙였는지 확인하세요. (예: `workspace/apps/...` -> `/workspace/apps/...`)

### Q3. 사이드바가 안 보여요.
*   **해결**: `.nojekyll` 파일이 있는지 확인하고, `index.html`의 `loadSidebar` 설정이 `github-pages/sidebar-manifest.md`를 가리키는지 확인하세요.
