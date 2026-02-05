/**
 * Metropolitan Museum of Art API Service
 * https://metmuseum.github.io/
 */

import { artworkCache } from './cache';

const BASE_URL = 'https://collectionapi.metmuseum.org/public/collection/v1';

// Met APIのレスポンス型
export interface MetArtworkResponse {
  objectID: number;
  isHighlight: boolean;
  primaryImage: string;
  primaryImageSmall: string;
  additionalImages: string[];
  department: string;
  objectName: string;
  title: string;
  culture: string;
  period: string;
  artistDisplayName: string;
  artistDisplayBio: string;
  artistNationality: string;
  artistBeginDate: string;
  artistEndDate: string;
  objectDate: string;
  objectBeginDate: number;
  objectEndDate: number;
  medium: string;
  dimensions: string;
  classification: string;
  creditLine: string;
  isPublicDomain: boolean;
  GalleryNumber: string;
}

export interface MetSearchResponse {
  total: number;
  objectIDs: number[] | null;
}

export interface MetDepartment {
  departmentId: number;
  displayName: string;
}

export interface MetDepartmentsResponse {
  departments: MetDepartment[];
}

// 部門ID（美術検定に関連するもの）
export const DEPARTMENTS = {
  EUROPEAN_PAINTINGS: 11,
  ASIAN_ART: 6,
  MODERN_ART: 21,
  DRAWINGS_PRINTS: 9,
  PHOTOGRAPHS: 19,
  EUROPEAN_SCULPTURE: 12,
} as const;

// 美術検定に適した検索キーワード
export const RECOMMENDED_SEARCHES = {
  IMPRESSIONISM: ['monet', 'renoir', 'degas', 'manet', 'cezanne', 'pissarro', 'sisley', 'morisot'],
  POST_IMPRESSIONISM: ['van gogh', 'gauguin', 'seurat', 'signac', 'toulouse-lautrec'],
  RENAISSANCE: ['leonardo da vinci', 'michelangelo', 'raphael', 'botticelli', 'titian', 'jan van eyck', 'bruegel', 'durer', 'dürer'],
  BAROQUE: ['rembrandt', 'vermeer', 'caravaggio', 'rubens', 'velazquez', 'velázquez', 'van dyck', 'la tour'],
  JAPANESE: ['hokusai', 'hiroshige', 'utamaro', 'sharaku', 'kuniyoshi', 'harunobu', 'ukiyo-e'],
  MODERN: ['picasso', 'matisse', 'kandinsky', 'klimt', 'munch', 'chagall', 'dali', 'mondrian'],
};

/**
 * 作品詳細を取得（キャッシュ対応）
 */
export async function getArtwork(objectId: number): Promise<MetArtworkResponse> {
  const cacheKey = `artwork-${objectId}`;
  const cached = artworkCache.get<MetArtworkResponse>(cacheKey);
  if (cached) {
    return cached;
  }

  const response = await fetch(`${BASE_URL}/objects/${objectId}`);
  if (!response.ok) {
    throw new Error(`Failed to fetch artwork: ${response.status}`);
  }
  const data = await response.json();
  artworkCache.set(cacheKey, data);
  return data;
}

/**
 * キーワードで作品を検索（キャッシュ対応）
 */
export async function searchArtworks(
  query: string,
  options?: {
    isHighlight?: boolean;
    hasImages?: boolean;
    departmentId?: number;
    isOnView?: boolean;
  }
): Promise<MetSearchResponse> {
  const params = new URLSearchParams({ q: query });

  if (options?.isHighlight) params.append('isHighlight', 'true');
  if (options?.hasImages !== false) params.append('hasImages', 'true');
  if (options?.departmentId) params.append('departmentId', options.departmentId.toString());
  if (options?.isOnView) params.append('isOnView', 'true');

  const cacheKey = `search-${params.toString()}`;
  const cached = artworkCache.get<MetSearchResponse>(cacheKey);
  if (cached) {
    return cached;
  }

  const response = await fetch(`${BASE_URL}/search?${params}`);
  if (!response.ok) {
    throw new Error(`Failed to search artworks: ${response.status}`);
  }
  const data = await response.json();
  artworkCache.set(cacheKey, data);
  return data;
}

/**
 * 複数の作品を並列取得（最適化版）
 */
