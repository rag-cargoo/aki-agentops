# Catalog API Specification (Agency/Artist)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-18 08:35:00`
> - **Updated At**: `2026-02-18 08:52:22`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Source
> - Publication Policy
> - Content
> - 1. Agency API
> - 2. Artist API
> - 3. 공통 에러 응답
<!-- DOC_TOC_END -->

## Source
- SoT: `AKI AgentOps sidecar` (`prj-docs/projects/ticket-core-service/product-docs/**`)
- Updated For CRUD Sync: 2026-02-18 08:35:00

## Publication Policy
- 이 문서는 GitHub Pages 사용자 탐색용 공식 문서다.
- 변경은 `rag-cargoo/aki-agentops` sidecar PR에서 관리한다.

## Content

공연 카탈로그의 기획사(Agency), 아티스트(Artist) 도메인 CRUD API를 정의합니다.

---

## 1. Agency API

### 1.1. 기획사 생성
- **Endpoint**: `POST /api/agencies`
- **Description**: 기획사를 생성합니다.

**Request Body**

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `name` | String | Yes | 기획사 이름 (중복 불가) |
| `countryCode` | String | No | 국가 코드 (`KR`, `JP` 등) |
| `homepageUrl` | String | No | 홈페이지 URL |

**Response (201 Created)**

```json
{
  "id": 1,
  "name": "ADOR",
  "countryCode": "KR",
  "homepageUrl": "https://ador.world"
}
```

### 1.2. 기획사 목록 조회
- **Endpoint**: `GET /api/agencies`
- **Description**: 전체 기획사 목록을 조회합니다.

### 1.3. 기획사 단건 조회
- **Endpoint**: `GET /api/agencies/{id}`
- **Description**: 기획사 단건 정보를 조회합니다.

### 1.4. 기획사 수정
- **Endpoint**: `PUT /api/agencies/{id}`
- **Description**: 기획사 이름/메타데이터를 수정합니다.

**Request Body**

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `name` | String | Yes | 기획사 이름 |
| `countryCode` | String | No | 국가 코드 |
| `homepageUrl` | String | No | 홈페이지 URL |

### 1.5. 기획사 삭제
- **Endpoint**: `DELETE /api/agencies/{id}`
- **Description**: 기획사를 삭제합니다.
- **Constraint**: 소속 아티스트가 있으면 삭제가 차단됩니다.

---

## 2. Artist API

### 2.1. 아티스트 생성
- **Endpoint**: `POST /api/artists`
- **Description**: 아티스트를 생성합니다.

**Request Body**

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `name` | String | Yes | 아티스트 이름 (중복 불가) |
| `agencyId` | Long | Yes | 소속 기획사 ID |
| `displayName` | String | No | 표시 이름 |
| `genre` | String | No | 장르 |
| `debutDate` | Date | No | 데뷔일 (`yyyy-mm-dd`) |

**Response (201 Created)**

```json
{
  "id": 10,
  "name": "NewJeans",
  "displayName": "NewJeans",
  "genre": "K-POP",
  "debutDate": "2022-07-22",
  "agencyId": 1,
  "agencyName": "ADOR"
}
```

### 2.2. 아티스트 목록 조회
- **Endpoint**: `GET /api/artists`
- **Description**: 전체 아티스트 목록을 조회합니다.

### 2.3. 아티스트 단건 조회
- **Endpoint**: `GET /api/artists/{id}`
- **Description**: 아티스트 단건 정보를 조회합니다.

### 2.4. 아티스트 수정
- **Endpoint**: `PUT /api/artists/{id}`
- **Description**: 아티스트 이름/프로필/소속 기획사를 수정합니다.

**Request Body**

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `name` | String | Yes | 아티스트 이름 |
| `agencyId` | Long | Yes | 소속 기획사 ID |
| `displayName` | String | No | 표시 이름 |
| `genre` | String | No | 장르 |
| `debutDate` | Date | No | 데뷔일 |

### 2.5. 아티스트 삭제
- **Endpoint**: `DELETE /api/artists/{id}`
- **Description**: 아티스트를 삭제합니다.
- **Constraint**: 연결된 공연이 있으면 삭제가 차단됩니다.

---

## 3. 공통 에러 응답

```json
{
  "timestamp": "2026-02-18T08:35:00.000",
  "status": 400,
  "error": "Bad Request",
  "path": "/api/artists/999"
}
```
