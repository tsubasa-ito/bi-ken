import { Artwork, DailyChallenge, UserProgress, QuizQuestion } from '../types';

export const artworks: Artwork[] = [
  {
    id: '1',
    title: '星月夜',
    titleJa: '星月夜',
    artist: 'フィンセント・ファン・ゴッホ',
    artistJa: 'フィンセント・ファン・ゴッホ',
    year: 1889,
    medium: '油彩、カンヴァス',
    movement: '後期印象派',
    era: 'Impressionism',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg/1280px-Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg',
    description: 'サン＝レミ＝ド＝プロヴァンスの療養院の窓から描かれた本作は、ゴッホの精神的な苦悩と霊的な探求を映し出しています。渦巻く空は風や乱流の視覚的表現として解釈されることが多く、画面の上部3分の2を占めています。\n\n前景の糸杉は生と死の架け橋として機能し、炎のように空に向かって伸びています。その暗く垂直なシルエットは、月と星の鮮やかな黄色やオレンジ色と鮮烈なコントラストを生み出しています。',
    artistBio: 'オランダ（1853-1890）',
    artistQuote: '「夜は昼よりも生き生きとしていて、より豊かに彩られていると私はよく思う」',
    examKeyPoint: 'ゴッホは後期印象派に分類され、光学的リアリズムよりも表現的な色彩と感情的な響きに焦点を当てました。',
    difficulty: 'Easy',
    correctRate: 82,
  },
  {
    id: '2',
    title: '真珠の耳飾りの少女',
    titleJa: '真珠の耳飾りの少女',
    artist: 'ヨハネス・フェルメール',
    artistJa: 'ヨハネス・フェルメール',
    year: 1665,
    medium: '油彩、カンヴァス',
    movement: 'オランダ黄金時代',
    era: 'Baroque',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/1665_Girl_with_a_Pearl_Earring.jpg/800px-1665_Girl_with_a_Pearl_Earring.jpg',
    description: '「北方のモナ・リザ」とも呼ばれるこのトローニーは、異国風の衣装を身につけ、非常に大きな真珠のイヤリングをした少女を描いています。この絵画の魅力は、少女の表情と視線の曖昧さにあります。',
    artistBio: 'オランダ（1632-1675）',
    examKeyPoint: 'フェルメールは光と室内画の巨匠であり、緻密な技法とカメラ・オブスキュラの使用で知られています。',
    difficulty: 'Easy',
    correctRate: 78,
  },
  {
    id: '3',
    title: '神奈川沖浪裏',
    titleJa: '神奈川沖浪裏',
    artist: '葛飾北斎',
    artistJa: '葛飾北斎',
    year: 1831,
    medium: '木版画',
    movement: '浮世絵',
    era: 'Japanese Art',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Tsunami_by_hokusai_19th_century.jpg/1280px-Tsunami_by_hokusai_19th_century.jpg',
    description: '神奈川沖浪裏は、背景に富士山を望みながら大波に翻弄される三艘の船を描いています。北斎の連作「富嶽三十六景」の一部です。',
    artistBio: '日本（1760-1849）',
    examKeyPoint: '北斎の作品は西洋の印象派やアール・ヌーヴォーの芸術家たちに大きな影響を与えました。',
    difficulty: 'Easy',
    correctRate: 85,
  },
  {
    id: '4',
    title: '接吻',
    titleJa: '接吻',
    artist: 'グスタフ・クリムト',
    artistJa: 'グスタフ・クリムト',
    year: 1907,
    medium: '油彩、金箔、カンヴァス',
    movement: '象徴主義 / アール・ヌーヴォー',
    era: 'Modern Art',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/The_Kiss_-_Gustav_Klimt_-_Google_Cultural_Institute.jpg/800px-The_Kiss_-_Gustav_Klimt_-_Google_Cultural_Institute.jpg',
    description: '接吻は、精巧な金色の模様のローブに身を包み、抱擁するカップルを描いています。この絵画は、ビザンチンモザイクに触発された金箔の使用が特徴的です。',
    artistBio: 'オーストリア（1862-1918）',
    examKeyPoint: 'クリムトの「黄金時代」は、ビザンチン美術、エジプト美術、アーツ・アンド・クラフツ運動の影響を融合させました。',
    difficulty: 'Medium',
    correctRate: 72,
  },
  {
    id: '5',
    title: 'アダムの創造',
    titleJa: 'アダムの創造',
    artist: 'ミケランジェロ・ブオナローティ',
    artistJa: 'ミケランジェロ・ブオナローティ',
    year: 1512,
    medium: 'フレスコ',
    movement: '盛期ルネサンス',
    era: 'Renaissance',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Michelangelo_-_Creation_of_Adam_%28cropped%29.jpg/1280px-Michelangelo_-_Creation_of_Adam_%28cropped%29.jpg',
    description: 'システィーナ礼拝堂天井画の一部であるこの象徴的なフレスコ画は、創世記の聖書物語を描いており、神が最初の人間アダムに命を与える場面を表現しています。',
    artistBio: 'イタリア（1475-1564）',
    examKeyPoint: 'ミケランジェロは真のルネサンス万能人でした：彫刻家、画家、建築家、そして詩人。',
    difficulty: 'Easy',
    correctRate: 88,
  },
  {
    id: '6',
    title: 'モナ・リザ',
    titleJa: 'モナ・リザ',
    artist: 'レオナルド・ダ・ヴィンチ',
    artistJa: 'レオナルド・ダ・ヴィンチ',
    year: 1503,
    medium: '油彩、ポプラ板',
    movement: '盛期ルネサンス',
    era: 'Renaissance',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg/800px-Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg',
    description: 'モナ・リザは、被写体の謎めいた表情とレオナルドの革新的な絵画技法、特にスフマートで有名です。',
    artistBio: 'イタリア（1452-1519）',
    examKeyPoint: 'レオナルドはスフマート技法を開拓し、色彩と調子の間に柔らかい移行を生み出しました。',
    difficulty: 'Easy',
    correctRate: 92,
  },
  {
    id: '7',
    title: '睡蓮',
    titleJa: '睡蓮',
    artist: 'クロード・モネ',
    artistJa: 'クロード・モネ',
    year: 1906,
    medium: '油彩、カンヴァス',
    movement: '印象派',
    era: 'Impressionism',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Claude_Monet_-_Water_Lilies_-_1906%2C_Ryerson.jpg/1280px-Claude_Monet_-_Water_Lilies_-_1906%2C_Ryerson.jpg',
    description: 'ジヴェルニーの花園を描いた約250点の油彩画シリーズの一部。これらの作品は、一日の異なる時間帯の光と大気を捉えています。',
    artistBio: 'フランス（1840-1926）',
    examKeyPoint: 'モネは印象派の創始者であり、戸外（プレネール）での光と大気の捕捉に焦点を当てました。',
    difficulty: 'Medium',
    correctRate: 68,
  },
  {
    id: '8',
    title: 'ヴィーナスの誕生',
    titleJa: 'ヴィーナスの誕生',
    artist: 'サンドロ・ボッティチェッリ',
    artistJa: 'サンドロ・ボッティチェッリ',
    year: 1485,
    medium: 'テンペラ、カンヴァス',
    movement: '初期ルネサンス',
    era: 'Renaissance',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Sandro_Botticelli_-_La_nascita_di_Venere_-_Google_Art_Project_-_edited.jpg/1280px-Sandro_Botticelli_-_La_nascita_di_Venere_-_Google_Art_Project_-_edited.jpg',
    description: 'この傑作は、海から成人した女性として誕生し、風に吹かれて岸に運ばれるヴィーナス女神を描いています。',
    artistBio: 'イタリア（1445-1510）',
    examKeyPoint: 'ボッティチェッリの作品は、古典神話と理想美へのルネサンスの関心を体現しています。',
    difficulty: 'Medium',
    correctRate: 75,
  },
];

