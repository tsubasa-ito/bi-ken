/**
 * Met Museum APIのレスポンスをアプリの型に変換
 */

import { Artwork, Era, QuizQuestion } from '../types';
import { MetArtworkResponse } from './metMuseumApi';

/**
 * 日本語マッピングが存在する作家名リスト
 * このリストに含まれる作家の作品のみを表示する
 * Met Museum APIが返す可能性のある名前形式を網羅
 */
const MAPPED_ARTISTS: string[] = [
  // ルネサンス
  'Botticelli', 'Sandro Botticelli', 'Alessandro Botticelli',
  'Leonardo', 'Leonardo da Vinci', 'da Vinci',
  'Michelangelo', 'Michelangelo Buonarroti', 'Buonarroti',
  'Raphael', 'Raffaello', 'Raffaello Sanzio', 'Raphael Sanzio',
  'Titian', 'Tiziano', 'Tiziano Vecellio', 'Vecellio',
  'Jan van Eyck', 'van Eyck', 'Eyck',
  'Bruegel', 'Pieter Bruegel', 'Brueghel', 'Pieter Brueghel',
  'Dürer', 'Durer', 'Albrecht Dürer', 'Albrecht Durer',
  // バロック
  'Caravaggio', 'Merisi', 'Michelangelo Merisi',
  'Rembrandt', 'Rembrandt van Rijn', 'Rembrandt Harmensz',
  'Vermeer', 'Johannes Vermeer', 'Jan Vermeer',
  'Rubens', 'Peter Paul Rubens', 'Pieter Paul Rubens',
  'Velázquez', 'Velazquez', 'Diego Velázquez', 'Diego Velazquez', 'Rodriguez de Silva',
  'Georges de La Tour', 'La Tour', 'de La Tour',
  'Van Dyck', 'Anthony van Dyck', 'Antoon van Dyck',
  // ロココ
  'Watteau', 'Antoine Watteau', 'Jean-Antoine Watteau',
  'Boucher', 'François Boucher', 'Francois Boucher',
  'Fragonard', 'Jean-Honoré Fragonard', 'Jean-Honore Fragonard',
  // 新古典主義・ロマン主義
  'David', 'Jacques-Louis David', 'Jacques Louis David',
  'Ingres', 'Jean-Auguste-Dominique Ingres',
  'Géricault', 'Gericault', 'Théodore Géricault', 'Theodore Gericault',
  'Delacroix', 'Eugène Delacroix', 'Eugene Delacroix',
  'Goya', 'Francisco de Goya', 'Francisco Goya',
  // 写実主義・バルビゾン派
  'Courbet', 'Gustave Courbet',
  'Millet', 'Jean-François Millet', 'Jean-Francois Millet',
  'Corot', 'Camille Corot', 'Jean-Baptiste-Camille Corot',
  // 印象派
  'Manet', 'Édouard Manet', 'Edouard Manet',
  'Monet', 'Claude Monet',
  'Renoir', 'Pierre-Auguste Renoir', 'Auguste Renoir',
  'Degas', 'Edgar Degas', 'Hilaire-Germain-Edgar Degas',
  'Pissarro', 'Camille Pissarro', 'Jacob Pissarro',
  'Sisley', 'Alfred Sisley',
  'Morisot', 'Berthe Morisot',
  // 新印象派・後期印象派
  'Seurat', 'Georges Seurat', 'Georges-Pierre Seurat',
  'Signac', 'Paul Signac',
  'Cézanne', 'Cezanne', 'Paul Cézanne', 'Paul Cezanne',
  'Van Gogh', 'van Gogh', 'Vincent van Gogh', 'Vincent Willem van Gogh',
  'Gauguin', 'Paul Gauguin', 'Eugène Henri Paul Gauguin',
  'Toulouse-Lautrec', 'Henri de Toulouse-Lautrec', 'Lautrec',
  // 象徴主義・世紀末
  'Klimt', 'Gustav Klimt',
  'Munch', 'Edvard Munch',
  'Redon', 'Odilon Redon',
  'Moreau', 'Gustave Moreau',
  // 20世紀
  'Picasso', 'Pablo Picasso', 'Pablo Ruiz Picasso',
  'Matisse', 'Henri Matisse', 'Henri-Émile-Benoît Matisse',
  'Kandinsky', 'Wassily Kandinsky', 'Vasily Kandinsky',
  'Mondrian', 'Piet Mondrian', 'Pieter Mondriaan',
  'Dalí', 'Dali', 'Salvador Dalí', 'Salvador Dali',
  'Chagall', 'Marc Chagall',
  'Warhol', 'Andy Warhol',
  'Pollock', 'Jackson Pollock',
  // 日本美術 - 浮世絵
  'Hokusai', 'Katsushika Hokusai', '北斎', '葛飾北斎',
  'Hiroshige', 'Utagawa Hiroshige', 'Ando Hiroshige', '広重', '歌川広重',
  'Utamaro', 'Kitagawa Utamaro', '歌麿', '喜多川歌麿',
  'Sharaku', 'Tōshūsai Sharaku', 'Toshusai Sharaku', '写楽', '東洲斎写楽',
  'Moronobu', 'Hishikawa Moronobu', '師宣', '菱川師宣',
  'Harunobu', 'Suzuki Harunobu', '春信', '鈴木春信',
  'Kuniyoshi', 'Utagawa Kuniyoshi', '国芳', '歌川国芳',
  // 日本美術 - 琳派
  'Sotatsu', 'Tawaraya Sōtatsu', 'Tawaraya Sotatsu', '宗達', '俵屋宗達',
  'Korin', 'Ogata Kōrin', 'Ogata Korin', '光琳', '尾形光琳',
  'Hoitsu', 'Sakai Hōitsu', 'Sakai Hoitsu', '抱一', '酒井抱一',
  // 日本美術 - 狩野派・その他
  'Sesshū', 'Sesshu', '雪舟',
  'Eitoku', 'Kanō Eitoku', 'Kano Eitoku', '永徳', '狩野永徳',
  'Tohaku', 'Hasegawa Tōhaku', 'Hasegawa Tohaku', '等伯', '長谷川等伯',
  'Jakuchu', 'Itō Jakuchū', 'Ito Jakuchu', '若冲', '伊藤若冲',
  'Okyo', 'Maruyama Ōkyo', 'Maruyama Okyo', '応挙', '円山応挙',
  // 近代日本画
  'Taikan', 'Yokoyama Taikan', '大観', '横山大観',
  'Shunso', 'Hishida Shunsō', 'Hishida Shunso', '春草', '菱田春草',
  'Shoen', 'Uemura Shōen', 'Uemura Shoen', '松園', '上村松園',
  'Seiho', 'Takeuchi Seihō', 'Takeuchi Seiho', '栖鳳', '竹内栖鳳',
  'Kaii', 'Higashiyama Kaii', '魁夷', '東山魁夷',
  // 近代洋画
  'Kuroda Seiki', '黒田清輝',
  'Fujishima Takeji', '藤島武二',
  'Aoki Shigeru', '青木繁',
  'Ryusei', 'Kishida Ryūsei', 'Kishida Ryusei', '劉生', '岸田劉生',
];

