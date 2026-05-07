# 美術検定 学習アプリ

美術検定の合格を目指す方のための学習コンパニオンアプリです。クイズ形式で楽しく美術の知識を身につけ、コレクションを増やしながら学習を進められます。

## スクリーンショット

| ホーム | クイズ | コレクション | 作品詳細 |
|:------:|:------:|:------------:|:--------:|
| 今日の一問・時代別学習 | 4択クイズ形式 | マスターした作品一覧 | 解説・検定ポイント |

## 機能

### 学習機能
- **10問チャレンジ**: 全時代からランダム10問・A/B/C/Dバッジ付き4択クイズ
- **時代別学習**: ルネサンス、バロック、印象派、近代美術などカテゴリ別に学習
- **復習モード**: 過去に間違えた問題だけを集中して復習
- **作品解説**: 正解後に詳しい解説と検定のポイントを表示
- **結果画面**: ○×グリッドとスコア表示、間違えた問題をワンタップで復習

### コレクション機能
- 時代別フィルターで作品を絞り込み
- 作品詳細から解説をいつでも復習可能

### 進捗管理
- **XPシステム**: 正解でXP獲得、100XPでレベルアップ・認定証を取得
- **学習ストリーク**: 連続学習日数の記録
- **ヒートマップ**: 直近28日間の学習履歴を可視化

### 設定
- **プロフィール**: ユーザー名の設定（ホーム画面アバターに反映）
- **通知**: プッシュ通知の許可とリマインダー時刻設定
- **目標設定**: 1日の目標問題数（5〜30問から選択）
- **進捗リセット**: 学習履歴・XP・レベルをリセット（名前・目標は保持）

## 技術スタック

- **Language**: Swift 6
- **UI Framework**: SwiftUI
- **Architecture**: `@Observable` + `@MainActor` ViewModel
- **Navigation**: NavigationStack + TabView
- **Networking**: URLSession async/await
- **Target**: iOS 17.0+

## セットアップ

### 前提条件

- Xcode 16 以上
- [xcodegen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
- iOS 17 以上のシミュレーターまたは実機

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
├── BiKen/
│   ├── App/
│   │   └── BiKenApp.swift       # エントリーポイント
│   ├── Models/                  # データモデル
│   │   ├── Artwork.swift
│   │   ├── Era.swift
│   │   ├── QuizQuestion.swift
│   │   └── UserProgress.swift
│   ├── Services/                # APIサービス
│   │   ├── MetMuseumAPIService.swift
│   │   ├── ArtworkCache.swift
│   │   └── ArtworkConverter.swift
│   ├── ViewModels/              # @Observable ViewModel
│   │   ├── HomeViewModel.swift
│   │   ├── QuizViewModel.swift
│   │   └── CollectionViewModel.swift
│   ├── Views/                   # SwiftUI ビュー
│   │   ├── Home/
│   │   ├── Quiz/
│   │   ├── Collection/
│   │   ├── Artwork/
│   │   └── ...
│   └── Extensions/              # Color+Theme.swift 等
├── project.yml                  # xcodegen 設定
├── docs/                        # 参考資料
└── bijutsu-kentei.pen           # デザインファイル
```

## 画面遷移

```
ホーム
├── 10問チャレンジ → QuizView(.random) → 結果 → [復習] QuizView(.specificIDs)
├── 時代から学ぶ → EraSelectionSheet → QuizView(.era(Era))
└── 復習する → QuizView(.review)

コレクション
└── 作品タップ → 作品詳細

学習記録
├── XPバー・レベル表示
├── 時代別進捗バー
├── 28日学習ヒートマップ
└── 学習を続ける → QuizView(.random)

設定
├── プロフィール → 名前変更
├── 通知 → 許可リクエスト / 学習リマインダー設定
├── 目標設定 → 1日の目標問題数
├── 学習リマインダー → 毎日通知の時刻設定
├── 進捗をリセット → 確認ダイアログ → UserProgress 全リセット
├── アプリについて → アプリ情報・機能紹介
└── ヘルプ → FAQ アコーディオン
```
