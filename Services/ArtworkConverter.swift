import Foundation

// MARK: - Japanese Mappings

private let mappedArtists: Set<String> = [
    "botticelli", "sandro botticelli", "leonardo", "leonardo da vinci", "michelangelo",
    "michelangelo buonarroti", "raphael", "raffaello", "titian", "tiziano", "jan van eyck",
    "bruegel", "pieter bruegel", "dürer", "durer", "albrecht dürer", "albrecht durer",
    "caravaggio", "rembrandt", "rembrandt van rijn", "vermeer", "johannes vermeer", "jan vermeer",
    "rubens", "peter paul rubens", "velázquez", "velazquez", "diego velázquez", "diego velazquez",
    "georges de la tour", "la tour", "van dyck", "anthony van dyck",
    "watteau", "antoine watteau", "boucher", "fragonard",
    "david", "jacques-louis david", "ingres", "géricault", "gericault", "delacroix", "goya",
    "courbet", "millet", "corot",
    "manet", "édouard manet", "edouard manet", "monet", "claude monet",
    "renoir", "pierre-auguste renoir", "degas", "edgar degas", "pissarro", "sisley", "morisot",
    "seurat", "signac", "cézanne", "cezanne", "paul cézanne", "paul cezanne",
    "van gogh", "vincent van gogh", "gauguin", "paul gauguin", "toulouse-lautrec",
    "klimt", "gustav klimt", "munch", "edvard munch", "redon", "moreau",
    "picasso", "pablo picasso", "matisse", "henri matisse", "kandinsky", "wassily kandinsky",
    "mondrian", "piet mondrian", "dalí", "dali", "salvador dalí", "salvador dali",
    "chagall", "marc chagall", "warhol", "andy warhol", "pollock", "jackson pollock",
    "hokusai", "katsushika hokusai", "hiroshige", "utagawa hiroshige", "ando hiroshige",
    "utamaro", "kitagawa utamaro", "sharaku", "tōshūsai sharaku", "toshusai sharaku",
    "moronobu", "hishikawa moronobu", "harunobu", "suzuki harunobu", "kuniyoshi", "utagawa kuniyoshi",
    "sotatsu", "tawaraya sōtatsu", "korin", "ogata kōrin", "hoitsu", "sakai hōitsu",
    "sesshu", "sesshū", "eitoku", "kanō eitoku", "kano eitoku", "tohaku", "hasegawa tōhaku",
    "jakuchu", "itō jakuchū", "ito jakuchu", "okyo", "maruyama ōkyo",
    "taikan", "yokoyama taikan", "shunso", "shoen", "seiho", "kaii", "higashiyama kaii",
    "kuroda seiki", "fujishima takeji", "aoki shigeru", "ryusei", "kishida ryūsei",
]