/**
 * 作家名が日本語マッピングに存在するかチェック
 */
export function hasJapaneseMapping(artistName: string): boolean {
  if (!artistName || artistName.trim() === '') return false;

  // 作者不詳系は除外
  const unknownPatterns = ['unknown', 'anonymous', 'unidentified', 'attributed'];
  const lowerName = artistName.toLowerCase();
  if (unknownPatterns.some(pattern => lowerName.includes(pattern))) {
    return false;
  }

  return MAPPED_ARTISTS.some(mapped => {
    const mappedLower = mapped.toLowerCase();
    // 完全一致、部分一致、または名前の一部が含まれているかチェック
    return lowerName.includes(mappedLower) ||
           mappedLower.includes(lowerName) ||
           lowerName.split(/[\s,()]+/).some(part => part.length > 3 && mappedLower.includes(part));
  });
}

/**
 * 部門名から時代（Era）を推定
 */
function detectEra(artwork: MetArtworkResponse): Era {
  const { department, period, culture, objectDate, classification } = artwork;
  const text = `${department} ${period} ${culture} ${objectDate} ${classification}`.toLowerCase();

  // 日本美術
  if (
    text.includes('japan') ||
    text.includes('ukiyo') ||
    text.includes('edo') ||
    culture?.toLowerCase().includes('japan')
  ) {
    return 'Japanese Art';
  }

  // ルネサンス
  if (
    text.includes('renaissance') ||
    text.includes('15th century') ||
    text.includes('16th century') ||
    (artwork.objectBeginDate >= 1400 && artwork.objectEndDate <= 1600)
  ) {
    return 'Renaissance';
  }

  // バロック
  if (
    text.includes('baroque') ||
    text.includes('17th century') ||
    (artwork.objectBeginDate >= 1600 && artwork.objectEndDate <= 1750)
  ) {
    return 'Baroque';
  }

  // 印象派
  if (
    text.includes('impressionist') ||
    text.includes('impressionism') ||
    text.includes('post-impressionist') ||
    (artwork.objectBeginDate >= 1860 && artwork.objectEndDate <= 1910)
  ) {
    return 'Impressionism';
  }

  // 近代美術
  if (
    text.includes('modern') ||
    text.includes('20th century') ||
    text.includes('contemporary') ||
    artwork.objectBeginDate >= 1900
  ) {
    return 'Modern Art';
  }

  // デフォルト
  return 'Renaissance';
}

