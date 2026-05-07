import SwiftUI

extension Color {
    static let appBackground     = Color(hex: "FAFAF7")
    static let appPrimary        = Color(hex: "3B5BDB")
    static let appAccent         = Color(hex: "F5C518")
    static let appText           = Color(hex: "1a1a1a")
    static let appTextSecondary  = Color(hex: "4a4a4a")
    static let appTextTertiary   = Color(hex: "8a8a8a")
    static let appCardBG         = Color(hex: "F2F1EC")
    static let appStreakBG       = Color(hex: "FFFBE8")
    static let appBorder         = Color(hex: "1a1a1a")
    static let appCorrect        = Color(hex: "2D6A2D")
    static let appCorrectBG      = Color(hex: "E7F4E7")
    static let appIncorrect      = Color(hex: "B23A3A")
    static let appIncorrectBG    = Color(hex: "FBEAEA")
    // Legacy aliases
    static let appSurface            = Color(hex: "F2F1EC")
    static let appSurfaceSecondary   = Color(hex: "FFFBE8")
    static let appError              = Color(hex: "B23A3A")
    static let appSuccess            = Color(hex: "2D6A2D")
}

extension ShapeStyle where Self == Color {
    static var appBackground: Color     { Color(hex: "FAFAF7") }
    static var appPrimary: Color        { Color(hex: "3B5BDB") }
    static var appAccent: Color         { Color(hex: "F5C518") }
    static var appText: Color           { Color(hex: "1a1a1a") }
    static var appTextSecondary: Color  { Color(hex: "4a4a4a") }
    static var appTextTertiary: Color   { Color(hex: "8a8a8a") }
    static var appCardBG: Color         { Color(hex: "F2F1EC") }
    static var appStreakBG: Color       { Color(hex: "FFFBE8") }
    static var appBorder: Color         { Color(hex: "1a1a1a") }
    static var appCorrect: Color        { Color(hex: "2D6A2D") }
    static var appCorrectBG: Color      { Color(hex: "E7F4E7") }
    static var appIncorrect: Color      { Color(hex: "B23A3A") }
    static var appIncorrectBG: Color    { Color(hex: "FBEAEA") }
    static var appSurface: Color        { Color(hex: "F2F1EC") }
    static var appSurfaceSecondary: Color { Color(hex: "FFFBE8") }
    static var appError: Color          { Color(hex: "B23A3A") }
    static var appSuccess: Color        { Color(hex: "2D6A2D") }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
