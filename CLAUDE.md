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

# ユニットテスト実行
xcodebuild test -scheme BiKen -sdk iphonesimulator -destination "platform=iOS Simulator,arch=arm64,id=<SIMULATOR_UDID>"
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
- `fileprivate enum WikiImageResult { case found(URL); case absent }` — 恒久的失敗（記事なし・サムネイルなし）と一時的失敗（ネットワーク・HTTP 5xx）を区別
- `inFlight: [String: Task<WikiImageResult?, Never>]` で並行リクエストの重複防止（actor再入バグ対策）
- `completed: [String: WikiImageResult]` で**恒久的失敗のみ**キャッシュ（ネットワークエラーはキャッシュせず再試行可能にする）
- キー形式: `"lang:wikiTitle"`

### Services/AppUpdateService.swift

- `actor AppUpdateService` - iTunes Search API でストア最新バージョンを確認し、アップデートが必要なら App Store URL を返す
- `func checkForUpdate() async -> URL?`: 更新あり→App Store URL、なし/失敗→`nil`
- **API呼び出し成功後のみ** `lastCheckKey`（`UserDefaults`）を更新（ネットワーク失敗時に1日スキップされるバグを防ぐ）
- `isChecking: Bool` フラグで二重並行実行を防止（`.task`と`didBecomeActiveNotification`の同時発火対策）
- `isUpdateAvailable`, `compareVersions`, `shouldCheckToday` を `static` メソッドとして公開しテスト可能にする
- バージョン比較は `.` 区切りの**数値比較**（辞書順比較は `"1.9" > "1.10"` の誤判定が起きるため禁止）
- 1日1回のみチェック（当日チェック済みなら即 `nil` を返す）
- `AppRootView`（`BiKenApp.swift` 内 `private struct`）で `.task` + `didBecomeActiveNotification` の両方でチェックを呼ぶ

### App/BiKenApp.swift（初期化順序）

`BiKenApp.init()` での初期化順序は以下のとおり：
1. `FirebaseApp.configure()` — `GoogleService-Info.plist` が Bundle に存在する場合のみ実行
2. URLCache 容量設定
3. `MobileAds.shared.start()` — AdMob 初期化

**Firebase Crashlytics の前提:** `GoogleService-Info.plist`（Firebase Console からダウンロード）をプロジェクトルートに配置する必要がある。このファイルは `.gitignore` 対象（API キーを含む）。ファイルが不在の場合、Crashlytics は動作しないがアプリはクラッシュしない。

### Services/AdService.swift

- `@MainActor final class AdService` - Google Mobile Ads SDK のラッパー（シングルトン `shared`）
- `preload()`: インタースティシャル広告を非同期でプリロード。SDK 初期化完了後（`BiKenApp.init`）と広告クローズ後に呼ぶ
- `showInterstitial(onDismiss:)`: 広告が準備できていれば表示、未準備なら即 `onDismiss()` を呼ぶ
- `bannerAdUnitID`: バナー広告ユニット ID（`static let`）
- ObjC delegate は `nonisolated` + `Task { @MainActor [weak self] }` パターンで Swift 6 concurrency に対応
- **本番リリース前に `AdUnitID` の各値と `Info.plist` の `GADApplicationIdentifier` を実際の AdMob ID に差し替えること**

### Views/Components/BannerAdView.swift

- `BannerView` を `UIViewRepresentable` でラップした SwiftUI コンポーネント（AdMob v13 以降の命名）
- `HomeView` の `.safeAreaInset(edge: .bottom)` 内に配置し、画面最下部に固定表示

### ViewModels

- `HomeViewModel`: デイリー作品（日付シードで固定）・フィーチャー作品取得。`TextbookArtworkData.all` からシード選択し、Wikipedia画像を1件フェッチ
- `QuizViewModel`: クイズ進行・回答記録。`withTaskGroup` で選択作品の画像を並列フェッチ

### Navigation

`NavigationStack`（タブバーなし）:
- `HomeView` → `QuizView(mode: QuizMode)` / `ArtworkDetailView(artwork:)`
- `HomeView` ヘッダー右上の歯車ボタン → `SettingsView`（`.sheet` で表示）
- `QuizResultView` → `QuizView(mode: .specificIDs([String]))` で復習クイズへ遷移
- `SettingsView` → 各サブ設定画面（`NavigationLink` で遷移）

### Settings Views（Views/Settings/）

- `SettingsView`: 設定トップ。`HomeView` から `.sheet` で表示。`confirmationDialog` で進捗リセット確認、`@Environment(\.requestReview)` でレビューリクエスト
- `NotificationSettingsView`: `UNAuthorizationStatus` 表示と許可リクエスト。`didBecomeActiveNotification` で状態を再取得
- `ReminderSettingsView`: 毎日リマインダーのオン/オフと時刻選択（`UNCalendarNotificationTrigger`）
- `AboutView`: アプリ情報・機能紹介
- `HelpView`: FAQ アコーディオン（`expandedItem: String?` で展開状態管理）

### QuizMode（ViewModels/QuizViewModel.swift）

```swift
enum QuizMode: Equatable, Hashable {
    case random(Int)      // 指定数のランダムクイズ（5/10/20/全問）
    case era(Era)         // 時代別クイズ
    case review           // UserProgress.wrongArtworkIDs を使った復習
    case specificIDs([String]) // 結果画面から選んだ間違い問題を復習
    case bookmark         // UserProgress.bookmarkedArtworkIDs を使ったブックマーク復習
}
```

### Type Definitions（Models/）

- `Artwork`: `artistOriginal`（英語名）を保持、`year` は `Int?`、`imageURL` は `URL?`（Wikipedia画像が取得できない作品は nil）
- `QuizQuestion`: `init` で `options.contains(correctAnswer)` を `precondition` チェック
- `UserProgress`: 全プロパティ `private(set)`、`levelTitle` は computed。テスト用に `init(userDefaults: UserDefaults)` を公開（`static let shared` は `private convenience init()` 経由で `UserDefaults.standard` を使用）
  - `currentXP: Int` — 0–99、100で自動レベルアップ（`totalCertificates += 1`）
  - `wrongArtworkIDs: [String]` — 間違えた作品IDのリスト（重複なし）
  - `bookmarkedArtworkIDs: [String]` — ブックマークした作品IDのリスト。`toggleBookmark`・`isBookmarked` で操作。`reset()` でクリアされる
  - `studyDateStrings: [String]` — ISO8601日付文字列、最大28件
  - `userName: String` — ユーザー名（現在UIから変更する画面なし）
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
- ObjC SDK delegate は `nonisolated func` + `Task { @MainActor [weak self] in }` で MainActor に戻る（GoogleMobileAds 等）
- `project.yml` 変更後は必ず `xcodegen generate` を実行（SPM パッケージ追加・既存ディレクトリへの新規 `.swift` ファイル追加時も同様）

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