/**
 * 難易度を推定
 */
function detectDifficulty(artwork: MetArtworkResponse): 'Easy' | 'Medium' | 'Hard' {
  // ハイライト作品は有名なので易しい
  if (artwork.isHighlight) {
    return 'Easy';
  }

  // 有名な作家は易しい
  const famousArtists = [
    'van gogh', 'monet', 'rembrandt', 'vermeer', 'da vinci', 'leonardo',
    'michelangelo', 'picasso', 'hokusai', 'hiroshige', 'botticelli',
    'raphael', 'caravaggio', 'renoir', 'cezanne', 'klimt', 'matisse'
  ];

  const artistName = artwork.artistDisplayName?.toLowerCase() || '';
  if (famousArtists.some(name => artistName.includes(name))) {
    return 'Easy';
  }

  // それ以外は中〜難
  return Math.random() > 0.5 ? 'Medium' : 'Hard';
}

/**
 * 日本語の作品タイトルを生成（既知の作品のみ）
 * 美術検定4級の頻出作品を網羅
 */
function getJapaneseTitle(title: string, artistName: string): string | undefined {
  const titleMap: Record<string, string> = {
    // ルネサンス
    'The Birth of Venus': 'ヴィーナスの誕生',
    'Birth of Venus': 'ヴィーナスの誕生',
    'Primavera': 'プリマヴェーラ（春）',
    'La Primavera': 'プリマヴェーラ（春）',
    'Mona Lisa': 'モナ・リザ',
    'The Last Supper': '最後の晩餐',
    'Last Supper': '最後の晩餐',
    'The Last Judgment': '最後の審判',
    'Last Judgment': '最後の審判',
    'David': 'ダヴィデ像',
    'The School of Athens': 'アテネの学堂',
    'School of Athens': 'アテネの学堂',
    'Venus of Urbino': 'ウルヴィーノのヴィーナス',
    'The Arnolfini Portrait': 'アルノルフィーニ夫妻像',
    'Arnolfini Portrait': 'アルノルフィーニ夫妻像',
    'The Tower of Babel': 'バベルの塔',
    'Tower of Babel': 'バベルの塔',
    'Hunters in the Snow': '雪中の狩人',

    // バロック
    'The Calling of Saint Matthew': '聖マタイの召命',
    'Calling of Saint Matthew': '聖マタイの召命',
    'The Night Watch': '夜警',
    'Night Watch': '夜警',
    'The Anatomy Lesson of Dr. Nicolaes Tulp': 'テュルプ博士の解剖学講義',
    'Girl with a Pearl Earring': '真珠の耳飾りの少女',
    'The Milkmaid': '牛乳を注ぐ女',
    'Milkmaid': '牛乳を注ぐ女',
    'View of Delft': 'デルフトの眺望',
    'The Elevation of the Cross': 'キリスト昇架',
    'The Descent from the Cross': 'キリスト降架',
    'Las Meninas': 'ラス・メニーナス（女官たち）',
    'The Embarkation for Cythera': 'シテール島への巡礼',
    'The Swing': 'ぶらんこ',

    // 新古典主義・ロマン主義
    'The Coronation of Napoleon': 'ナポレオンの戴冠式',
    'Coronation of Napoleon': 'ナポレオンの戴冠式',
    'The Death of Marat': 'マラーの死',
    'Death of Marat': 'マラーの死',
    'Oath of the Horatii': 'ホラティウス兄弟の誓い',
    'Grande Odalisque': 'グランド・オダリスク',
    'The Source': '泉',
    'La Source': '泉',
    'The Raft of the Medusa': 'メデュース号の筏',
    'Raft of the Medusa': 'メデュース号の筏',
    'Liberty Leading the People': '民衆を導く自由の女神',
    'The Nude Maja': '裸のマハ',
    'The Clothed Maja': '着衣のマハ',
    'Saturn Devouring His Son': '我が子を食らうサトゥルヌス',

    // 写実主義・バルビゾン派
    'A Burial at Ornans': 'オルナンの埋葬',
    'Burial at Ornans': 'オルナンの埋葬',
    'The Gleaners': '落穂拾い',
    'Gleaners': '落穂拾い',
    'The Angelus': '晩鐘',
    'Angelus': '晩鐘',
    'The Sower': '種まく人',

    // 印象派
    'Luncheon on the Grass': '草上の昼食',
    'Le Déjeuner sur l\'herbe': '草上の昼食',
    'Olympia': 'オランピア',
    'A Bar at the Folies-Bergère': 'フォリー・ベルジェールのバー',
    'Impression, Sunrise': '印象・日の出',
    'Impression Sunrise': '印象・日の出',
    'Water Lilies': '睡蓮',
    'Waterlilies': '睡蓮',
    'La Japonaise': 'ラ・ジャポネーズ',
    'Haystacks': '積みわら',
    'Bal du moulin de la Galette': 'ムーラン・ド・ラ・ギャレットの舞踏会',
    'Dance at Le Moulin de la Galette': 'ムーラン・ド・ラ・ギャレットの舞踏会',
    'Luncheon of the Boating Party': '舟遊びの昼食',
    'The Dance Class': '踊り子',
    'The Star': 'エトワール',
    'L\'Étoile': 'エトワール',
    'The Cradle': 'ゆりかご',

    // 新印象派・後期印象派
    'A Sunday Afternoon on the Island of La Grande Jatte': 'グランド・ジャット島の日曜日の午後',
    'Sunday Afternoon on the Island of La Grande Jatte': 'グランド・ジャット島の日曜日の午後',
    'Mont Sainte-Victoire': 'サント・ヴィクトワール山',
    'The Card Players': 'カード遊びをする人々',
    'Apples and Oranges': 'リンゴとオレンジのある静物',
    'Sunflowers': 'ひまわり',
    'Starry Night': '星月夜',
    'The Starry Night': '星月夜',
    'Café Terrace at Night': '夜のカフェテラス',
    'Self-Portrait': '自画像',
    'Bedroom in Arles': 'アルルの寝室',
    'Where Do We Come From? What Are We? Where Are We Going?': '我々はどこから来たのか 我々は何者か 我々はどこへ行くのか',
    'Tahitian Women': 'タヒチの女たち',
    'At the Moulin Rouge': 'ムーラン・ルージュにて',

    // 象徴主義・世紀末
    'The Kiss': '接吻',
    'Kiss': '接吻',
    'Judith': 'ユディト',
    'The Scream': '叫び',
    'Scream': '叫び',

    // 20世紀
    'Guernica': 'ゲルニカ',
    'Les Demoiselles d\'Avignon': 'アヴィニョンの娘たち',
    'The Weeping Woman': '泣く女',
    'The Dance': 'ダンス',
    'Dance': 'ダンス',
    'The Red Room': '赤い部屋',
    'Composition': 'コンポジション',
    'The Persistence of Memory': '記憶の固執',
    'I and the Village': '私と村',

    // 日本美術 - 浮世絵
    'The Great Wave off Kanagawa': '神奈川沖浪裏',
    'Under the Wave off Kanagawa': '神奈川沖浪裏',
    'Great Wave': '神奈川沖浪裏',
    'Fine Wind, Clear Morning': '凱風快晴（赤富士）',
    'South Wind, Clear Sky': '凱風快晴（赤富士）',
    'Thirty-six Views of Mount Fuji': '富嶽三十六景',
    'Fifty-three Stations of the Tōkaidō': '東海道五十三次',
    'One Hundred Famous Views of Edo': '名所江戸百景',
    'Beauty Looking Back': '見返り美人図',
    'Three Beauties of the Present Day': '寛政三美人',

    // 日本美術 - 琳派・その他
    'Wind God and Thunder God': '風神雷神図屏風',
    'Irises': '燕子花図屏風',
    'Red and White Plum Blossoms': '紅白梅図屏風',
    'Summer and Autumn Grasses': '夏秋草図屏風',
    'Pine Trees': '松林図屏風',
  };

  // 完全一致
  if (titleMap[title]) {
    return titleMap[title];
  }

  // 部分一致（長いキーから優先的にマッチ）
  const sortedKeys = Object.keys(titleMap).sort((a, b) => b.length - a.length);
  for (const key of sortedKeys) {
    if (title.toLowerCase().includes(key.toLowerCase())) {
      return titleMap[key];
    }
  }

  return undefined;
}