private let artistNameMap: [String: String] = [
    "sandro botticelli": "サンドロ・ボッティチェッリ",
    "botticelli": "サンドロ・ボッティチェッリ",
    "leonardo da vinci": "レオナルド・ダ・ヴィンチ",
    "leonardo": "レオナルド・ダ・ヴィンチ",
    "michelangelo buonarroti": "ミケランジェロ・ブオナローティ",
    "michelangelo": "ミケランジェロ・ブオナローティ",
    "raphael": "ラファエロ・サンティ", "raffaello": "ラファエロ・サンティ",
    "titian": "ティツィアーノ・ヴェチェッリオ", "tiziano": "ティツィアーノ・ヴェチェッリオ",
    "jan van eyck": "ヤン・ファン・エイク",
    "pieter bruegel": "ピーテル・ブリューゲル", "bruegel": "ピーテル・ブリューゲル",
    "albrecht dürer": "アルブレヒト・デューラー", "albrecht durer": "アルブレヒト・デューラー",
    "dürer": "アルブレヒト・デューラー", "durer": "アルブレヒト・デューラー",
    "caravaggio": "カラヴァッジョ",
    "rembrandt van rijn": "レンブラント・ファン・レイン", "rembrandt": "レンブラント・ファン・レイン",
    "johannes vermeer": "ヨハネス・フェルメール", "vermeer": "ヨハネス・フェルメール",
    "peter paul rubens": "ピーテル・パウル・ルーベンス", "rubens": "ピーテル・パウル・ルーベンス",
    "diego velázquez": "ディエゴ・ベラスケス", "diego velazquez": "ディエゴ・ベラスケス",
    "velázquez": "ディエゴ・ベラスケス", "velazquez": "ディエゴ・ベラスケス",
    "georges de la tour": "ジョルジュ・ド・ラ・トゥール", "la tour": "ジョルジュ・ド・ラ・トゥール",
    "anthony van dyck": "アンソニー・ヴァン・ダイク", "van dyck": "アンソニー・ヴァン・ダイク",
    "antoine watteau": "アントワーヌ・ヴァトー", "watteau": "アントワーヌ・ヴァトー",
    "François boucher": "フランソワ・ブーシェ", "boucher": "フランソワ・ブーシェ",
    "jean-honoré fragonard": "ジャン・オノレ・フラゴナール", "fragonard": "ジャン・オノレ・フラゴナール",
    "jacques-louis david": "ジャック＝ルイ・ダヴィッド", "david": "ジャック＝ルイ・ダヴィッド",
    "jean-auguste-dominique ingres": "ドミニク・アングル", "ingres": "ドミニク・アングル",
    "théodore géricault": "テオドール・ジェリコー", "géricault": "テオドール・ジェリコー", "gericault": "テオドール・ジェリコー",
    "eugène delacroix": "ウジェーヌ・ドラクロワ", "delacroix": "ウジェーヌ・ドラクロワ",
    "francisco de goya": "フランシスコ・デ・ゴヤ", "goya": "フランシスコ・デ・ゴヤ",
    "gustave courbet": "ギュスターヴ・クールベ", "courbet": "ギュスターヴ・クールベ",
    "jean-françois millet": "ジャン＝フランソワ・ミレー", "millet": "ジャン＝フランソワ・ミレー",
    "camille corot": "カミーユ・コロー", "corot": "カミーユ・コロー",
    "édouard manet": "エドゥアール・マネ", "edouard manet": "エドゥアール・マネ", "manet": "エドゥアール・マネ",
    "claude monet": "クロード・モネ", "monet": "クロード・モネ",
    "pierre-auguste renoir": "ピエール＝オーギュスト・ルノワール", "renoir": "ピエール＝オーギュスト・ルノワール",
    "edgar degas": "エドガー・ドガ", "degas": "エドガー・ドガ",
    "camille pissarro": "カミーユ・ピサロ", "pissarro": "カミーユ・ピサロ",
    "alfred sisley": "アルフレッド・シスレー", "sisley": "アルフレッド・シスレー",
    "berthe morisot": "ベルト・モリゾ", "morisot": "ベルト・モリゾ",
    "georges seurat": "ジョルジュ・スーラ", "seurat": "ジョルジュ・スーラ",
    "paul signac": "ポール・シニャック", "signac": "ポール・シニャック",
    "paul cézanne": "ポール・セザンヌ", "paul cezanne": "ポール・セザンヌ", "cézanne": "ポール・セザンヌ", "cezanne": "ポール・セザンヌ",
    "vincent van gogh": "フィンセント・ファン・ゴッホ", "van gogh": "フィンセント・ファン・ゴッホ",
    "paul gauguin": "ポール・ゴーギャン", "gauguin": "ポール・ゴーギャン",
    "henri de toulouse-lautrec": "アンリ・ド・トゥールーズ＝ロートレック", "toulouse-lautrec": "アンリ・ド・トゥールーズ＝ロートレック",
    "gustav klimt": "グスタフ・クリムト", "klimt": "グスタフ・クリムト",
    "edvard munch": "エドヴァルド・ムンク", "munch": "エドヴァルド・ムンク",
    "odilon redon": "オディロン・ルドン", "redon": "オディロン・ルドン",
    "gustave moreau": "ギュスターヴ・モロー", "moreau": "ギュスターヴ・モロー",
    "pablo picasso": "パブロ・ピカソ", "picasso": "パブロ・ピカソ",
    "henri matisse": "アンリ・マティス", "matisse": "アンリ・マティス",
    "wassily kandinsky": "ワシリー・カンディンスキー", "kandinsky": "ワシリー・カンディンスキー",
    "piet mondrian": "ピート・モンドリアン", "mondrian": "ピート・モンドリアン",
    "salvador dalí": "サルバドール・ダリ", "salvador dali": "サルバドール・ダリ", "dalí": "サルバドール・ダリ", "dali": "サルバドール・ダリ",
    "marc chagall": "マルク・シャガール", "chagall": "マルク・シャガール",
    "andy warhol": "アンディ・ウォーホル", "warhol": "アンディ・ウォーホル",
    "jackson pollock": "ジャクソン・ポロック", "pollock": "ジャクソン・ポロック",
    "katsushika hokusai": "葛飾北斎", "hokusai": "葛飾北斎",
    "utagawa hiroshige": "歌川広重", "ando hiroshige": "歌川広重", "hiroshige": "歌川広重",
    "kitagawa utamaro": "喜多川歌麿", "utamaro": "喜多川歌麿",
    "tōshūsai sharaku": "東洲斎写楽", "toshusai sharaku": "東洲斎写楽", "sharaku": "東洲斎写楽",
    "hishikawa moronobu": "菱川師宣", "moronobu": "菱川師宣",
    "suzuki harunobu": "鈴木春信", "harunobu": "鈴木春信",
    "utagawa kuniyoshi": "歌川国芳", "kuniyoshi": "歌川国芳",
    "tawaraya sōtatsu": "俵屋宗達", "sotatsu": "俵屋宗達",
    "ogata kōrin": "尾形光琳", "korin": "尾形光琳",
    "sakai hōitsu": "酒井抱一", "hoitsu": "酒井抱一",
    "sesshū": "雪舟", "sesshu": "雪舟",
    "kanō eitoku": "狩野永徳", "kano eitoku": "狩野永徳", "eitoku": "狩野永徳",
    "hasegawa tōhaku": "長谷川等伯", "tohaku": "長谷川等伯",
    "itō jakuchū": "伊藤若冲", "ito jakuchu": "伊藤若冲", "jakuchu": "伊藤若冲",
    "maruyama ōkyo": "円山応挙", "okyo": "円山応挙",
    "yokoyama taikan": "横山大観", "taikan": "横山大観",
    "hishida shunsō": "菱田春草", "shunso": "菱田春草",
    "uemura shōen": "上村松園", "shoen": "上村松園",
    "takeuchi seihō": "竹内栖鳳", "seiho": "竹内栖鳳",
    "higashiyama kaii": "東山魁夷", "kaii": "東山魁夷",
    "kuroda seiki": "黒田清輝",
    "fujishima takeji": "藤島武二",
    "aoki shigeru": "青木繁",
    "kishida ryūsei": "岸田劉生", "kishida ryusei": "岸田劉生", "ryusei": "岸田劉生",
]