async function fetchArtworksBatch(objectIds: number[]): Promise<(MetArtworkResponse | null)[]> {
  // 並列で取得（10件ずつのバッチ処理）
  const batchSize = 10;
  const results: (MetArtworkResponse | null)[] = [];

  for (let i = 0; i < objectIds.length; i += batchSize) {
    const batch = objectIds.slice(i, i + batchSize);
    const batchResults = await Promise.all(
      batch.map(async (id) => {
        try {
          return await getArtwork(id);
        } catch {
          return null;
        }
      })
    );
    results.push(...batchResults);

    // バッチ間で少し待機（レート制限対策、最小限に）
    if (i + batchSize < objectIds.length) {
      await new Promise(resolve => setTimeout(resolve, 20));
    }
  }

  return results;
}

/**
 * ハイライト作品を検索（美術検定向け有名作品）- 最適化版
 */
export async function getHighlightArtworks(
  query: string,
  limit: number = 10
): Promise<MetArtworkResponse[]> {
  const searchResult = await searchArtworks(query, {
    isHighlight: true,
    hasImages: true,
  });

  if (!searchResult.objectIDs || searchResult.objectIDs.length === 0) {
    return [];
  }

  // 指定数だけ取得
  const objectIds = searchResult.objectIDs.slice(0, Math.min(limit, 15));

  // 並列でバッチ取得
  const artworks = await fetchArtworksBatch(objectIds);

  // nullを除外し、画像があるもののみ返す
  return artworks.filter(
    (artwork): artwork is MetArtworkResponse =>
      artwork !== null &&
      artwork.primaryImage !== '' &&
      artwork.isPublicDomain
  );
}

/**
 * 複数のクエリを並列実行して作品を取得（最適化版）
 */
export async function getArtworksByQueries(
  queries: string[],
  limitPerQuery: number = 10
): Promise<MetArtworkResponse[]> {
  // すべてのクエリを並列実行
  const results = await Promise.all(
    queries.map(query => getHighlightArtworks(query, limitPerQuery))
  );

  // 結果をフラット化
  return results.flat();
}

/**
 * 部門別に作品を取得
 */
export async function getArtworksByDepartment(
  departmentId: number,
  limit: number = 20
): Promise<MetArtworkResponse[]> {
  const searchResult = await searchArtworks('*', {
    departmentId,
    hasImages: true,
    isHighlight: true,
  });

  if (!searchResult.objectIDs || searchResult.objectIDs.length === 0) {
    return [];
  }

  const objectIds = searchResult.objectIDs.slice(0, limit);
  const artworks = await fetchArtworksBatch(objectIds);

  return artworks.filter(
    (artwork): artwork is MetArtworkResponse =>
      artwork !== null &&
      artwork.primaryImage !== '' &&
      artwork.isPublicDomain
  );
}

/**
 * 美術検定向けの作品セットを取得
 * 各ジャンルからバランスよく取得（最適化版）
 */
export async function getArtExamArtworks(limitPerCategory: number = 5): Promise<MetArtworkResponse[]> {
  const categories = [
    { queries: RECOMMENDED_SEARCHES.IMPRESSIONISM, name: 'Impressionism' },
    { queries: RECOMMENDED_SEARCHES.RENAISSANCE, name: 'Renaissance' },
    { queries: RECOMMENDED_SEARCHES.BAROQUE, name: 'Baroque' },
    { queries: RECOMMENDED_SEARCHES.JAPANESE, name: 'Japanese' },
    { queries: RECOMMENDED_SEARCHES.MODERN, name: 'Modern' },
  ];

  // 各カテゴリからランダムに1つのアーティストを選択
  const selectedQueries = categories.map(
    category => category.queries[Math.floor(Math.random() * category.queries.length)]
  );

  // 並列で取得
  const allArtworks = await getArtworksByQueries(selectedQueries, limitPerCategory);

  // シャッフルして返す
  return allArtworks.sort(() => Math.random() - 0.5);
}

/**
 * 部門一覧を取得
 */
export async function getDepartments(): Promise<MetDepartment[]> {
  const cacheKey = 'departments';
  const cached = artworkCache.get<MetDepartment[]>(cacheKey);
  if (cached) {
    return cached;
  }

  const response = await fetch(`${BASE_URL}/departments`);
  if (!response.ok) {
    throw new Error(`Failed to fetch departments: ${response.status}`);
  }
  const data: MetDepartmentsResponse = await response.json();
  artworkCache.set(cacheKey, data.departments);
  return data.departments;
}