/**
 * 日本語の作家名を生成
 * 美術検定4級の頻出作家を網羅
 */
function getJapaneseArtistName(artistName: string): string {
  const artistMap: Record<string, string> = {
    // ルネサンス
    'Sandro Botticelli': 'サンドロ・ボッティチェッリ',
    'Botticelli': 'サンドロ・ボッティチェッリ',
    'Leonardo da Vinci': 'レオナルド・ダ・ヴィンチ',
    'Leonardo': 'レオナルド・ダ・ヴィンチ',
    'Michelangelo': 'ミケランジェロ・ブオナローティ',
    'Michelangelo Buonarroti': 'ミケランジェロ・ブオナローティ',
    'Raphael': 'ラファエロ・サンティ',
    'Raffaello': 'ラファエロ・サンティ',
    'Titian': 'ティツィアーノ・ヴェチェッリオ',
    'Tiziano': 'ティツィアーノ・ヴェチェッリオ',
    'Jan van Eyck': 'ヤン・ファン・エイク',
    'Pieter Bruegel': 'ピーテル・ブリューゲル',
    'Bruegel': 'ピーテル・ブリューゲル',
    'Albrecht Dürer': 'アルブレヒト・デューラー',
    'Dürer': 'アルブレヒト・デューラー',
    'Durer': 'アルブレヒト・デューラー',

    // バロック
    'Caravaggio': 'カラヴァッジョ',
    'Rembrandt': 'レンブラント・ファン・レイン',
    'Rembrandt van Rijn': 'レンブラント・ファン・レイン',
    'Johannes Vermeer': 'ヨハネス・フェルメール',
    'Vermeer': 'ヨハネス・フェルメール',
    'Peter Paul Rubens': 'ピーテル・パウル・ルーベンス',
    'Rubens': 'ピーテル・パウル・ルーベンス',
    'Diego Velázquez': 'ディエゴ・ベラスケス',
    'Velázquez': 'ディエゴ・ベラスケス',
    'Velazquez': 'ディエゴ・ベラスケス',
    'Georges de La Tour': 'ジョルジュ・ド・ラ・トゥール',
    'Anthony van Dyck': 'アンソニー・ヴァン・ダイク',
    'Van Dyck': 'アンソニー・ヴァン・ダイク',

    // ロココ
    'Antoine Watteau': 'アントワーヌ・ヴァトー',
    'Watteau': 'アントワーヌ・ヴァトー',
    'François Boucher': 'フランソワ・ブーシェ',
    'Boucher': 'フランソワ・ブーシェ',
    'Jean-Honoré Fragonard': 'ジャン・オノレ・フラゴナール',
    'Fragonard': 'ジャン・オノレ・フラゴナール',

    // 新古典主義・ロマン主義
    'Jacques-Louis David': 'ジャック＝ルイ・ダヴィッド',
    'David': 'ジャック＝ルイ・ダヴィッド',
    'Jean-Auguste-Dominique Ingres': 'ドミニク・アングル',
    'Ingres': 'ドミニク・アングル',
    'Théodore Géricault': 'テオドール・ジェリコー',
    'Géricault': 'テオドール・ジェリコー',
    'Gericault': 'テオドール・ジェリコー',
    'Eugène Delacroix': 'ウジェーヌ・ドラクロワ',
    'Delacroix': 'ウジェーヌ・ドラクロワ',
    'Francisco de Goya': 'フランシスコ・デ・ゴヤ',
    'Goya': 'フランシスコ・デ・ゴヤ',

    // 写実主義・バルビゾン派
    'Gustave Courbet': 'ギュスターヴ・クールベ',
    'Courbet': 'ギュスターヴ・クールベ',
    'Jean-François Millet': 'ジャン＝フランソワ・ミレー',
    'Millet': 'ジャン＝フランソワ・ミレー',
    'Camille Corot': 'カミーユ・コロー',
    'Corot': 'カミーユ・コロー',

    // 印象派
    'Édouard Manet': 'エドゥアール・マネ',
    'Edouard Manet': 'エドゥアール・マネ',
    'Manet': 'エドゥアール・マネ',
    'Claude Monet': 'クロード・モネ',
    'Monet': 'クロード・モネ',
    'Pierre-Auguste Renoir': 'ピエール＝オーギュスト・ルノワール',
    'Renoir': 'ピエール＝オーギュスト・ルノワール',
    'Edgar Degas': 'エドガー・ドガ',
    'Degas': 'エドガー・ドガ',
    'Camille Pissarro': 'カミーユ・ピサロ',
    'Pissarro': 'カミーユ・ピサロ',
    'Alfred Sisley': 'アルフレッド・シスレー',
    'Sisley': 'アルフレッド・シスレー',
    'Berthe Morisot': 'ベルト・モリゾ',
    'Morisot': 'ベルト・モリゾ',

    // 新印象派・後期印象派
    'Georges Seurat': 'ジョルジュ・スーラ',
    'Seurat': 'ジョルジュ・スーラ',
    'Paul Signac': 'ポール・シニャック',
    'Signac': 'ポール・シニャック',
    'Paul Cézanne': 'ポール・セザンヌ',
    'Cézanne': 'ポール・セザンヌ',
    'Cezanne': 'ポール・セザンヌ',
    'Vincent van Gogh': 'フィンセント・ファン・ゴッホ',
    'Van Gogh': 'フィンセント・ファン・ゴッホ',
    'van Gogh': 'フィンセント・ファン・ゴッホ',
    'Paul Gauguin': 'ポール・ゴーギャン',
    'Gauguin': 'ポール・ゴーギャン',
    'Henri de Toulouse-Lautrec': 'アンリ・ド・トゥールーズ＝ロートレック',
    'Toulouse-Lautrec': 'アンリ・ド・トゥールーズ＝ロートレック',

    // 象徴主義・世紀末美術
    'Gustav Klimt': 'グスタフ・クリムト',
    'Klimt': 'グスタフ・クリムト',
    'Edvard Munch': 'エドヴァルド・ムンク',
    'Munch': 'エドヴァルド・ムンク',
    'Odilon Redon': 'オディロン・ルドン',
    'Redon': 'オディロン・ルドン',
    'Gustave Moreau': 'ギュスターヴ・モロー',
    'Moreau': 'ギュスターヴ・モロー',

    // 20世紀美術
    'Pablo Picasso': 'パブロ・ピカソ',
    'Picasso': 'パブロ・ピカソ',
    'Henri Matisse': 'アンリ・マティス',
    'Matisse': 'アンリ・マティス',
    'Wassily Kandinsky': 'ワシリー・カンディンスキー',
    'Kandinsky': 'ワシリー・カンディンスキー',
    'Piet Mondrian': 'ピート・モンドリアン',
    'Mondrian': 'ピート・モンドリアン',
    'Salvador Dalí': 'サルバドール・ダリ',
    'Salvador Dali': 'サルバドール・ダリ',
    'Dalí': 'サルバドール・ダリ',
    'Dali': 'サルバドール・ダリ',
    'Marc Chagall': 'マルク・シャガール',
    'Chagall': 'マルク・シャガール',
    'Andy Warhol': 'アンディ・ウォーホル',
    'Warhol': 'アンディ・ウォーホル',
    'Jackson Pollock': 'ジャクソン・ポロック',
    'Pollock': 'ジャクソン・ポロック',

    // 日本美術 - 浮世絵
    'Katsushika Hokusai': '葛飾北斎',
    'Hokusai': '葛飾北斎',
    'Utagawa Hiroshige': '歌川広重',
    'Hiroshige': '歌川広重',
    'Kitagawa Utamaro': '喜多川歌麿',
    'Utamaro': '喜多川歌麿',
    'Tōshūsai Sharaku': '東洲斎写楽',
    'Sharaku': '東洲斎写楽',
    'Hishikawa Moronobu': '菱川師宣',
    'Moronobu': '菱川師宣',
    'Suzuki Harunobu': '鈴木春信',
    'Harunobu': '鈴木春信',
    'Utagawa Kuniyoshi': '歌川国芳',
    'Kuniyoshi': '歌川国芳',

    // 日本美術 - 琳派
    'Tawaraya Sōtatsu': '俵屋宗達',
    'Sotatsu': '俵屋宗達',
    'Ogata Kōrin': '尾形光琳',
    'Korin': '尾形光琳',
    'Sakai Hōitsu': '酒井抱一',
    'Hoitsu': '酒井抱一',

    // 日本美術 - 狩野派・その他
    'Sesshū': '雪舟',
    'Sesshu': '雪舟',
    'Kanō Eitoku': '狩野永徳',
    'Kano Eitoku': '狩野永徳',
    'Hasegawa Tōhaku': '長谷川等伯',
    'Tohaku': '長谷川等伯',
    'Itō Jakuchū': '伊藤若冲',
    'Ito Jakuchu': '伊藤若冲',
    'Jakuchu': '伊藤若冲',
    'Maruyama Ōkyo': '円山応挙',
    'Okyo': '円山応挙',

    // 近代日本画
    'Yokoyama Taikan': '横山大観',
    'Taikan': '横山大観',
    'Hishida Shunsō': '菱田春草',
    'Shunso': '菱田春草',
    'Uemura Shōen': '上村松園',
    'Shoen': '上村松園',
    'Takeuchi Seihō': '竹内栖鳳',
    'Seiho': '竹内栖鳳',
    'Higashiyama Kaii': '東山魁夷',
    'Kaii': '東山魁夷',

    // 近代洋画
    'Kuroda Seiki': '黒田清輝',
    'Fujishima Takeji': '藤島武二',
    'Aoki Shigeru': '青木繁',
    'Kishida Ryūsei': '岸田劉生',
    'Ryusei': '岸田劉生',
  };

  // 完全一致
  if (artistMap[artistName]) {
    return artistMap[artistName];
  }

  // 部分一致（長いキーから優先的にマッチ）
  const sortedKeys = Object.keys(artistMap).sort((a, b) => b.length - a.length);
  for (const key of sortedKeys) {
    if (artistName.toLowerCase().includes(key.toLowerCase())) {
      return artistMap[key];
    }
  }

  return artistName;
}

