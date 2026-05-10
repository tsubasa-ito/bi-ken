# デザインドキュメント — 美術検定（BiKen）

## 1. デザイン方針

### コンセプト
「美術の教科書をスマホで開く」体験。クラシックで落ち着いた美術館的な雰囲気を保ちながら、学習アプリとして直感的に操作できる UI を目指す。

### デザイン原則
- **Serif first** — 見出しにセリフ書体を使い、美術・文化系の高級感を演出する
- **Neutral canvas** — 暖白の背景で作品画像が映える余白を確保する
- **Clear feedback** — クイズの正解・不正解は色・形の両方で即座に認識できる
- **Minimal chrome** — タブバーなし、NavigationStack のみで画面遷移をシンプルに保つ

---

## 2. カラーパレット

| トークン | Hex | 用途 |
|---|---|---|
| `appBackground` | `#FAFAF7` | 全画面ベース背景（暖白） |
| `appPrimary` | `#3B5BDB` | 主要アクション・リンク・作家名 |
| `appAccent` | `#F5C518` | アクセント・ストリーク・CTA |
| `appText` | `#1A1A1A` | 本文テキスト |
| `appTextSecondary` | `#4A4A4A` | 副テキスト |
| `appTextTertiary` | `#8A8A8A` | 補助テキスト・プレースホルダー |
| `appCardBG` | `#F2F1EC` | カード・入力フィールド背景 |
| `appStreakBG` | `#FFFBE8` | ストリーク強調背景 |
| `appBorder` | `#1A1A1A` | 全要素の枠線（統一） |
| `appCorrect` | `#2D6A2D` | 正解テキスト・アイコン |
| `appCorrectBG` | `#E7F4E7` | 正解選択肢背景 |
| `appIncorrect` | `#B23A3A` | 不正解テキスト・アイコン |
| `appIncorrectBG` | `#FBEAEA` | 不正解選択肢背景 |

### 実装
`Extensions/Color+Theme.swift` に `ShapeStyle where Self == Color` として定義。ドット構文（`.appPrimary`）で呼び出す。

---

## 3. タイポグラフィ

| 役割 | フォント指定 | サイズ | ウェイト |
|---|---|---|---|
| ページタイトル | `.serif` | 22–26pt | `.bold` |
| セクション見出し | `.serif` | 18–20pt | `.semibold` |
| カード見出し | `.serif` | 16–17pt | `.semibold` |
| 本文 | システムフォント | 14–15pt | `.medium` / `.regular` |
| 補助・ラベル | システムフォント | 11–13pt | `.regular` |
| 大型数字（結果画面） | システムフォント | 72pt | `.bold` |

セリフフォントは **見出しのみ** に限定し、本文では可読性を優先してシステムフォントを使用する。

---

## 4. スペーシング・レイアウト

| 項目 | 値 |
|---|---|
| 画面水平パディング | 20px |
| セクション間マージン | 24–32px |
| カード内パディング | 12–16px |
| カードコーナー半径 | 6px |
| タグ（Capsule）コーナー半径 | 14px |
| ボタンコーナー半径 | 25px |
| 枠線太さ | 1.5px |

---

## 5. コンポーネント

### 5.1 statCell — スタッツカード
ホーム画面で正答率・連続正解数・挑戦回数を表示する横並びカード。

```
┌──────────────┐
│  正答率       │
│   78%        │
└──────────────┘
```
- 背景：`appCardBG`、枠線：1.5px `appBorder`
- 数値：22pt bold serif、ラベル：11pt tertiary

### 5.2 modeRow — クイズモード選択行
クイズの開始オプションを列挙するタップ可能な行。

```
[アイコン]  タイトル          問題数  ›
            サブタイトル
```
- 行全体が `Button`、末尾に Chevron アイコン
- アイコンは丸背景（`appCardBG`）にシステムアイコン

### 5.3 streakChip — ストリーク表示
クイズ進行中のトップバーに配置する小型チップ。

```
🔥 3
```
- 背景：`appStreakBG`、枠線：1px `appAccent`
- 13pt、連続正解数をリアルタイム更新

### 5.4 optionButton — クイズ選択肢ボタン

| 状態 | 背景 | 枠線 | テキスト色 |
|---|---|---|---|
| 未回答 | 白 | `appBorder` 1.5px | `appText` |
| 選択済み正解 | `appCorrectBG` | `appCorrect` 2px | `appCorrect` |
| 選択済み不正解 | `appIncorrectBG` | `appIncorrect` 2px | `appIncorrect` |
| 正解（自分の回答以外） | `appCorrectBG` + 薄い | — | `appCorrect` |
| 無効 | `appCardBG` | — | `appTextTertiary` |

高さ 48px、コーナー半径 6px。左端に A〜D のラベルバッジ。

### 5.5 explanationPanel — 解説パネル
回答後に表示される作品情報パネル。

```
│ 作品タイトル（太字）
│ 作家名（appPrimary）
│ 年代・技法
│ ─────────────
│ 検定ポイント（本文）
```
- 左端に `appAccent` の縦線（3px）
- 背景：`appCardBG`

