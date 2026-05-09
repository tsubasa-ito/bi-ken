# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

美術検定（Art Certification）学習アプリ - Swift 6 / iOS 17+ ネイティブアプリ。美術検定テキスト掲載の名作100点をローカルデータ（TextbookArtworkData）として保持し、Wikipedia APIから作品画像を取得してクイズを出題する。

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
TextbookArtworkData.swift → ViewModels + WikipediaImageService.swift → SwiftUI Views
```

### Key Data Source

**Data/TextbookArtworkData.swift**
- 美術検定テキスト掲載の名作100点をハードコード（`TextbookArtworkData.all: [TextbookArtwork]`）
- `TextbookArtwork`: `id`（`"textbook-001"`形式）、`wikiTitle: String?`、`wikiLang: String`（`"en"` or `"ja"`）を保持
- `var era: Era`: `periodJa` 文字列から `Era` enum に変換（exhaustive マッピング）
- `func asArtwork(imageURL: URL?) -> Artwork`: `TextbookArtwork` → `Artwork` 変換

**Services/WikipediaImageService.swift**
- `actor WikipediaImageService` - Wikipedia Action API（`/w/api.php?prop=pageimages`）から作品画像を取得
- `inFlight: [String: Task<URL?, Never>]` で並行リクエストの重複防止（actor再入バグ対策）
- `completed: [String: URL?]` でリクエスト結果をキャッシュ（成功・失敗ともに記録）
- キー形式: `"lang:wikiTitle"`

### ViewModels

- `HomeViewModel`: デイリー作品（日付シードで固定）・フィーチャー作品取得。`TextbookArtworkData.all` からシード選択し、Wikipedia画像を1件フェッチ
- `QuizViewModel`: クイズ進行・回答記録。`withTaskGroup` で選択作品の画像を並列フェッチ
- `CollectionViewModel`: プレースホルダー即時表示 → `withTaskGroup` で画像を逐次更新するプログレッシブロード

### Navigation

`NavigationStack` + `TabView`:
- `HomeView` → `QuizView(mode: QuizMode)` / `ArtworkDetailView(artwork:)`
- `CollectionView` → `ArtworkDetailView(artwork:)`
- `QuizResultView` → `QuizView(mode: .specificIDs([String]))` で復習クイズへ遷移
- `SettingsView` → 各サブ設定画面（`NavigationLink` で遷移）

### Settings Views（Views/Settings/）

- `SettingsView`: 設定トップ。`confirmationDialog` で進捗リセット確認、`@Environment(\.requestReview)` でレビューリクエスト
- `ProfileSettingsView`: ユーザー名編集（`@FocusState`）+ 推し作品設定。`@AppStorage("oshiArtworkData")` に `Artwork` を JSON エンコードして永続化。`@State + onChange(initial: true)` でデコードキャッシュ
- `OshiArtworkPickerView`: 推し作品選択シート。`CollectionViewModel` で作品一覧取得、`LazyVGrid` でサムネイル表示。選択作品を `oshiArtworkData` に保存
- `NotificationSettingsView`: `UNAuthorizationStatus` 表示と許可リクエスト。`didBecomeActiveNotification` で状態を再取得
- `AboutView`: アプリ情報・機能紹介
- `HelpView`: FAQ アコーディオン（`expandedItem: String?` で展開状態管理）

### QuizMode（ViewModels/QuizViewModel.swift）

```swift
enum QuizMode: Equatable, Hashable {
    case random           // 全時代シャッフルの10問チャレンジ
    case era(Era)         // 時代別クイズ
    case review           // UserProgress.wrongArtworkIDs を使った復習
    case specificIDs([String]) // 結果画面から選んだ間違い問題を復習
    case bookmark         // UserProgress.bookmarkedArtworkIDs を使ったブックマーク復習
}
```

### Type Definitions（Models/）

- `Artwork`: `artistOriginal`（英語名）を保持、`year` は `Int?`、`imageURL` は `URL?`（Wikipedia画像が取得できない作品は nil）
- `QuizQuestion`: `init` で `options.contains(correctAnswer)` を `precondition` チェック
- `UserProgress`: 全プロパティ `private(set)`、`levelTitle` は computed
  - `currentXP: Int` — 0–99、100で自動レベルアップ（`totalCertificates += 1`）
  - `wrongArtworkIDs: [String]` — 間違えた作品IDのリスト（重複なし）
  - `bookmarkedArtworkIDs: [String]` — ブックマークした作品IDのリスト。`toggleBookmark`・`isBookmarked` で操作。`reset()` でクリアされる
  - `studyDateStrings: [String]` — ISO8601日付文字列、最大28件
  - `userName: String` — プロフィール設定で変更可能
  - `dailyGoal: Int` — 1日の目標問題数（デフォルト10）
  - `todayArtworksMet: Int` — 当日回答済み問題数（日付変更でリセット）
  - `todayDateString: String` — 当日の日付文字列（`todayArtworksMet` のリセット判定用）

### コーディングルール

- Swift 6 / `@Observable` + `@MainActor` ViewModel
- `ShapeStyle where Self == Color` extension でドット構文カラーを使用
- `withTaskGroup`（non-throwing）でAPI並列取得
- `withThrowingTaskGroup` を `fetchByIDs` など throws 伝搬が必要な箇所で使用
- `@Environment(\.dismiss)` でナビゲーション dismiss
- `Array[safe: index]` は `Extensions/Array+Safe.swift` で定義（重複定義禁止）

## Important Patterns

### 作品データの管理
全作品は `TextbookArtworkData.all` の静的配列で管理。新しい作品を追加する場合は `TextbookArtworkData.swift` に `TextbookArtwork` エントリを追加し、`wikiTitle` に Wikipedia記事名を設定する。画像が取れない・誤った画像になる場合は `wikiTitle: nil` を設定。

### Wikipedia画像の信頼性
Wikipedia REST API は曖昧さ回避ページの画像（建物・風景）を返すことがある。Action API（`prop=pageimages&redirects=1`）を使用し、問題のある作品には `wikiTitle: nil` を設定して画像なしプレースホルダーを表示する。

### 画像なし時のUI
- **クイズ**: 作品タイトルをセリフ体で表示（`Text("『タイトル』")`）
- **コレクション**: フォトアイコン + タイトルのプレースホルダーセルを表示

## Reference Documentation

- `docs/BIJUTSU_KENTEI_4.md` - 美術検定4級頻出作家・作品リスト
- `docs/ART_APIS.md` - 美術API調査結果
