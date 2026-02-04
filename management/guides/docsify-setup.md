# 📘 문서화 시스템 구축 가이드 (Docsify Setup Guide)

> **Goal**: 이 가이드를 따라 하면 5분 안에 현재와 같은 문서 웹사이트를 구축할 수 있습니다.
> **Tools**: GitHub Pages + Docsify

---

## 1. 준비물 (Prerequisites)
*   GitHub 저장소 (Repository)
*   약간의 Markdown 지식

---

## 2. 단계별 구축 (Step-by-Step)

### Step 1: 필수 파일 생성 (Root)
프로젝트 최상위 루트(`/`)에 다음 3개 파일을 생성합니다.

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
      loadSidebar: 'sidebar-manifest.md', // 사이드바 파일 지정
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

**3. `sidebar-manifest.md`**
*   왼쪽 메뉴를 정의합니다.
*   **중요**: 링크는 반드시 **루트 기준 절대 경로(`/`)**를 사용하세요.
```markdown
* [Home](/README.md)

* **GUIDES**
  * [Setup Guide](/management/guides/docsify-setup.md)
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
*   **해결**: `sidebar-manifest.md`에서 모든 링크 앞에 `/`를 붙였는지 확인하세요. (예: `management/...` -> `/management/...`)

### Q3. 사이드바가 안 보여요.
*   **해결**: `.nojekyll` 파일이 있는지 확인하고, `index.html`의 `loadSidebar` 설정이 올바른 파일명을 가리키는지 확인하세요.