export const dailyChallenge: DailyChallenge = {
  id: 'daily-1',
  artwork: artworks[0],
  xpReward: 150,
  participantsToday: 2200,
  description: '後期印象派の筆致と色彩理論を今日のクイズでマスターしましょう。',
};

export const userProgress: UserProgress = {
  level: 2,
  levelTitle: '美術愛好家',
  masteryPercentage: 74,
  totalArtworksMet: 450,
  totalCertificates: 3,
  currentStreak: 12,
  totalHours: 42,
  eraProgress: {
    Renaissance: 85,
    Baroque: 65,
    Impressionism: 70,
    'Modern Art': 45,
    'Japanese Art': 60,
    Contemporary: 30,
  },
  collectedArtworkIds: ['1', '2', '3', '4', '5', '6'],
};

export const generateQuizQuestions = (era?: string, count: number = 10): QuizQuestion[] => {
  const filteredArtworks = era
    ? artworks.filter((a) => a.era === era)
    : artworks;

  const shuffled = [...filteredArtworks].sort(() => Math.random() - 0.5);
  const selected = shuffled.slice(0, Math.min(count, shuffled.length));

  return selected.map((artwork, index) => {
    const otherArtists = artworks
      .filter((a) => a.artist !== artwork.artist)
      .map((a) => a.artist)
      .sort(() => Math.random() - 0.5)
      .slice(0, 3);

    const options = [artwork.artist, ...otherArtists].sort(() => Math.random() - 0.5);

    return {
      id: `q-${index}`,
      artwork,
      questionType: 'artist',
      question: 'この作品の作者は誰でしょう？',
      options,
      correctAnswer: artwork.artist,
    };
  });
};

export const eras = [
  {
    id: 'renaissance',
    name: 'ルネサンス',
    nameEn: 'Renaissance',
    period: '14〜17世紀',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg/800px-Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg',
  },
  {
    id: 'baroque',
    name: 'バロック',
    nameEn: 'Baroque',
    period: '17〜18世紀',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/1665_Girl_with_a_Pearl_Earring.jpg/800px-1665_Girl_with_a_Pearl_Earring.jpg',
  },
  {
    id: 'impressionism',
    name: '印象派',
    nameEn: 'Impressionism',
    period: '19世紀後半',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Claude_Monet_-_Water_Lilies_-_1906%2C_Ryerson.jpg/1280px-Claude_Monet_-_Water_Lilies_-_1906%2C_Ryerson.jpg',
  },
  {
    id: 'modern',
    name: '近代美術',
    nameEn: 'Modern Art',
    period: '20世紀',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/The_Kiss_-_Gustav_Klimt_-_Google_Cultural_Institute.jpg/800px-The_Kiss_-_Gustav_Klimt_-_Google_Cultural_Institute.jpg',
  },
];
