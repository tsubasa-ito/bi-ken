import { useState, useEffect, useCallback } from 'react';
import { Artwork, QuizQuestion } from '../types';
import {
  getHighlightArtworks,
  getArtExamArtworks,
  searchArtworks,
  getArtwork,
  RECOMMENDED_SEARCHES,
  MetArtworkResponse,
} from '../services/metMuseumApi';
import {
  convertMetArtworks,
  convertMetArtworkToArtwork,
  generateQuizFromArtworks,
} from '../services/artworkConverter';

interface UseArtworksResult {
  artworks: Artwork[];
  loading: boolean;
  error: Error | null;
  refetch: () => void;
}

interface UseQuizResult {
  questions: QuizQuestion[];
  loading: boolean;
  error: Error | null;
  refetch: () => void;
}

/**
 * 美術検定向けの作品を取得するフック
 */
export function useArtExamArtworks(limitPerCategory: number = 5): UseArtworksResult {
  const [artworks, setArtworks] = useState<Artwork[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchArtworks = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const metArtworks = await getArtExamArtworks(limitPerCategory);
      const converted = convertMetArtworks(metArtworks);
      setArtworks(converted);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to fetch artworks'));
    } finally {
      setLoading(false);
    }
  }, [limitPerCategory]);

  useEffect(() => {
    fetchArtworks();
  }, [fetchArtworks]);

  return { artworks, loading, error, refetch: fetchArtworks };
}

/**
 * キーワードで作品を検索するフック
 */
export function useSearchArtworks(query: string, limit: number = 20): UseArtworksResult {
  const [artworks, setArtworks] = useState<Artwork[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const fetchArtworks = useCallback(async () => {
    if (!query.trim()) {
      setArtworks([]);
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const metArtworks = await getHighlightArtworks(query, limit);
      const converted = convertMetArtworks(metArtworks);
      setArtworks(converted);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to search artworks'));
    } finally {
      setLoading(false);
    }
  }, [query, limit]);

  useEffect(() => {
    fetchArtworks();
  }, [fetchArtworks]);

  return { artworks, loading, error, refetch: fetchArtworks };
}

/**
 * 時代/カテゴリ別に作品を取得するフック
 */
export function useArtworksByEra(
  era: 'renaissance' | 'baroque' | 'impressionism' | 'modern' | 'japanese' | 'all',
  limit: number = 20
): UseArtworksResult {
  const [artworks, setArtworks] = useState<Artwork[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchArtworks = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      let queries: string[];

      switch (era) {
        case 'renaissance':
          queries = RECOMMENDED_SEARCHES.RENAISSANCE;
          break;
        case 'baroque':
          queries = RECOMMENDED_SEARCHES.BAROQUE;
          break;
        case 'impressionism':
          queries = [...RECOMMENDED_SEARCHES.IMPRESSIONISM, ...RECOMMENDED_SEARCHES.POST_IMPRESSIONISM];
          break;
        case 'modern':
          queries = RECOMMENDED_SEARCHES.MODERN;
          break;
        case 'japanese':
          queries = RECOMMENDED_SEARCHES.JAPANESE;
          break;
        default:
          queries = [
            ...RECOMMENDED_SEARCHES.RENAISSANCE,
            ...RECOMMENDED_SEARCHES.IMPRESSIONISM,
            ...RECOMMENDED_SEARCHES.BAROQUE,
          ];
      }

      // クエリを制限してAPI負荷を軽減（最大4クエリ）
      const selectedQueries = queries.sort(() => Math.random() - 0.5).slice(0, 4);
      const allArtworks: MetArtworkResponse[] = [];

      for (const query of selectedQueries) {
        try {
          const results = await getHighlightArtworks(query, 15);
          allArtworks.push(...results);
          // APIレート制限を回避するため少し待機
          await new Promise(resolve => setTimeout(resolve, 100));
        } catch (e) {
          console.warn(`Failed to fetch artworks for query: ${query}`);
        }
      }

      const converted = convertMetArtworks(allArtworks);
      // シャッフルして返す
      const shuffled = converted.sort(() => Math.random() - 0.5);
      setArtworks(shuffled.slice(0, limit));
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to fetch artworks'));
    } finally {
      setLoading(false);
    }
  }, [era, limit]);

  useEffect(() => {
    fetchArtworks();
  }, [fetchArtworks]);

  return { artworks, loading, error, refetch: fetchArtworks };
}

/**
 * クイズ問題を生成するフック
 */
export function useQuiz(
  era: 'renaissance' | 'baroque' | 'impressionism' | 'modern' | 'japanese' | 'all' = 'all',
  questionCount: number = 10
): UseQuizResult {
  const [questions, setQuestions] = useState<QuizQuestion[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchQuiz = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      let queries: string[];

      switch (era) {
        case 'renaissance':
          queries = RECOMMENDED_SEARCHES.RENAISSANCE;
          break;
        case 'baroque':
          queries = RECOMMENDED_SEARCHES.BAROQUE;
          break;
        case 'impressionism':
          queries = [...RECOMMENDED_SEARCHES.IMPRESSIONISM, ...RECOMMENDED_SEARCHES.POST_IMPRESSIONISM];
          break;
        case 'modern':
          queries = RECOMMENDED_SEARCHES.MODERN;
          break;
        case 'japanese':
          queries = RECOMMENDED_SEARCHES.JAPANESE;
          break;
        default:
          queries = [
            ...RECOMMENDED_SEARCHES.RENAISSANCE.slice(0, 2),
            ...RECOMMENDED_SEARCHES.IMPRESSIONISM.slice(0, 2),
            ...RECOMMENDED_SEARCHES.BAROQUE.slice(0, 2),
            ...RECOMMENDED_SEARCHES.JAPANESE.slice(0, 2),
          ];
      }

      // クエリを制限してAPI負荷を軽減（最大4クエリ）
      const selectedQueries = queries.slice(0, 4);
      const allArtworks: MetArtworkResponse[] = [];

      for (const query of selectedQueries) {
        try {
          const results = await getHighlightArtworks(query, 15);
          allArtworks.push(...results);
          // APIレート制限を回避するため少し待機
          await new Promise(resolve => setTimeout(resolve, 100));
        } catch (e) {
          console.warn(`Failed to fetch artworks for query: ${query}`);
        }
      }

      const converted = convertMetArtworks(allArtworks);

      if (converted.length < 4) {
        throw new Error('十分な作品を取得できませんでした。しばらく待ってから再試行してください。');
      }

      const quizQuestions = generateQuizFromArtworks(converted, questionCount);
      setQuestions(quizQuestions);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to generate quiz'));
    } finally {
      setLoading(false);
    }
  }, [era, questionCount]);

  useEffect(() => {
    fetchQuiz();
  }, [fetchQuiz]);

  return { questions, loading, error, refetch: fetchQuiz };
}

/**
 * 単一の作品を取得するフック
 */
export function useArtwork(objectId: string | number): {
  artwork: Artwork | null;
  loading: boolean;
  error: Error | null;
} {
  const [artwork, setArtwork] = useState<Artwork | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchArtwork = async () => {
      setLoading(true);
      setError(null);

      try {
        const id = typeof objectId === 'string' ? parseInt(objectId) : objectId;
        const metArtwork = await getArtwork(id);
        const converted = convertMetArtworkToArtwork(metArtwork);
        setArtwork(converted);
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Failed to fetch artwork'));
      } finally {
        setLoading(false);
      }
    };

    if (objectId) {
      fetchArtwork();
    }
  }, [objectId]);

  return { artwork, loading, error };
}