private let titleMap: [String: String] = [
    "the birth of venus": "ヴィーナスの誕生",
    "birth of venus": "ヴィーナスの誕生",
    "primavera": "プリマヴェーラ（春）",
    "mona lisa": "モナ・リザ",
    "the last supper": "最後の晩餐",
    "the last judgment": "最後の審判",
    "the school of athens": "アテネの学堂",
    "venus of urbino": "ウルビーノのヴィーナス",
    "the arnolfini portrait": "アルノルフィーニ夫妻像",
    "the tower of babel": "バベルの塔",
    "hunters in the snow": "雪中の狩人",
    "the calling of saint matthew": "聖マタイの召命",
    "the night watch": "夜警",
    "night watch": "夜警",
    "girl with a pearl earring": "真珠の耳飾りの少女",
    "the milkmaid": "牛乳を注ぐ女",
    "milkmaid": "牛乳を注ぐ女",
    "view of delft": "デルフトの眺望",
    "las meninas": "ラス・メニーナス（女官たち）",
    "the swing": "ぶらんこ",
    "the coronation of napoleon": "ナポレオンの戴冠式",
    "the death of marat": "マラーの死",
    "oath of the horatii": "ホラティウス兄弟の誓い",
    "grande odalisque": "グランド・オダリスク",
    "the raft of the medusa": "メデュース号の筏",
    "liberty leading the people": "民衆を導く自由の女神",
    "saturn devouring his son": "我が子を食らうサトゥルヌス",
    "the gleaners": "落穂拾い",
    "gleaners": "落穂拾い",
    "the angelus": "晩鐘",
    "the sower": "種まく人",
    "olympia": "オランピア",
    "impression, sunrise": "印象・日の出",
    "water lilies": "睡蓮",
    "waterlilies": "睡蓮",
    "bal du moulin de la galette": "ムーラン・ド・ラ・ギャレットの舞踏会",
    "dance at le moulin de la galette": "ムーラン・ド・ラ・ギャレットの舞踏会",
    "luncheon of the boating party": "舟遊びの昼食",
    "the dance class": "踊り子",
    "the star": "エトワール",
    "mont sainte-victoire": "サント・ヴィクトワール山",
    "the card players": "カード遊びをする人々",
    "sunflowers": "ひまわり",
    "starry night": "星月夜",
    "the starry night": "星月夜",
    "bedroom in arles": "アルルの寝室",
    "where do we come from? what are we? where are we going?": "我々はどこから来たのか 我々は何者か 我々はどこへ行くのか",
    "the kiss": "接吻",
    "kiss": "接吻",
    "the scream": "叫び",
    "scream": "叫び",
    "guernica": "ゲルニカ",
    "les demoiselles d'avignon": "アヴィニョンの娘たち",
    "the persistence of memory": "記憶の固執",
    "i and the village": "私と村",
    "the great wave off kanagawa": "神奈川沖浪裏",
    "under the wave off kanagawa": "神奈川沖浪裏",
    "great wave": "神奈川沖浪裏",
    "fine wind, clear morning": "凱風快晴（赤富士）",
    "south wind, clear sky": "凱風快晴（赤富士）",
    "beauty looking back": "見返り美人図",
    "wind god and thunder god": "風神雷神図屏風",
    "irises": "燕子花図屏風",
    "red and white plum blossoms": "紅白梅図屏風",
    "pine trees": "松林図屏風",
]

