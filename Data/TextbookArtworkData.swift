import Foundation

struct TextbookArtwork: Identifiable, Sendable, Equatable {
    let id: String
    let number: Int
    let titleJa: String
    let artist: String
    let artistEn: String
    let periodJa: String
    let wikiTitle: String?
    let wikiLang: String

    init(id: String, number: Int, titleJa: String, artist: String, artistEn: String, periodJa: String,
         wikiTitle: String? = nil, wikiLang: String = "en") {
        self.id = id
        self.number = number
        self.titleJa = titleJa
        self.artist = artist
        self.artistEn = artistEn
        self.periodJa = periodJa
        self.wikiTitle = wikiTitle
        self.wikiLang = wikiLang
    }
}

extension TextbookArtwork {
    var era: Era {
        switch periodJa {
        case "プロト・ルネサンス", "ルネサンス", "マニエリスム":
            return .renaissance
        case "バロック", "ロココ", "新古典主義":
            return .baroque
        case "ロマン主義", "写実主義", "ラファエル前派", "印象派", "新印象派", "後期印象派":
            return .impressionism
        case "象徴主義", "キュビスム", "ナイーフ・アート", "抽象表現主義",
             "形而上絵画", "シュルレアリスム", "抽象絵画", "20世紀":
            return .modernArt
        case "ポップアート":
            return .contemporary
        case "飛鳥時代", "平安時代", "平安〜鎌倉時代", "室町時代", "桃山時代", "江戸時代",
             "明治時代", "大正時代", "昭和時代", "明治〜昭和時代", "大正〜昭和時代":
            return .japaneseArt
        default:
            assertionFailure("Unknown periodJa: \(periodJa) — add mapping to TextbookArtwork.era")
            return .contemporary
        }
    }

    func asArtwork(imageURL: URL? = nil) -> Artwork {
        Artwork(
            id: id,
            title: titleJa,
            titleJa: titleJa,
            artist: artist,
            artistJa: artist,
            artistOriginal: artistEn,
            year: nil,
            medium: "",
            movement: periodJa,
            era: era,
            imageURL: imageURL,
            description: "『\(titleJa)』は\(artist)による\(periodJa)の作品です。",
            artistBio: nil,
            difficulty: .medium
        )
    }
}

