# Catalog API Specification (Entertainment/Artist/Promoter/Venue)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-18 08:35:00`
> - **Updated At**: `2026-02-23 00:24:00`
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
> - 1. Entertainment(Agency) API
> - 2. Artist API
> - 3. Promoter API
> - 4. Venue API
> - 5. 공통 에러 응답
<!-- DOC_TOC_END -->

## Source
- SoT: `AKI AgentOps sidecar` (`prj-docs/projects/ticket-core-service/product-docs/**`)
- Updated For CRUD Sync: 2026-02-18 08:35:00

## Publication Policy
- 이 문서는 GitHub Pages 사용자 탐색용 공식 문서다.
- 변경은 `rag-cargoo/aki-agentops` sidecar PR에서 관리한다.

## Content

공연 카탈로그의 소속사(Entertainment), 아티스트(Artist), 기획사(Promoter), 공연장(Venue) 도메인 CRUD API를 정의합니다.

---

## 1. Entertainment(Agency) API

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

### 1.2-1. 기획사 검색/필터/정렬 + 페이징 조회
- **Endpoint**: `GET /api/agencies/search`
- **Description**: 기획사 이름/국가코드 기준 검색, 정렬, 페이징을 수행합니다.

**Parameters**

| Location | Field | Type | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| Query | `keyword` | String | No | 기획사 이름/국가코드 검색 키워드 |
| Query | `page` | Integer | No | 페이지 번호(기본값 `0`) |
| Query | `size` | Integer | No | 페이지 크기(기본값 `20`) |
| Query | `sort` | String | No | 정렬 규칙(`id|name|countryCode`,`asc|desc`) 예: `name,asc` |

**Response Summary (200 OK)**

| Field | Type | Description |
| :--- | :--- | :--- |
| `items` | Array | 기획사 목록 |
| `page` | Integer | 현재 페이지 번호 |
| `size` | Integer | 페이지 크기 |
| `totalElements` | Long | 전체 검색 결과 건수 |
| `totalPages` | Integer | 전체 페이지 수 |
| `hasNext` | Boolean | 다음 페이지 존재 여부 |

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

### 1.6. 엔터테인먼트 Admin 경로(동일 데이터)
- **Endpoints**
  - `POST /api/admin/entertainments`
  - `GET /api/admin/entertainments`
  - `GET /api/admin/entertainments/search`
  - `GET /api/admin/entertainments/{id}`
  - `PUT /api/admin/entertainments/{id}`
  - `DELETE /api/admin/entertainments/{id}`
- **Description**
  - 기존 `Agency` 저장소를 `Entertainment` 의미로 노출하는 운영 관리자 경로입니다.
  - 프론트 Admin은 해당 경로를 우선 사용합니다.

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

### 2.2-1. 아티스트 검색/필터/정렬 + 페이징 조회
- **Endpoint**: `GET /api/artists/search`
- **Description**: 아티스트명/표시명/장르/소속사명 검색, 소속사 필터, 정렬, 페이징을 수행합니다.

**Parameters**

| Location | Field | Type | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| Query | `keyword` | String | No | 아티스트/소속사 검색 키워드 |
| Query | `agencyId` | Long | No | 소속사 ID 필터 |
| Query | `page` | Integer | No | 페이지 번호(기본값 `0`) |
| Query | `size` | Integer | No | 페이지 크기(기본값 `20`) |
| Query | `sort` | String | No | 정렬 규칙(`id|name|displayName|genre|debutDate|agencyName`,`asc|desc`) 예: `name,asc` |

**Response Summary (200 OK)**

| Field | Type | Description |
| :--- | :--- | :--- |
| `items` | Array | 아티스트 목록 |
| `page` | Integer | 현재 페이지 번호 |
| `size` | Integer | 페이지 크기 |
| `totalElements` | Long | 전체 검색 결과 건수 |
| `totalPages` | Integer | 전체 페이지 수 |
| `hasNext` | Boolean | 다음 페이지 존재 여부 |

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

## 3. Promoter API

### 3.1. 기획사 생성
- **Endpoint**: `POST /api/admin/promoters`
- **Description**: 공연 기획/주최사(Promoter)를 생성합니다.

### 3.2. 기획사 목록 조회
- **Endpoint**: `GET /api/admin/promoters`

### 3.3. 기획사 검색/필터/정렬 + 페이징 조회
- **Endpoint**: `GET /api/admin/promoters/search`
- **Query**
  - `keyword`(선택)
  - `page`(기본 `0`)
  - `size`(기본 `20`)
  - `sort`(`id|name|countryCode`,`asc|desc`)

### 3.4. 기획사 단건 조회
- **Endpoint**: `GET /api/admin/promoters/{id}`

### 3.5. 기획사 수정
- **Endpoint**: `PUT /api/admin/promoters/{id}`

### 3.6. 기획사 삭제
- **Endpoint**: `DELETE /api/admin/promoters/{id}`
- **Constraint**: 연결된 콘서트가 있으면 삭제가 차단됩니다.

---

## 4. Venue API

### 4.1. 공연장 생성
- **Endpoint**: `POST /api/admin/venues`
- **Description**: 공연장(Venue)을 생성합니다.

### 4.2. 공연장 목록 조회
- **Endpoint**: `GET /api/admin/venues`

### 4.3. 공연장 검색/필터/정렬 + 페이징 조회
- **Endpoint**: `GET /api/admin/venues/search`
- **Query**
  - `keyword`(선택)
  - `page`(기본 `0`)
  - `size`(기본 `20`)
  - `sort`(`id|name|city|countryCode`,`asc|desc`)

### 4.4. 공연장 단건 조회
- **Endpoint**: `GET /api/admin/venues/{id}`

### 4.5. 공연장 수정
- **Endpoint**: `PUT /api/admin/venues/{id}`

### 4.6. 공연장 삭제
- **Endpoint**: `DELETE /api/admin/venues/{id}`
- **Constraint**: 연결된 회차(ConcertOption)가 있으면 삭제가 차단됩니다.

---

## 5. 공통 에러 응답

```json
{
  "timestamp": "2026-02-18T08:35:00.000",
  "status": 400,
  "error": "Bad Request",
  "path": "/api/artists/999"
}
```