// MARK: - Conversion Functions

func hasJapaneseMapping(_ artistName: String) -> Bool {
    guard !artistName.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
    let lower = artistName.lowercased()
    let unknowns = ["unknown", "anonymous", "unidentified", "attributed"]
    if unknowns.contains(where: { lower.contains($0) }) { return false }
    return mappedArtists.contains(where: { lower.contains($0) || $0.contains(lower) })
}

private func japaneseArtistName(_ name: String) -> String {
    let lower = name.lowercased()
    let sortedKeys = artistNameMap.keys.sorted { $0.count > $1.count }
    for key in sortedKeys where lower.contains(key) {
        return artistNameMap[key]!
    }
    return name
}

private func japaneseTitle(_ title: String) -> String? {
    let lower = title.lowercased()
    if let exact = titleMap[lower] { return exact }
    let sortedKeys = titleMap.keys.sorted { $0.count > $1.count }
    for key in sortedKeys where lower.contains(key) {
        return titleMap[key]
    }
    return nil
}

private func japaneseMedium(_ medium: String) -> String {
    let lower = medium.lowercased()
    let map: [(String, String)] = [
        ("oil on canvas", "油彩、カンヴァス"),
        ("oil on panel", "油彩、板"),
        ("oil on wood", "油彩、板"),
        ("tempera on panel", "テンペラ、板"),
        ("fresco", "フレスコ"),
        ("watercolor", "水彩"),
        ("woodblock print", "木版画"),
        ("woodcut", "木版画"),
        ("color woodblock print", "多色木版画"),
        ("ink on paper", "紙本墨画"),
        ("ink and color on paper", "紙本着色"),
        ("ink and color on silk", "絹本着色"),
        ("pastel", "パステル"),
        ("gouache", "グワッシュ"),
        ("etching", "エッチング"),
        ("engraving", "版画"),
        ("lithograph", "リトグラフ"),
        ("bronze", "ブロンズ"),
        ("marble", "大理石"),
    ]
    for (key, value) in map where lower.contains(key) { return value }
    return ""
}

private func detectEra(_ artwork: MetArtworkResponse) -> Era {
    let text = "\(artwork.department) \(artwork.period ?? "") \(artwork.culture ?? "") \(artwork.objectDate ?? "") \(artwork.classification ?? "")".lowercased()
    if text.contains("japan") || text.contains("ukiyo") || text.contains("edo") { return .japaneseArt }
    if text.contains("renaissance") || (artwork.objectBeginDate >= 1400 && artwork.objectEndDate <= 1600) { return .renaissance }
    if text.contains("baroque") || (artwork.objectBeginDate >= 1600 && artwork.objectEndDate <= 1750) { return .baroque }
    if text.contains("impressionist") || (artwork.objectBeginDate >= 1860 && artwork.objectEndDate <= 1910) { return .impressionism }
    if text.contains("modern") || text.contains("20th century") || artwork.objectBeginDate >= 1900 { return .modernArt }
    return .renaissance
}

