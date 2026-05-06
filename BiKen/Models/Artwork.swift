import Foundation

enum Era: String, CaseIterable, Codable, Sendable {
    case renaissance = "Renaissance"
    case baroque = "Baroque"
    case impressionism = "Impressionism"
    case modernArt = "Modern Art"
    case japaneseArt = "Japanese Art"
    case contemporary = "Contemporary"

    var japaneseName: String {
        switch self {
        case .renaissance:  "ルネサンス"
        case .baroque:      "バロック"
        case .impressionism:"印象派"
        case .modernArt:    "近代美術"
        case .japaneseArt:  "日本美術"
        case .contemporary: "現代美術"
        }
    }

    var period: String {
        switch self {
        case .renaissance:  "14〜17世紀"
        case .baroque:      "17〜18世紀"
        case .impressionism:"19世紀後半"
        case .modernArt:    "20世紀"
        case .japaneseArt:  "江戸〜近代"
        case .contemporary: "1960年代〜"
        }
    }

    var gradientStart: String {
        switch self {
        case .renaissance:  "6B3A2A"
        case .baroque:      "1A0A3E"
        case .impressionism:"1A4A6B"
        case .modernArt:    "6B0000"
        case .japaneseArt:  "6B0030"
        case .contemporary: "1C1C1C"
        }
    }

    var gradientEnd: String {
        switch self {
        case .renaissance:  "C4854A"
        case .baroque:      "3A0E8F"
        case .impressionism:"5BA3D0"
        case .modernArt:    "CC2200"
        case .japaneseArt:  "CC3366"
        case .contemporary: "606060"
        }
    }

    var quizID: String { rawValue.lowercased().replacingOccurrences(of: " ", with: "") }

    var searchQueries: [String] {
        switch self {
        case .renaissance:
            ["leonardo da vinci", "michelangelo", "raphael", "botticelli", "titian", "jan van eyck", "bruegel", "durer"]
        case .baroque:
            ["rembrandt", "vermeer", "caravaggio", "rubens", "velazquez", "van dyck", "la tour"]
        case .impressionism:
            ["monet", "renoir", "degas", "manet", "cezanne", "pissarro", "sisley", "morisot", "van gogh", "gauguin", "seurat"]
        case .modernArt:
            ["picasso", "matisse", "kandinsky", "klimt", "munch", "chagall", "dali", "mondrian"]
        case .japaneseArt:
            ["hokusai", "hiroshige", "utamaro", "sharaku", "kuniyoshi", "harunobu"]
        case .contemporary:
            ["warhol", "pollock", "lichtenstein"]
        }
    }
}

enum Difficulty: String, Codable, Sendable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

struct Artwork: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: String
    let title: String
    let titleJa: String?
    let artist: String
    let artistJa: String?
    let artistOriginal: String
    let year: Int?
    let medium: String
    let movement: String
    let era: Era
    let imageURL: URL
    let description: String
    let artistBio: String?
    let difficulty: Difficulty

    var displayTitle: String  { titleJa ?? title }
    var displayArtist: String { artistJa ?? artist }
}