### 5.6 tagView — タグ
時代・技法などのメタ情報を示す Capsule 形状のラベル。

- パディング：水平 10px、垂直 4px
- 背景：`appCardBG`、枠線：1px `appTextTertiary`
- フォント：12pt regular

### 5.7 BannerAdView
`HomeView` 下部の `safeAreaInset` 内に固定配置。GADBannerView を UIViewRepresentable でラップ。

---

## 6. 画面構成

### 6.1 HomeView
```
ScrollView
├── ヘッダー（「おかえりなさい」+ 歯車ボタン）
├── ストリーク表示（studyStreak日連続）
├── スタッツ行（正答率 / 連続正解 / 挑戦回数）
├── デイリー作品カード
├── ─── 問題演習 ───
│   ├── modeRow「ランダム出題」
│   └── modeRow「時代別で学ぶ」
├── ─── 復習 ───
│   ├── modeRow「間違えた問題を復習」
│   └── modeRow「ブックマーク問題」
└── .safeAreaInset — BannerAdView
```

### 6.2 QuizView
```
VStack
├── トップバー（× ボタン / プログレスバー / streakChip）
├── 問題番号
├── 作品画像（CachedAsyncImage / タイトルプレースホルダー）
├── ヒント（年代・技法）
├── 選択肢 × 4（optionButton）
├── explanationPanel（回答後）
└── 次へボタン（回答後）
```

### 6.3 QuizResultView
```
ScrollView
├── 「セット完了」ヘッダー
├── 「おつかれさま！」見出し
├── 正解数 / 総問題数（72pt）+ 正答率
├── スタッツグリッド（本日正解 / ストリーク）
├── 結果一覧（○/× + 作品名 + 作家名 + ブックマーク）
└── アクションボタン群
    ├── 「間違えた問題を復習」（appAccent）
    ├── 「もう一度」（appCardBG）
    └── 「ホームへ」（appPrimary）
```

### 6.4 ArtworkDetailView
```
ScrollView
├── 作品画像（ヘッダー）
│   ├── 戻るボタン（左上、丸形オーバーレイ）
│   └── ブックマークボタン（右上、丸形オーバーレイ）
├── 白カード
│   ├── タイトル（serif bold）
│   ├── 作家名（appPrimary）
│   ├── 年代・サイズ・技法
│   ├── タグ行（Era・技法）
│   ├── ─── 解説 ───
│   ├── 説明文
│   ├── ─── 作家について ───
│   └── 作家略歴
└── （余白）
```

### 6.5 SettingsView（.sheet で表示）
```
NavigationStack
└── List
    ├── ヘッダー：ユーザー名
    ├── セクション「アカウント」
    │   └── NavigationLink「通知設定」
    ├── セクション「学習」
    │   └── Button「進捗をリセット」（confirmationDialog）
    └── セクション「アプリ」
        ├── NavigationLink「アプリについて」
        ├── Button「レビューを書く」
        └── NavigationLink「ヘルプ」
```

---

## 7. ナビゲーション

```
HomeView
├── → QuizView(mode: .random / .era / .review / .bookmark)
│       └── → QuizResultView
│               └── → QuizView(mode: .specificIDs([...]))
├── → ArtworkDetailView(artwork:)
└── .sheet → SettingsView
                ├── → NotificationSettingsView
                ├── → ReminderSettingsView
                ├── → AboutView
                └── → HelpView
```

画面遷移はすべて `NavigationStack` + `NavigationLink` で管理。モーダルは `SettingsView` のみ（`.sheet`）。

---

## 8. アニメーション

| シーン | 仕様 |
|---|---|
| 選択肢タップ後の状態変化 | `.easeInOut(duration: 0.2)` |
| プログレスバー更新 | `.easeInOut(duration: 0.3)` |
| 次へボタン出現 | `.spring(duration: 0.3)` |
| 解説パネル展開 | `.easeInOut(duration: 0.25)` |

---

## 9. 画像表示ルール

### 画像あり（WikipediaImageService が URL を取得済み）
`CachedAsyncImage` で表示。URLCache（メモリ 50MB、ディスク 200MB）でキャッシュ。

### 画像なし（`wikiTitle: nil` または取得失敗）
- **クイズ画面**：セリフ体で `『タイトル』` をテキスト表示
- **コレクション・詳細**：フォトアイコン + タイトルのプレースホルダー

---

## 10. 広告配置

- **バナー広告**：`HomeView` 下部、`safeAreaInset(edge: .bottom)` で画面最下部に固定
- **インタースティシャル広告**：クイズ終了後（`QuizResultView` 遷移時）に表示

本番リリース前に `AdService.swift` の `AdUnitID` と `Info.plist` の `GADApplicationIdentifier` を実際の AdMob ID に差し替えること。

---

## 11. アクセシビリティ

- タップターゲット最小サイズ：36px（アイコンボタン）、48px（選択肢）、50px（CTA ボタン）
- カラーのみに依存しない：正解・不正解はアイコン（○/×）と背景色の両方で表現
- Dynamic Type：`relativeTo:` は未適用（固定サイズ）— 将来の改善ポイント
