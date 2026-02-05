export interface Artwork {
  id: string;
  title: string;
  titleJa?: string;
  artist: string;
  artistJa?: string;
  year: number;
  medium: string;
  movement: string;
  era: Era;
  imageUrl: string;
  description: string;
  artistBio?: string;
  artistQuote?: string;
  examKeyPoint?: string;
  difficulty: 'Easy' | 'Medium' | 'Hard';
  correctRate?: number;
}

export type Era =
  | 'Renaissance'
  | 'Baroque'
  | 'Impressionism'
  | 'Modern Art'
  | 'Japanese Art'
  | 'Contemporary';

export interface QuizQuestion {
  id: string;
  artwork: Artwork;
  questionType: 'artist' | 'title' | 'year' | 'movement';
  question: string;
  options: string[];
  correctAnswer: string;
}

export interface UserProgress {
  level: number;
  levelTitle: string;
  masteryPercentage: number;
  totalArtworksMet: number;
  totalCertificates: number;
  currentStreak: number;
  totalHours: number;
  eraProgress: Record<Era, number>;
  collectedArtworkIds: string[];
}

export interface DailyChallenge {
  id: string;
  artwork: Artwork;
  xpReward: number;
  participantsToday: number;
  description: string;
}

export interface QuizSession {
  id: string;
  era?: Era;
  questions: QuizQuestion[];
  currentIndex: number;
  correctCount: number;
  startedAt: Date;
}
