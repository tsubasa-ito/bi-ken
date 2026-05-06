# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

美術検定（Art Certification）学習アプリ - Swift（iOS ネイティブ）への完全移行を進めています。

- **`BiKenSwift/`**: Swift 6 / iOS 17+ ネイティブアプリ（メイン開発対象）
- **`app/`, `src/`**: React Native + Expo の旧実装（参照用・順次削除予定）

Metropolitan Museum of Art APIから作品データを取得し、日本語でクイズを出題する。

## Development Commands

### Swift（BiKenSwift/）

```bash
# xcodegen でプロジェクト生成
cd BiKenSwift && xcodegen generate

# ビルド（iOSシミュレーター向け）
xcodebuild -target BiKen -sdk iphonesimulator -arch arm64 build SYMROOT=/tmp/biken-products

# シミュレーターにインストールして起動
xcrun simctl install booted /tmp/biken-products/Debug-iphonesimulator/BiKen.app
xcrun simctl launch booted com.tebasakin.biken
```

### React Native（旧実装・参照用）

```bash
npm start          # 開発サーバー起動
npm run ios        # iOSシミュレーターで起動
npm run android    # Androidエミュレーターで起動
npx tsc --noEmit   # 型チェック
```

## Swift Architecture（BiKenSwift/）

### Data Flow
```
Met Museum API → MetMuseumAPIService.swift → ArtworkConverter.swift → ViewModels → SwiftUI Views
```

### Key Services

**BiKen/Services/MetMuseumAPIService.swift**
- Metropolitan Museum of Art API との通信（async/await）
- `artworksByQueries(_:limitPerQuery:)`: `withTaskGroup` で並列実行、エラーは吸収して続行
- nullable フィールド（`artistDisplayName` 等）はすべて `String?` で受け取る

**BiKen/Services/ArtworkConverter.swift**
- `MetArtworkResponse` → `Artwork` 型への変換
- `MAPPED_ARTISTS`: 日本語マッピングが存在する作家名リスト
- `hasJapaneseMapping()`: マッピング存在チェック（これを通過した作品のみ表示）
- `year`: `objectBeginDate > 0` のときのみセット、それ以外は `nil`

**BiKen/Services/ArtworkCache.swift**
- `actor ArtworkCache` - 5分TTLのインメモリキャッシュ
- `CacheEntry.value: Any` 型でJSON再エンコード不要

### ViewModels

- `HomeViewModel`: デイリー作品（日付シードで固定）・フィーチャー作品取得
- `QuizViewModel`: クイズ進行・回答記録・URLError種別ごとのエラーメッセージ
- `CollectionViewModel`: `withTaskGroup` でプログレッシブロード・重複除去

### Navigation

`NavigationStack` + `TabView`:
- `HomeView` → `QuizView(eraID:)` / `ArtworkDetailView(artwork:)`
- `CollectionView` → `ArtworkDetailView(artwork:)`

### Type Definitions（BiKen/Models/）

- `Artwork`: `artistOriginal`（英語名）を保持、`year` は `Int?`
- `QuizQuestion`: `init` で `options.contains(correctAnswer)` を `precondition` チェック
- `UserProgress`: 全プロパティ `private(set)`、`levelTitle` は computed

### Swift コーディングルール

- Swift 6 / `@Observable` + `@MainActor` ViewModel
- `ShapeStyle where Self == Color` extension でドット構文カラーを使用
- `withTaskGroup`（non-throwing）でAPI並列取得
- `@Environment(\.dismiss)` でナビゲーション dismiss

## React Native Architecture（旧実装）

### Data Flow
```
Met Museum API → metMuseumApi.ts → artworkConverter.ts → useArtworks hooks → UI Components
```

### Key Services

**src/services/metMuseumApi.ts**
- インメモリキャッシュ（5分TTL）でAPI呼び出しを最適化
- `getArtworksByQueries()`: 複数クエリを並列実行

**src/services/artworkConverter.ts**
- `MAPPED_ARTISTS`: 日本語マッピングが存在する作家名リスト（約100名）
- `hasJapaneseMapping()`: マッピング存在チェック

### Routing (Expo Router)

- `app/(tabs)/` - タブナビゲーション
- `app/quiz/[id].tsx` - クイズ画面
- `app/artwork/[id].tsx` - 作品詳細画面

## Important Patterns

### 日本語化フィルタリング
Met Museum APIは英語データを返すため、マッピング辞書に存在する作家・作品のみを表示する設計。新しい作家を追加する場合はマッピング辞書とリスト両方に追加が必要。

### APIレート制限対策
- クエリ数を最大4に制限
- キャッシュで重複リクエストを抑制

## Reference Documentation

- `docs/BIJUTSU_KENTEI_4.md` - 美術検定4級頻出作家・作品リスト
- `docs/ART_APIS.md` - 美術API調査結果
