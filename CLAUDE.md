# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

美術検定（Art Certification）学習アプリ - React Native + Expo で構築された美術検定4級対策クイズアプリ。Metropolitan Museum of Art APIから作品データを取得し、日本語でクイズを出題する。

## Development Commands

```bash
# 開発サーバー起動
npm start

# iOSシミュレーターで起動
npm run ios

# Androidエミュレーターで起動
npm run android

# 型チェック
npx tsc --noEmit
```

## Architecture

### Data Flow
```
Met Museum API → metMuseumApi.ts → artworkConverter.ts → useArtworks hooks → UI Components
```

### Key Services

**src/services/metMuseumApi.ts**
- Metropolitan Museum of Art API（https://metmuseum.github.io/）との通信
- インメモリキャッシュ（5分TTL）でAPI呼び出しを最適化
- `getArtworksByQueries()`: 複数クエリを並列実行
- `RECOMMENDED_SEARCHES`: 時代別の検索キーワード定義

**src/services/artworkConverter.ts**
- APIレスポンス → アプリ内Artwork型への変換
- `MAPPED_ARTISTS`: 日本語マッピングが存在する作家名リスト（約100名）
- `hasJapaneseMapping()`: マッピング存在チェック（これを通過した作品のみ表示）
- 作家名・作品タイトルの日本語マッピング辞書

**src/hooks/useArtworks.ts**
- `useQuiz(era, count)`: クイズ問題生成
- `useArtworksByEra(era, limit)`: 時代別作品取得
- `useArtwork(objectId)`: 単一作品取得

### Routing (Expo Router)

- `app/(tabs)/` - タブナビゲーション（ホーム、コレクション、進捗、設定）
- `app/quiz/[id].tsx` - クイズ画面（時代IDをパラメータで受け取る）
- `app/artwork/[id].tsx` - 作品詳細画面（Met Museum objectIDをパラメータで受け取る）

### Type Definitions

主要な型は `src/types/index.ts` に定義:
- `Artwork`: 作品データ
- `Era`: 時代区分（'Renaissance' | 'Baroque' | 'Impressionism' | 'Modern Art' | 'Japanese Art' | 'Contemporary'）
- `QuizQuestion`: クイズ問題

## Important Patterns

### 日本語化フィルタリング
Met Museum APIは英語データを返すため、`artworkConverter.ts`内のマッピング辞書に存在する作家・作品のみを表示する設計。新しい作家を追加する場合は`MAPPED_ARTISTS`配列と`getJapaneseArtistName()`の辞書両方に追加が必要。

### APIレート制限対策
- クエリ数を最大4に制限
- バッチサイズ10件、バッチ間20ms待機
- 検索結果・作品詳細をキャッシュ

## Reference Documentation

- `docs/BIJUTSU_KENTEI_4.md` - 美術検定4級頻出作家・作品リスト
- `docs/ART_APIS.md` - 美術API調査結果
