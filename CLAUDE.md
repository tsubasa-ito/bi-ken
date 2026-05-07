# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

美術検定（Art Certification）学習アプリ - Swift 6 / iOS 17+ ネイティブアプリ。Metropolitan Museum of Art APIから作品データを取得し、日本語でクイズを出題する。

## Development Commands

```bash
# xcodegen でプロジェクト生成（project.yml 変更後に実行）
xcodegen generate

# ビルド（iOSシミュレーター向け）
xcodebuild -target BiKen -sdk iphonesimulator -arch arm64 build SYMROOT=/tmp/biken-products

# シミュレーターにインストールして起動
xcrun simctl install booted /tmp/biken-products/Debug-iphonesimulator/BiKen.app
xcrun simctl launch booted com.tebasakin.biken
```

## Architecture

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
- `HomeView` → `QuizView(mode: QuizMode)` / `ArtworkDetailView(artwork:)`
- `CollectionView` → `ArtworkDetailView(artwork:)`
- `QuizResultView` → `QuizView(mode: .specificIDs([String]))` で復習クイズへ遷移

### QuizMode（BiKen/ViewModels/QuizViewModel.swift）

```swift
enum QuizMode: Equatable, Hashable {
    case random           // 全時代シャッフルの10問チャレンジ
    case era(Era)         // 時代別クイズ
    case review           // UserProgress.wrongArtworkIDs を使った復習
    case specificIDs([String]) // 結果画面から選んだ間違い問題を復習
}
```

### Type Definitions（BiKen/Models/）

- `Artwork`: `artistOriginal`（英語名）を保持、`year` は `Int?`
- `QuizQuestion`: `init` で `options.contains(correctAnswer)` を `precondition` チェック
- `UserProgress`: 全プロパティ `private(set)`、`levelTitle` は computed
  - `currentXP: Int` — 0–99、100で自動レベルアップ（`totalCertificates += 1`）
  - `wrongArtworkIDs: [String]` — 間違えた作品IDのリスト（重複なし）
  - `studyDateStrings: [String]` — ISO8601日付文字列、最大28件

### コーディングルール

- Swift 6 / `@Observable` + `@MainActor` ViewModel
- `ShapeStyle where Self == Color` extension でドット構文カラーを使用
- `withTaskGroup`（non-throwing）でAPI並列取得
- `withThrowingTaskGroup` を `fetchByIDs` など throws 伝搬が必要な箇所で使用
- `@Environment(\.dismiss)` でナビゲーション dismiss
- `Array[safe: index]` は `BiKen/Extensions/Array+Safe.swift` で定義（重複定義禁止）

## Important Patterns

### 日本語化フィルタリング
Met Museum APIは英語データを返すため、マッピング辞書に存在する作家・作品のみを表示する設計。新しい作家を追加する場合はマッピング辞書とリスト両方に追加が必要。

### APIレート制限対策
- クエリ数を最大4に制限
- キャッシュで重複リクエストを抑制

## Reference Documentation

- `docs/BIJUTSU_KENTEI_4.md` - 美術検定4級頻出作家・作品リスト
- `docs/ART_APIS.md` - 美術API調査結果
