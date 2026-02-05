# 美術作品 API リファレンス

美術検定アプリで利用可能なオープンアクセス美術館APIの一覧です。

---

## 1. Metropolitan Museum of Art API（メトロポリタン美術館）

**現在このアプリで使用中**

### 概要
- **公式サイト**: https://www.metmuseum.org/
- **APIドキュメント**: https://metmuseum.github.io/
- **画像数**: 492,000点以上
- **ライセンス**: CC0（パブリックドメイン、商用利用可、帰属表示不要）

### エンドポイント

```
Base URL: https://collectionapi.metmuseum.org/public/collection/v1
```

| エンドポイント | 説明 |
|---------------|------|
| `/objects` | 全オブジェクトIDのリストを取得 |
| `/objects/[objectID]` | 特定の作品の詳細を取得 |
| `/departments` | 部門（カテゴリ）一覧を取得 |
| `/search?q={query}` | キーワード検索 |

### 使用例

```typescript
// 作品詳細を取得
const response = await fetch(
  'https://collectionapi.metmuseum.org/public/collection/v1/objects/45734'
);
const artwork = await response.json();

// レスポンス例
{
  "objectID": 45734,
  "title": "The Great Wave off Kanagawa",
  "artistDisplayName": "Katsushika Hokusai",
  "objectDate": "ca. 1830–32",
  "medium": "Polychrome woodblock print",
  "primaryImage": "https://images.metmuseum.org/...",
  "department": "Asian Art",
  ...
}
```

### 検索パラメータ

| パラメータ | 説明 | 例 |
|-----------|------|-----|
| `q` | 検索キーワード | `q=sunflowers` |
| `isHighlight` | ハイライト作品のみ | `isHighlight=true` |
| `departmentId` | 部門ID | `departmentId=11` |
| `isOnView` | 展示中のみ | `isOnView=true` |
| `hasImages` | 画像ありのみ | `hasImages=true` |
| `artistOrCulture` | 作者/文化で検索 | `artistOrCulture=true` |

### 主要な部門ID

| ID | 部門名 |
|----|--------|
| 11 | European Paintings（ヨーロッパ絵画） |
| 6 | Asian Art（アジア美術） |
| 21 | Modern Art（近代美術） |
| 9 | Greek and Roman Art（ギリシャ・ローマ美術） |

---

## 2. Art Institute of Chicago API（シカゴ美術館）

### 概要
- **公式サイト**: https://www.artic.edu/
- **APIドキュメント**: https://api.artic.edu/docs/
- **画像数**: 60,000点以上
- **ライセンス**: CC0（パブリックドメイン）

### エンドポイント

```
Base URL: https://api.artic.edu/api/v1
```

| エンドポイント | 説明 |
|---------------|------|
| `/artworks` | 作品一覧を取得 |
| `/artworks/{id}` | 特定の作品詳細 |
| `/artworks/search?q={query}` | 検索 |
| `/artists` | 作家一覧 |

### 使用例

```typescript
// 作品を検索
const response = await fetch(
  'https://api.artic.edu/api/v1/artworks/search?q=monet&limit=10'
);
const data = await response.json();

// 画像URL生成
const imageUrl = `https://www.artic.edu/iiif/2/${artwork.image_id}/full/843,/0/default.jpg`;
```

### 特徴
- **IIIF対応**: 画像サイズを柔軟に指定可能
- **Elasticsearch**: 高度な検索クエリに対応
- **豊富なメタデータ**: 作品解説、来歴、展示履歴など

---

## 3. Rijksmuseum API（アムステルダム国立美術館）

### 概要
- **公式サイト**: https://www.rijksmuseum.nl/
- **APIドキュメント**: https://data.rijksmuseum.nl/
- **画像数**: 360,000点以上
- **ライセンス**: 帰属表示で商用利用可
- **APIキー**: 必要（無料登録）

### エンドポイント

```
Base URL: https://www.rijksmuseum.nl/api
```

| エンドポイント | 説明 |
|---------------|------|
| `/[culture]/collection?key=[api-key]` | コレクション検索 |
| `/[culture]/collection/[object-number]?key=[api-key]` | 作品詳細 |

### 使用例

```typescript
// 作品を検索（オランダ語: nl、英語: en）
const response = await fetch(
  'https://www.rijksmuseum.nl/api/en/collection?key=YOUR_API_KEY&q=vermeer'
);
const data = await response.json();
```

### 特徴
- **高解像度画像**: 最大4500pxの画像を提供
- **オランダ絵画**: フェルメール、レンブラント、ゴッホの充実したコレクション
- **Rijksstudio**: ユーザーがコレクションを作成・共有可能

---

## 4. Cleveland Museum of Art API（クリーブランド美術館）

### 概要
- **公式サイト**: https://www.clevelandart.org/
- **APIドキュメント**: https://openaccess-api.clevelandart.org/
- **画像数**: 30,000点以上
- **ライセンス**: CC0

### エンドポイント

```
Base URL: https://openaccess-api.clevelandart.org/api
```

### 使用例

```typescript
const response = await fetch(
  'https://openaccess-api.clevelandart.org/api/artworks/?q=impressionism'
);
const data = await response.json();
```

---

## 5. Harvard Art Museums API（ハーバード美術館）

### 概要
- **公式サイト**: https://harvardartmuseums.org/
- **APIドキュメント**: https://github.com/harvardartmuseums/api-docs
- **画像数**: 200,000点以上
- **APIキー**: 必要（無料登録）

### 使用例

```typescript
const response = await fetch(
  'https://api.harvardartmuseums.org/object?apikey=YOUR_KEY&q=van gogh'
);
```

---

## 6. Europeana API（ヨーロッパ文化遺産）

### 概要
- **公式サイト**: https://www.europeana.eu/
- **APIドキュメント**: https://pro.europeana.eu/page/apis
- **画像数**: 5,000万点以上（美術以外も含む）
- **APIキー**: 必要（無料登録）

### 特徴
- ヨーロッパ中の美術館・図書館・アーカイブを横断検索
- 多言語対応

---

## 比較表

| API | 画像数 | ライセンス | APIキー | 日本美術 | 印象派 |
|-----|--------|-----------|---------|---------|--------|
| **Met Museum** | 492,000+ | CC0 | 不要 | ◎ | ◎ |
| **Art Institute Chicago** | 60,000+ | CC0 | 不要 | ○ | ◎ |
| **Rijksmuseum** | 360,000+ | 帰属表示 | 必要 | △ | ○ |
| **Cleveland** | 30,000+ | CC0 | 不要 | ○ | ○ |
| **Harvard** | 200,000+ | 様々 | 必要 | ○ | ○ |

---

## 推奨

**美術検定アプリには Metropolitan Museum of Art API を推奨**

理由：
1. APIキー不要で手軽に始められる
2. CC0ライセンスで商用利用も安心
3. 日本美術（浮世絵）から西洋絵画まで幅広くカバー
4. 美術検定に出題される有名作品が多数収録