/**
 * MetArtworkResponseをArtwork型に変換
 */
export function convertMetArtworkToArtwork(metArtwork: MetArtworkResponse): Artwork {
  const era = detectEra(metArtwork);
  const difficulty = detectDifficulty(metArtwork);
  const artistJa = getJapaneseArtistName(metArtwork.artistDisplayName || '作者不詳');
  const titleJa = getJapaneseTitle(metArtwork.title, metArtwork.artistDisplayName);

  return {
    id: metArtwork.objectID.toString(),
    title: titleJa || metArtwork.title,
    titleJa,
    artist: artistJa,
    artistJa,
    year: metArtwork.objectBeginDate || parseInt(metArtwork.objectDate) || 0,
    medium: metArtwork.medium || '不明',
    movement: metArtwork.classification || metArtwork.department || '',
    era,
    imageUrl: metArtwork.primaryImage || metArtwork.primaryImageSmall,
    description: `${metArtwork.title}は${metArtwork.artistDisplayName || '作者不詳'}による作品です。${metArtwork.medium ? `技法は${metArtwork.medium}。` : ''}${metArtwork.dimensions ? `サイズは${metArtwork.dimensions}。` : ''}現在${metArtwork.creditLine || 'メトロポリタン美術館'}に所蔵されています。`,
    artistBio: metArtwork.artistDisplayBio || undefined,
    difficulty,
    correctRate: difficulty === 'Easy' ? 80 : difficulty === 'Medium' ? 60 : 40,
  };
}