private func detectDifficulty(_ artwork: MetArtworkResponse) -> Difficulty {
    if artwork.isHighlight { return .easy }
    let famousNames = ["van gogh", "monet", "rembrandt", "vermeer", "da vinci", "leonardo",
                       "michelangelo", "picasso", "hokusai", "hiroshige", "botticelli",
                       "raphael", "caravaggio", "renoir", "cezanne", "klimt", "matisse"]
    let lower = (artwork.artistDisplayName ?? "").lowercased()
    if famousNames.contains(where: { lower.contains($0) }) { return .easy }
    return Bool.random() ? .medium : .hard
}

// MARK: - Public API

func convertArtwork(_ metArtwork: MetArtworkResponse) -> Artwork? {
    let artistDisplayName = metArtwork.artistDisplayName ?? ""
    guard let imageURL = URL(string: metArtwork.primaryImage.isEmpty ? metArtwork.primaryImageSmall : metArtwork.primaryImage),
          !imageURL.absoluteString.isEmpty,
          metArtwork.isPublicDomain,
          hasJapaneseMapping(artistDisplayName)
    else { return nil }

    let era = detectEra(metArtwork)
    let difficulty = detectDifficulty(metArtwork)
    let artistJa = japaneseArtistName(artistDisplayName)
    let titleJa = japaneseTitle(metArtwork.title)
    let displayTitle = titleJa ?? metArtwork.title

    let mediumStr = metArtwork.medium ?? ""
    let mediumJa = japaneseMedium(mediumStr)
    var desc = "『\(displayTitle)』は\(artistJa)による作品です。"
    if metArtwork.objectBeginDate > 0 { desc += "\(metArtwork.objectBeginDate)年頃に制作されました。" }
    if !mediumJa.isEmpty { desc += "技法は\(mediumJa)です。" }
    desc += "現在、メトロポリタン美術館に所蔵されています。"

    let artistBio = metArtwork.artistDisplayBio.flatMap { $0.isEmpty ? nil : $0 }

    return Artwork(
        id: String(metArtwork.objectID),
        title: displayTitle,
        titleJa: titleJa,
        artist: artistJa,
        artistJa: artistJa,
        artistOriginal: artistDisplayName.isEmpty ? "Unknown" : artistDisplayName,
        year: metArtwork.objectBeginDate > 0 ? metArtwork.objectBeginDate : nil,
        medium: mediumStr,
        movement: metArtwork.classification ?? "",
        era: era,
        imageURL: imageURL,
        description: desc,
        artistBio: artistBio,
        difficulty: difficulty
    )
}

func convertArtworks(_ metArtworks: [MetArtworkResponse]) -> [Artwork] {
    var seen = Set<Int>()
    return metArtworks.compactMap { meta -> Artwork? in
        guard !seen.contains(meta.objectID) else { return nil }
        seen.insert(meta.objectID)
        return convertArtwork(meta)
    }
}

func generateQuiz(from artworks: [Artwork], count: Int = 10) throws -> [QuizQuestion] {
    guard artworks.count >= 2 else {
        throw NSError(domain: "Quiz", code: 0, userInfo: [NSLocalizedDescriptionKey: "十分な作品を取得できませんでした"])
    }
    let shuffled = artworks.shuffled()
    let selected = Array(shuffled.prefix(min(count, shuffled.count)))

    return selected.enumerated().map { index, artwork in
        // 他の作家（重複なし、正解と異なる）
        let otherPool = Array(Set(artworks.filter { $0.artist != artwork.artist }.map { $0.artist })).shuffled()
        var wrongOptions: [String] = Array(otherPool.prefix(3))
        let fallbacks = ["作者不詳", "匿名の画家", "不明な作家"]
        var fi = 0
        while wrongOptions.count < 3 {
            let candidate = fallbacks[fi % fallbacks.count]; fi += 1
            if !wrongOptions.contains(candidate) && candidate != artwork.artist {
                wrongOptions.append(candidate)
            }
        }
        // 安定IDのために enumerated index を使う（ForEach クラッシュ防止）
        let options = ([artwork.artist] + wrongOptions).shuffled()
        return QuizQuestion(
            id: "q-\(index)-\(artwork.id)",
            artwork: artwork,
            question: "この作品の作者は誰でしょう？",
            options: options,
            correctAnswer: artwork.artist
        )
    }
}