enum TextbookArtworkData {
    static let all: [TextbookArtwork] = [
        // ── 西洋美術 001-060 ──────────────────────────────────────────────────
        .init(id: "textbook-001",  number: 1,   titleJa: "ユダの接吻",
              artist: "ジョット・ディ・ボンドーネ",             artistEn: "Giotto di Bondone",
              periodJa: "プロト・ルネサンス",
              wikiTitle: "Kiss of Judas (Giotto)"),

        .init(id: "textbook-002",  number: 2,   titleJa: "アルノルフィーニ夫妻の肖像",
              artist: "ヤン・ファン・エイク",                   artistEn: "Jan van Eyck",
              periodJa: "ルネサンス",
              wikiTitle: "Arnolfini Portrait"),

        .init(id: "textbook-003",  number: 3,   titleJa: "春（プリマヴェーラ）",
              artist: "サンドロ・ボッティチェリ",               artistEn: "Sandro Botticelli",
              periodJa: "ルネサンス",
              wikiTitle: "Primavera (Botticelli)"),

        .init(id: "textbook-004",  number: 4,   titleJa: "ヴィーナスの誕生",
              artist: "サンドロ・ボッティチェリ",               artistEn: "Sandro Botticelli",
              periodJa: "ルネサンス",
              wikiTitle: "The Birth of Venus"),

        .init(id: "textbook-005",  number: 5,   titleJa: "最後の晩餐",
              artist: "レオナルド・ダ・ヴィンチ",               artistEn: "Leonardo da Vinci",
              periodJa: "ルネサンス",
              wikiTitle: "The Last Supper (Leonardo da Vinci)"),

        .init(id: "textbook-006",  number: 6,   titleJa: "自画像",
              artist: "アルブレヒト・デューラー",               artistEn: "Albrecht Dürer",
              periodJa: "ルネサンス",
              wikiTitle: "Self-portrait (Dürer, 1500)"),

        .init(id: "textbook-007",  number: 7,   titleJa: "モナ・リザ",
              artist: "レオナルド・ダ・ヴィンチ",               artistEn: "Leonardo da Vinci",
              periodJa: "ルネサンス",
              wikiTitle: "Mona Lisa"),

        .init(id: "textbook-008",  number: 8,   titleJa: "快楽の園",
              artist: "ヒエロニムス・ボス",                     artistEn: "Hieronymus Bosch",
              periodJa: "ルネサンス",
              wikiTitle: "The Garden of Earthly Delights"),

        .init(id: "textbook-009",  number: 9,   titleJa: "アテネの学堂",
              artist: "ラファエロ・サンティ",                   artistEn: "Raphael",
              periodJa: "ルネサンス",
              wikiTitle: "The School of Athens"),

        .init(id: "textbook-010",  number: 10,  titleJa: "小椅子の聖母",
              artist: "ラファエロ・サンティ",                   artistEn: "Raphael",
              periodJa: "ルネサンス",
              wikiTitle: "Madonna della seggiola"),

        .init(id: "textbook-011",  number: 11,  titleJa: "最後の審判",
              artist: "ミケランジェロ・ブオナローティ",         artistEn: "Michelangelo",
              periodJa: "ルネサンス",
              wikiTitle: "The Last Judgment (Michelangelo)"),

        .init(id: "textbook-012",  number: 12,  titleJa: "ウルヴィーノのヴィーナス",
              artist: "ティツィアーノ・ヴェチェッリオ",         artistEn: "Titian",
              periodJa: "ルネサンス",
              wikiTitle: "Venus of Urbino"),

        .init(id: "textbook-013",  number: 13,  titleJa: "雪中の狩人",
              artist: "ピーテル・ブリューゲル",                 artistEn: "Pieter Bruegel",
              periodJa: "ルネサンス",
              wikiTitle: "Hunters in the Snow"),

        .init(id: "textbook-014",  number: 14,  titleJa: "受胎告知",
              artist: "エル・グレコ",                           artistEn: "El Greco",
              periodJa: "マニエリスム",
              wikiTitle: "The Annunciation (El Greco, Toledo)"),

        .init(id: "textbook-015",  number: 15,  titleJa: "聖母の死",
              artist: "カラヴァッジョ",                         artistEn: "Caravaggio",
              periodJa: "バロック",
              wikiTitle: "Death of the Virgin (Caravaggio)"),

        .init(id: "textbook-016",  number: 16,  titleJa: "マリー・ド・メディシスのマルセイユ上陸",
              artist: "ピーテル・パウル・ルーベンス",           artistEn: "Peter Paul Rubens",
              periodJa: "バロック",
              wikiTitle: "The Disembarkation at Marseilles"),

        .init(id: "textbook-017",  number: 17,  titleJa: "夜警",
              artist: "レンブラント・ファン・レイン",           artistEn: "Rembrandt",
              periodJa: "バロック",
              wikiTitle: "The Night Watch"),

        .init(id: "textbook-018",  number: 18,  titleJa: "ラス・メニーナス（女官たち）",
              artist: "ディエゴ・ベラスケス",                   artistEn: "Diego Velázquez",
              periodJa: "バロック",
              wikiTitle: "Las Meninas"),

        .init(id: "textbook-019",  number: 19,  titleJa: "真珠の耳飾りの少女",
              artist: "ヨハネス・フェルメール",                 artistEn: "Johannes Vermeer",
              periodJa: "バロック",
              wikiTitle: "Girl with a Pearl Earring"),

        .init(id: "textbook-020",  number: 20,  titleJa: "シテール島への巡礼",
              artist: "アントワーヌ・ヴァトー",                 artistEn: "Antoine Watteau",
              periodJa: "ロココ",
              wikiTitle: "The Embarkation for Cythera"),

        .init(id: "textbook-021",  number: 21,  titleJa: "マラーの死",
              artist: "ジャック＝ルイ・ダヴィッド",             artistEn: "Jacques-Louis David",
              periodJa: "新古典主義",
              wikiTitle: "The Death of Marat"),

        .init(id: "textbook-022",  number: 22,  titleJa: "裸のマハ",
              artist: "フランシスコ・デ・ゴヤ",                 artistEn: "Francisco de Goya",
              periodJa: "ロマン主義",
              wikiTitle: "La maja desnuda"),

        .init(id: "textbook-023",  number: 23,  titleJa: "グランド・オダリスク",
              artist: "ドミニク・アングル",                     artistEn: "Jean-Auguste-Dominique Ingres",
              periodJa: "新古典主義",
              wikiTitle: "La Grande Odalisque"),

        .init(id: "textbook-024",  number: 24,  titleJa: "マドリード、1808年5月3日",
              artist: "フランシスコ・デ・ゴヤ",                 artistEn: "Francisco de Goya",
              periodJa: "ロマン主義",
              wikiTitle: "The Third of May 1808"),

        .init(id: "textbook-025",  number: 25,  titleJa: "メデュース号の筏",
              artist: "テオドール・ジェリコー",                 artistEn: "Théodore Géricault",
              periodJa: "ロマン主義",
              wikiTitle: "The Raft of the Medusa"),

        .init(id: "textbook-026",  number: 26,  titleJa: "民衆を導く自由の女神",
              artist: "ウジェーヌ・ドラクロワ",                 artistEn: "Eugène Delacroix",
              periodJa: "ロマン主義",
              wikiTitle: "Liberty Leading the People"),

        .init(id: "textbook-027",  number: 27,  titleJa: "雨、蒸気、速力—グレート・ウェスタン鉄道",
              artist: "J.M.W. ターナー",                       artistEn: "J.M.W. Turner",
              periodJa: "ロマン主義",
              wikiTitle: "Rain, Steam and Speed – The Great Western Railway"),

        .init(id: "textbook-028",  number: 28,  titleJa: "種まく人",
              artist: "ジャン＝フランソワ・ミレー",             artistEn: "Jean-François Millet",
              periodJa: "写実主義",
              wikiTitle: "The Sower (Millet, 1850)"),

        .init(id: "textbook-029",  number: 29,  titleJa: "オフィーリア",
              artist: "ジョン・エヴァレット・ミレイ",           artistEn: "John Everett Millais",
              periodJa: "ラファエル前派",
              wikiTitle: "Ophelia (Millais painting)"),

        .init(id: "textbook-030",  number: 30,  titleJa: "画家のアトリエ",
              artist: "ギュスターヴ・クールベ",                 artistEn: "Gustave Courbet",
              periodJa: "写実主義",
              wikiTitle: "The Painter's Studio"),

        .init(id: "textbook-031",  number: 31,  titleJa: "草上の昼食",
              artist: "エドゥアール・マネ",                     artistEn: "Édouard Manet",
              periodJa: "印象派",
              wikiTitle: "Le Déjeuner sur l'herbe"),

        .init(id: "textbook-032",  number: 32,  titleJa: "オランピア",
              artist: "エドゥアール・マネ",                     artistEn: "Édouard Manet",
              periodJa: "印象派",
              wikiTitle: "Olympia (Manet)"),

        .init(id: "textbook-033",  number: 33,  titleJa: "真珠の女",
              artist: "カミーユ・コロー",                       artistEn: "Camille Corot",
              periodJa: "写実主義",
              wikiTitle: "Woman with a Pearl"),

        .init(id: "textbook-034",  number: 34,  titleJa: "印象・日の出",
              artist: "クロード・モネ",                         artistEn: "Claude Monet",
              periodJa: "印象派",
              wikiTitle: "Impression, Sunrise"),

        .init(id: "textbook-035",  number: 35,  titleJa: "アブサン（カフェにて）",
              artist: "エドガー・ドガ",                         artistEn: "Edgar Degas",
              periodJa: "印象派",
              wikiTitle: "L'Absinthe"),

        .init(id: "textbook-036",  number: 36,  titleJa: "エトワール（バレエの花形）",
              artist: "エドガー・ドガ",                         artistEn: "Edgar Degas",
              periodJa: "印象派",
              wikiTitle: "L'Étoile (Degas)"),

        .init(id: "textbook-037",  number: 37,  titleJa: "ムーラン・ド・ラ・ギャレットの舞踏会",
              artist: "ピエール＝オーギュスト・ルノワール",     artistEn: "Pierre-Auguste Renoir",
              periodJa: "印象派",
              wikiTitle: "Bal du moulin de la Galette"),

        .init(id: "textbook-038",  number: 38,  titleJa: "サント・ヴィクトワール山",
              artist: "ポール・セザンヌ",                       artistEn: "Paul Cézanne",
              periodJa: "後期印象派",
              wikiTitle: "Mont Sainte-Victoire (Cézanne)"),

        .init(id: "textbook-039",  number: 39,  titleJa: "グランド・ジャット島の日曜日の午後",
              artist: "ジョルジュ・スーラ",                     artistEn: "Georges Seurat",
              periodJa: "新印象派",
              wikiTitle: "A Sunday on La Grande Jatte"),

        .init(id: "textbook-040",  number: 40,  titleJa: "ひまわり",
              artist: "フィンセント・ファン・ゴッホ",           artistEn: "Vincent van Gogh",
              periodJa: "後期印象派",
              wikiTitle: "Sunflowers (Van Gogh series)"),

        .init(id: "textbook-041",  number: 41,  titleJa: "アルルの寝室",
              artist: "フィンセント・ファン・ゴッホ",           artistEn: "Vincent van Gogh",
              periodJa: "後期印象派",
              wikiTitle: "Bedroom in Arles"),

        .init(id: "textbook-042",  number: 42,  titleJa: "タヒチの女たち",
              artist: "ポール・ゴーギャン",                     artistEn: "Paul Gauguin",
              periodJa: "後期印象派",
              wikiTitle: "Tahitian Women (On the Beach)"),

        .init(id: "textbook-043",  number: 43,  titleJa: "ムーラン・ルージュ",
              artist: "アンリ・ド・トゥールーズ＝ロートレック", artistEn: "Henri de Toulouse-Lautrec",
              periodJa: "後期印象派",
              wikiTitle: "At the Moulin Rouge"),

        .init(id: "textbook-044",  number: 44,  titleJa: "叫び",
              artist: "エドヴァルド・ムンク",                   artistEn: "Edvard Munch",
              periodJa: "象徴主義",
              wikiTitle: "The Scream"),

        .init(id: "textbook-045",  number: 45,  titleJa: "接吻",
              artist: "グスタフ・クリムト",                     artistEn: "Gustav Klimt",
              periodJa: "象徴主義",
              wikiTitle: "The Kiss (Klimt)"),

        .init(id: "textbook-046",  number: 46,  titleJa: "アヴィニョンの娘たち",
              artist: "パブロ・ピカソ",                         artistEn: "Pablo Picasso",
              periodJa: "キュビスム",
              wikiTitle: "Les Demoiselles d'Avignon"),

        .init(id: "textbook-047",  number: 47,  titleJa: "夢",
              artist: "アンリ・ルソー",                         artistEn: "Henri Rousseau",
              periodJa: "ナイーフ・アート",
              wikiTitle: "The Dream (Rousseau)"),

        .init(id: "textbook-048",  number: 48,  titleJa: "階段を降りる裸体 No.2",
              artist: "マルセル・デュシャン",                   artistEn: "Marcel Duchamp",
              periodJa: "キュビスム",
              wikiTitle: "Nude Descending a Staircase, No. 2"),

        .init(id: "textbook-049",  number: 49,  titleJa: "コンポジション VII",
              artist: "ワシリー・カンディンスキー",             artistEn: "Wassily Kandinsky",
              periodJa: "抽象表現主義",
              wikiTitle: "Composition VII"),

        .init(id: "textbook-050",  number: 50,  titleJa: "街の神秘と憂愁",
              artist: "ジョルジョ・デ・キリコ",                 artistEn: "Giorgio de Chirico",
              periodJa: "形而上絵画",
              wikiTitle: "Mystery and Melancholy of a Street"),

        .init(id: "textbook-051",  number: 51,  titleJa: "睡蓮",
              artist: "クロード・モネ",                         artistEn: "Claude Monet",
              periodJa: "印象派",
              wikiTitle: "Water Lilies (Monet series)"),

        .init(id: "textbook-052",  number: 52,  titleJa: "誕生日",
              artist: "マルク・シャガール",                     artistEn: "Marc Chagall",
              periodJa: "20世紀",
              wikiTitle: "Birthday (Chagall)"),

        .init(id: "textbook-053",  number: 53,  titleJa: "黄色いセーターを着たジャンヌ・エビュテルヌ",
              artist: "アメデオ・モディリアーニ",               artistEn: "Amedeo Modigliani",
              periodJa: "20世紀",
              wikiTitle: "Jeanne Hébuterne (in Yellow Sweater)"),

        .init(id: "textbook-054",  number: 54,  titleJa: "記憶の固執",
              artist: "サルバドール・ダリ",                     artistEn: "Salvador Dalí",
              periodJa: "シュルレアリスム",
              wikiTitle: "The Persistence of Memory"),

        .init(id: "textbook-055",  number: 55,  titleJa: "アド・パルナッスム",
              artist: "パウル・クレー",                         artistEn: "Paul Klee",
              periodJa: "20世紀",
              wikiTitle: "Ad Parnassum"),

        .init(id: "textbook-056",  number: 56,  titleJa: "聖顔（キリストの顔）",
              artist: "ジョルジュ・ルオー",                     artistEn: "Georges Rouault",
              periodJa: "20世紀"),

        .init(id: "textbook-057",  number: 57,  titleJa: "ゲルニカ",
              artist: "パブロ・ピカソ",                         artistEn: "Pablo Picasso",
              periodJa: "キュビスム"),

        .init(id: "textbook-058",  number: 58,  titleJa: "ブロードウェイ・ブギウギ",
              artist: "ピート・モンドリアン",                   artistEn: "Piet Mondrian",
              periodJa: "抽象絵画",
              wikiTitle: "Broadway Boogie-Woogie"),

        .init(id: "textbook-059",  number: 59,  titleJa: "光の帝国",
              artist: "ルネ・マグリット",                       artistEn: "René Magritte",
              periodJa: "シュルレアリスム",
              wikiTitle: "The Empire of Light"),

        .init(id: "textbook-060",  number: 60,  titleJa: "キャンベルスープ缶",
              artist: "アンディ・ウォーホル",                   artistEn: "Andy Warhol",
              periodJa: "ポップアート",
              wikiTitle: "Campbell's Soup Cans"),

        // ── 日本美術 061-100 ──────────────────────────────────────────────────
        .init(id: "textbook-061",  number: 61,  titleJa: "高松塚古墳壁画",
              artist: "作者不詳",                               artistEn: "Unknown",
              periodJa: "飛鳥時代",
              wikiTitle: "高松塚古墳", wikiLang: "ja"),

        .init(id: "textbook-062",  number: 62,  titleJa: "源氏物語絵巻",
              artist: "作者不詳",                               artistEn: "Unknown",
              periodJa: "平安時代",
              wikiTitle: "源氏物語絵巻", wikiLang: "ja"),

        .init(id: "textbook-063",  number: 63,  titleJa: "鳥獣人物戯画",
              artist: "作者不詳",                               artistEn: "Unknown",
              periodJa: "平安〜鎌倉時代",
              wikiTitle: "鳥獣人物戯画", wikiLang: "ja"),

        .init(id: "textbook-064",  number: 64,  titleJa: "慧可断臂図",
              artist: "雪舟等楊",                               artistEn: "Sesshū Tōyō",
              periodJa: "室町時代",
              wikiTitle: "慧可断臂図", wikiLang: "ja"),

        .init(id: "textbook-065",  number: 65,  titleJa: "唐獅子図屏風",
              artist: "狩野永徳",                               artistEn: "Kanō Eitoku",
              periodJa: "桃山時代",
              wikiTitle: "唐獅子図屏風", wikiLang: "ja"),

        .init(id: "textbook-066",  number: 66,  titleJa: "松林図屏風",
              artist: "長谷川等伯",                             artistEn: "Hasegawa Tōhaku",
              periodJa: "桃山時代",
              wikiTitle: "松林図屏風", wikiLang: "ja"),

        .init(id: "textbook-067",  number: 67,  titleJa: "風神雷神図屏風",
              artist: "俵屋宗達",                               artistEn: "Tawaraya Sōtatsu",
              periodJa: "江戸時代",
              wikiTitle: "風神雷神図屏風", wikiLang: "ja"),

        .init(id: "textbook-068",  number: 68,  titleJa: "夕顔棚納涼図屏風",
              artist: "久隅守景",                               artistEn: "Kusumi Morikage",
              periodJa: "江戸時代",
              wikiTitle: "久隅守景", wikiLang: "ja"),

        .init(id: "textbook-069",  number: 69,  titleJa: "見返り美人図",
              artist: "菱川師宣",                               artistEn: "Hishikawa Moronobu",
              periodJa: "江戸時代",
              wikiTitle: "見返り美人図", wikiLang: "ja"),

        .init(id: "textbook-070",  number: 70,  titleJa: "燕子花図屏風",
              artist: "尾形光琳",                               artistEn: "Ogata Kōrin",
              periodJa: "江戸時代",
              wikiTitle: "燕子花図屏風", wikiLang: "ja"),

        .init(id: "textbook-071",  number: 71,  titleJa: "達磨図",
              artist: "白隠慧鶴",                               artistEn: "Hakuin Ekaku",
              periodJa: "江戸時代",
              wikiTitle: "白隠慧鶴", wikiLang: "ja"),

        .init(id: "textbook-072",  number: 72,  titleJa: "群仙図屏風",
              artist: "曾我蕭白",                               artistEn: "Soga Shōhaku",
              periodJa: "江戸時代",
              wikiTitle: "群仙図屏風", wikiLang: "ja"),

        .init(id: "textbook-073",  number: 73,  titleJa: "動植綵絵",
              artist: "伊藤若冲",                               artistEn: "Itō Jakuchū",
              periodJa: "江戸時代",
              wikiTitle: "動植綵絵", wikiLang: "ja"),

        .init(id: "textbook-074",  number: 74,  titleJa: "雨夜の宮詣",
              artist: "鈴木春信",                               artistEn: "Suzuki Harunobu",
              periodJa: "江戸時代",
              wikiTitle: "鈴木春信", wikiLang: "ja"),

        .init(id: "textbook-075",  number: 75,  titleJa: "雪松図屏風",
              artist: "円山応挙",                               artistEn: "Maruyama Ōkyo",
              periodJa: "江戸時代",
              wikiTitle: "雪松図屏風", wikiLang: "ja"),

        .init(id: "textbook-076",  number: 76,  titleJa: "虎図襖",
              artist: "長沢芦雪",                               artistEn: "Nagasawa Rosetsu",
              periodJa: "江戸時代",
              wikiTitle: "長沢芦雪", wikiLang: "ja"),

        .init(id: "textbook-077",  number: 77,  titleJa: "鳶烏図",
              artist: "与謝蕪村",                               artistEn: "Yosa Buson",
              periodJa: "江戸時代",
              wikiTitle: "与謝蕪村", wikiLang: "ja"),

        .init(id: "textbook-078",  number: 78,  titleJa: "婦女人相十品 ポッピンを吹く女",
              artist: "喜多川歌麿",                             artistEn: "Kitagawa Utamaro",
              periodJa: "江戸時代",
              wikiTitle: "婦女人相十品", wikiLang: "ja"),

        .init(id: "textbook-079",  number: 79,  titleJa: "三代目大谷鬼次の奴江戸兵衛",
              artist: "東洲斎写楽",                             artistEn: "Tōshūsai Sharaku",
              periodJa: "江戸時代",
              wikiTitle: "三代目大谷鬼次の奴江戸兵衛", wikiLang: "ja"),

        .init(id: "textbook-080",  number: 80,  titleJa: "夏秋草図屏風",
              artist: "酒井抱一",                               artistEn: "Sakai Hōitsu",
              periodJa: "江戸時代",
              wikiTitle: "夏秋草図屏風", wikiLang: "ja"),

        .init(id: "textbook-081",  number: 81,  titleJa: "富嶽三十六景 神奈川沖浪裏",
              artist: "葛飾北斎",                               artistEn: "Katsushika Hokusai",
              periodJa: "江戸時代",
              wikiTitle: "神奈川沖浪裏", wikiLang: "ja"),

        .init(id: "textbook-082",  number: 82,  titleJa: "東海道五十三次 庄野（白雨）",
              artist: "歌川広重",                               artistEn: "Utagawa Hiroshige",
              periodJa: "江戸時代",
              wikiTitle: "東海道五十三次", wikiLang: "ja"),

        .init(id: "textbook-083",  number: 83,  titleJa: "鷹見泉石像",
              artist: "渡辺崋山",                               artistEn: "Watanabe Kazan",
              periodJa: "江戸時代",
              wikiTitle: "鷹見泉石像", wikiLang: "ja"),

        .init(id: "textbook-084",  number: 84,  titleJa: "見かけハこハゐが とんだいゝ人だ",
              artist: "歌川国芳",                               artistEn: "Utagawa Kuniyoshi",
              periodJa: "江戸時代",
              wikiTitle: "歌川国芳", wikiLang: "ja"),

        .init(id: "textbook-085",  number: 85,  titleJa: "鮭",
              artist: "高橋由一",                               artistEn: "Takahashi Yuichi",
              periodJa: "明治時代",
              wikiTitle: "鮭 (高橋由一)", wikiLang: "ja"),

        .init(id: "textbook-086",  number: 86,  titleJa: "枯木寒鴉図",
              artist: "河鍋暁斎",                               artistEn: "Kawanabe Kyōsai",
              periodJa: "明治時代",
              wikiTitle: "河鍋暁斎", wikiLang: "ja"),

        .init(id: "textbook-087",  number: 87,  titleJa: "悲母観音図",
              artist: "狩野芳崖",                               artistEn: "Kanō Hōgai",
              periodJa: "明治時代",
              wikiTitle: "悲母観音", wikiLang: "ja"),

        .init(id: "textbook-088",  number: 88,  titleJa: "湖畔",
              artist: "黒田清輝",                               artistEn: "Kuroda Seiki",
              periodJa: "明治時代",
              wikiTitle: "湖畔 (黒田清輝)", wikiLang: "ja"),

        .init(id: "textbook-089",  number: 89,  titleJa: "屈原",
              artist: "横山大観",                               artistEn: "Yokoyama Taikan",
              periodJa: "明治〜昭和時代",
              wikiTitle: "横山大観", wikiLang: "ja"),

        .init(id: "textbook-090",  number: 90,  titleJa: "海の幸",
              artist: "青木繁",                                 artistEn: "Aoki Shigeru",
              periodJa: "明治時代",
              wikiTitle: "海の幸", wikiLang: "ja"),

        .init(id: "textbook-091",  number: 91,  titleJa: "黒き猫",
              artist: "菱田春草",                               artistEn: "Hishida Shunsō",
              periodJa: "明治時代",
              wikiTitle: "黒き猫", wikiLang: "ja"),

        .init(id: "textbook-092",  number: 92,  titleJa: "裸体美人",
              artist: "萬鉄五郎",                               artistEn: "Yorozu Tetsugorō",
              periodJa: "大正時代",
              wikiTitle: "萬鉄五郎", wikiLang: "ja"),

        .init(id: "textbook-093",  number: 93,  titleJa: "麗子像",
              artist: "岸田劉生",                               artistEn: "Kishida Ryūsei",
              periodJa: "大正時代",
              wikiTitle: "麗子像", wikiLang: "ja"),

        .init(id: "textbook-094",  number: 94,  titleJa: "炎舞",
              artist: "速水御舟",                               artistEn: "Hayami Gyoshū",
              periodJa: "大正〜昭和時代",
              wikiTitle: "炎舞", wikiLang: "ja"),

        .init(id: "textbook-095",  number: 95,  titleJa: "郵便配達夫",
              artist: "佐伯祐三",                               artistEn: "Saeki Yūzō",
              periodJa: "大正〜昭和時代",
              wikiTitle: "佐伯祐三", wikiLang: "ja"),

        .init(id: "textbook-096",  number: 96,  titleJa: "海",
              artist: "古賀春江",                               artistEn: "Koga Harue",
              periodJa: "大正〜昭和時代",
              wikiTitle: "古賀春江", wikiLang: "ja"),

        .init(id: "textbook-097",  number: 97,  titleJa: "水竹居",
              artist: "竹久夢二",                               artistEn: "Takehisa Yumeji",
              periodJa: "大正時代",
              wikiTitle: "竹久夢二", wikiLang: "ja"),

        .init(id: "textbook-098",  number: 98,  titleJa: "序の舞",
              artist: "上村松園",                               artistEn: "Uemura Shōen",
              periodJa: "大正〜昭和時代",
              wikiTitle: "序の舞", wikiLang: "ja"),

        .init(id: "textbook-099",  number: 99,  titleJa: "痛ましき腕",
              artist: "岡本太郎",                               artistEn: "Okamoto Tarō",
              periodJa: "昭和時代",
              wikiTitle: "痛ましき腕", wikiLang: "ja"),

        .init(id: "textbook-100",  number: 100, titleJa: "道",
              artist: "東山魁夷",                               artistEn: "Higashiyama Kaii",
              periodJa: "昭和時代",
              wikiTitle: "道 (東山魁夷)", wikiLang: "ja"),
    ]
}