/**
 * 複数の作品を変換
 * 日本語マッピングが存在する作家の作品のみを返す
 * 重複を除去する
 */
export function convertMetArtworks(metArtworks: MetArtworkResponse[]): Artwork[] {
  // 重複を除去（objectIDでユニーク化）
  const uniqueArtworks = metArtworks.filter((artwork, index, self) =>
    index === self.findIndex(a => a.objectID === artwork.objectID)
  );

  return uniqueArtworks
    .filter(artwork => artwork.primaryImage || artwork.primaryImageSmall)
    .filter(artwork => hasJapaneseMapping(artwork.artistDisplayName))
    .map(convertMetArtworkToArtwork);
}

/**
 * クイズ問題を生成
 */
export function generateQuizFromArtworks(
  artworks: Artwork[],
  count: number = 10
): QuizQuestion[] {
  if (artworks.length < 4) {
    throw new Error('クイズを生成するには最低4つの作品が必要です');
  }

  const shuffled = [...artworks].sort(() => Math.random() - 0.5);
  const selected = shuffled.slice(0, Math.min(count, shuffled.length));

  return selected.map((artwork, index) => {
    // 他の作家を選択肢に使用
    const otherArtists = artworks
      .filter(a => a.artist !== artwork.artist)
      .map(a => a.artist)
      .filter((v, i, a) => a.indexOf(v) === i) // 重複削除
      .sort(() => Math.random() - 0.5)
      .slice(0, 3);

    // 選択肢が足りない場合はダミーを追加
    while (otherArtists.length < 3) {
      const dummyArtists = ['作者不詳', '匿名の画家', '不明な作家'];
      otherArtists.push(dummyArtists[otherArtists.length]);
    }

    const options = [artwork.artist, ...otherArtists].sort(() => Math.random() - 0.5);

    return {
      id: `q-${index}-${artwork.id}`,
      artwork,
      questionType: 'artist' as const,
      question: 'この作品の作者は誰でしょう？',
      options,
      correctAnswer: artwork.artist,
    };
  });
}
