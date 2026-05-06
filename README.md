# 美術検定 学習アプリ

美術検定の合格を目指す方のための学習コンパニオンアプリです。クイズ形式で楽しく美術の知識を身につけ、コレクションを増やしながら学習を進められます。

## スクリーンショット

| ホーム | クイズ | コレクション | 作品詳細 |
|:------:|:------:|:------------:|:--------:|
| 今日の一問・時代別学習 | 4択クイズ形式 | マスターした作品一覧 | 解説・検定ポイント |

## 機能

### 学習機能
- **今日の一問**: 毎日更新されるデイリーチャレンジ
- **時代別学習**: ルネサンス、バロック、印象派、近代美術などカテゴリ別に学習
- **4択クイズ**: 作品画像から作者を当てるクイズ形式
- **作品解説**: 正解後に詳しい解説と検定のポイントを表示

### コレクション機能
- マスターした作品を自動でコレクションに追加
- 時代別フィルターで作品を絞り込み
- 作品詳細から解説をいつでも復習可能

### 進捗管理
- 習熟度をパーセンテージで可視化
- 連続学習日数・学習作品数の記録
- 合格までの目安を表示

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
├── 今日の一問 → クイズ → 結果 → (次の問題 / ホーム)
└── 時代から学ぶ → クイズ → 結果

コレクション
└── 作品タップ → 作品詳細

進捗
└── 習熟度・連続日数・取得認定証

設定
└── 各種設定
```
