# 美術検定4級 名画問題集

美術検定4級の合格を目指す方のための学習アプリです。クイズ形式で楽しく美術の知識を身につけ、コレクションを増やしながら学習を進められます。

## スクリーンショット

| ホーム | クイズ | 作品詳細 |
|:------:|:------:|:--------:|
| クイズモード選択・復習 | 4択クイズ形式 | 解説・検定ポイント |

## 機能

### 学習機能
- **10問チャレンジ**: 全時代からランダム10問・A/B/C/Dバッジ付き4択クイズ
- **時代別学習**: ルネサンス、バロック、印象派、近代美術などカテゴリ別に学習
- **復習モード**: 過去に間違えた問題だけを集中して復習
- **ブックマーク**: 気になる作品・忘れやすい作品をブックマーク保存し、ブックマーク作品のみでクイズを受講
- **作品解説**: 正解後に詳しい解説と検定のポイントを表示
- **結果画面**: 作品名・作者・○×のリスト表示、各問題にブックマークボタン、間違えた問題をワンタップで復習

### 進捗管理
- **XPシステム**: 正解でXP獲得、100XPでレベルアップ・認定証を取得
- **学習ストリーク**: 連続学習日数の記録
- **ヒートマップ**: 直近28日間の学習履歴を可視化

### 設定
- **プロフィール**: ユーザー名の設定 + 推し作品の選択（ホーム画面アイコンに反映）
- **通知**: プッシュ通知の許可とリマインダー時刻設定
- **進捗リセット**: 学習履歴・XP・レベル・ブックマークをリセット

## 技術スタック

- **Language**: Swift 6
- **UI Framework**: SwiftUI
- **Architecture**: `@Observable` + `@MainActor` ViewModel
- **Navigation**: NavigationStack + Sheet
- **Networking**: URLSession async/await
- **Target**: iOS 17.0+
- **Crash Reporting**: Firebase Crashlytics
- **Analytics**: Firebase Analytics

## セットアップ

### 前提条件

- Xcode 16 以上
- [xcodegen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
- iOS 17 以上のシミュレーターまたは実機

### Firebase セットアップ（任意）

Firebase Crashlytics を有効にするには `GoogleService-Info.plist` が必要です。

1. [Firebase Console](https://console.firebase.google.com/) で Bundle ID `com.tebasakin.biken` のアプリを登録
2. ダウンロードした `GoogleService-Info.plist` をプロジェクトルートに配置

> このファイルは API キーを含むため `.gitignore` 対象です。リポジトリにコミットしないでください。
> ファイルが不在の場合もビルド・起動は可能です（Crashlytics 無効で動作）。

### ビルド方法

```bash
# リポジトリをクローン
git clone <repository-url>
cd bi-ken

# Xcode プロジェクトを生成
xcodegen generate

# Xcode で開く
open BiKen.xcodeproj
```

### コマンドラインビルド

```bash
# ビルド（iOSシミュレーター向け）
xcodebuild -target BiKen -sdk iphonesimulator -arch arm64 build SYMROOT=/tmp/biken-products

# シミュレーターにインストールして起動
xcrun simctl install booted /tmp/biken-products/Debug-iphonesimulator/BiKen.app
xcrun simctl launch booted com.tebasakin.biken
```

## プロジェクト構成

```
bi-ken/
├── App/
│   └── BiKenApp.swift               # エントリーポイント
├── Data/
│   └── TextbookArtworkData.swift    # 美術検定テキスト掲載100作品
├── Models/                          # データモデル
│   ├── Artwork.swift
│   ├── QuizQuestion.swift
│   └── UserProgress.swift
├── Services/                        # サービス
│   ├── WikipediaImageService.swift  # Wikipedia画像取得（actor）
│   ├── AppUpdateService.swift       # アップデート確認（iTunes Search API）
│   ├── AdService.swift              # Google Mobile Ads ラッパー
│   ├── ImageCache.swift             # 画像キャッシュ
│   ├── ArtworkCache.swift           # 作品データキャッシュ
│   └── ArtworkConverter.swift       # クイズ生成ロジック
├── ViewModels/                      # @Observable ViewModel
│   ├── HomeViewModel.swift
│   └── QuizViewModel.swift
├── Views/                           # SwiftUI ビュー
│   ├── Home/
│   ├── Quiz/
│   ├── Artwork/
│   └── ...
├── Extensions/                      # Color+Theme.swift 等
├── Tests/
│   └── BiKenTests/                  # XCTest ユニットテスト
├── project.yml                      # xcodegen 設定
├── docs/                            # 参考資料
└── bijutsu-kentei.pen               # デザインファイル
```

## 画面遷移

```
ホーム（唯一のルート画面）
├── 統計行（正答率・連続正解数・挑戦回数）
├── ランダム出題 → RandomQuizSetupSheet → QuizView(.random) → 結果 → [復習] QuizView(.specificIDs)
├── 時代別で学ぶ → EraSelectionSheet → QuizView(.era(Era))
├── 間違えた問題を復習 → QuizView(.review)
├── ブックマーク問題 → QuizView(.bookmark)
└── [右上歯車] → SettingsView（シート）

SettingsView（シート）
├── 通知 → 許可リクエスト / 学習リマインダー設定
├── 進捗をリセット → 確認ダイアログ → UserProgress 全リセット
├── アプリについて → アプリ情報・機能紹介
└── ヘルプ → FAQ アコーディオン
```
