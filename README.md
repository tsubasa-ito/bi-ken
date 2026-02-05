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
- 時代別の進捗グラフ
- 連続学習日数、学習時間の記録
- 合格までの目安を表示

## 技術スタック

- **Framework**: React Native + Expo (SDK 54)
- **Navigation**: Expo Router
- **Language**: TypeScript
- **Styling**: React Native StyleSheet
- **Fonts**: Noto Sans JP / Noto Serif JP (Google Fonts)
- **Icons**: @expo/vector-icons (Ionicons)
- **Graphics**: react-native-svg, expo-linear-gradient

## セットアップ

### 前提条件

- Node.js 18以上
- npm または yarn
- Expo Go アプリ（iOS/Android）またはシミュレーター

### インストール

```bash
# リポジトリをクローン
git clone <repository-url>
cd bi-ken

# 依存関係をインストール
npm install

# 開発サーバーを起動
npm start
```

### 実行方法

```bash
# 開発サーバー起動（QRコード表示）
npx expo start --ios --clear

# iOSシミュレーターで起動
npm run ios

# Androidエミュレーターで起動
npm run android

# Webブラウザで起動
npm run web
```

## プロジェクト構成

```
bi-ken/
├── app/                      # Expo Router ページ
│   ├── (tabs)/              # タブナビゲーション
│   │   ├── _layout.tsx      # タブレイアウト
│   │   ├── index.tsx        # ホーム画面
│   │   ├── collection.tsx   # コレクション画面
│   │   ├── progress.tsx     # 進捗画面
│   │   └── settings.tsx     # 設定画面
│   ├── quiz/
│   │   └── [id].tsx         # クイズ画面
│   ├── artwork/
│   │   └── [id].tsx         # 作品詳細画面
│   └── _layout.tsx          # ルートレイアウト
├── src/
│   ├── constants/
│   │   ├── colors.ts        # カラーパレット・スペーシング
│   │   └── fonts.ts         # フォント定義
│   ├── data/
│   │   └── artworks.ts      # サンプル作品データ
│   └── types/
│       └── index.ts         # TypeScript型定義
├── assets/                   # 画像・アイコン
├── app.json                  # Expo設定
├── package.json
└── tsconfig.json
```

## 画面遷移

```
ホーム
├── 今日の一問 → クイズ → 解説 → (次の問題 / ホーム)
├── 時代別学習 → クイズ → 解説 → (次の問題 / ホーム)
└── 進捗サマリー

コレクション
└── 作品タップ → 作品詳細（解説アーカイブ）

進捗
└── 習熟度・時代別グラフ表示

設定
└── アカウント・学習設定・表示設定
```

## カスタマイズ

### 作品データの追加

`src/data/artworks.ts` に作品を追加できます：

```typescript
{
  id: '9',
  title: '作品名',
  artist: '作家名',
  year: 1900,
  medium: '技法',
  movement: '様式',
  era: 'Renaissance', // Renaissance | Baroque | Impressionism | Modern Art | Japanese Art | Contemporary
  imageUrl: 'https://...',
  description: '作品解説...',
  examKeyPoint: '検定のポイント...',
  difficulty: 'Easy', // Easy | Medium | Hard
  correctRate: 75,
}
```

### テーマカラーの変更

`src/constants/colors.ts` でカラーパレットを変更できます。
