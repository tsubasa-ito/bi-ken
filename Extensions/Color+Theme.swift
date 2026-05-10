import SwiftUI
import UIKit

private extension UIColor {
    convenience init(hex: String) {
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
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, alpha: Double(a) / 255)
    }
}

private func adaptive(_ light: String, _ dark: String) -> Color {
    let lightColor = UIColor(hex: light)
    let darkColor = UIColor(hex: dark)
    return Color(UIColor { t in t.userInterfaceStyle == .dark ? darkColor : lightColor })
}

extension Color {
    static let appBackground     = adaptive("FAFAF7", "1A1A18")
    static let appPrimary        = adaptive("3B5BDB", "6B8EF7")
    static let appAccent         = adaptive("F5C518", "F5C518")
    static let appText           = adaptive("1A1A1A", "F0EFE8")
    static let appTextSecondary  = adaptive("4A4A4A", "B8B6AE")
    static let appTextTertiary   = adaptive("8A8A8A", "6A6860")
    static let appCardBG         = adaptive("F2F1EC", "252520")
    static let appStreakBG       = adaptive("FFFBE8", "2A2618")
    static let appBorder         = adaptive("1A1A1A", "3A3A35")
    static let appCorrect        = adaptive("2D6A2D", "4CAF4C")
    static let appCorrectBG      = adaptive("E7F4E7", "1A2E1A")
    static let appIncorrect      = adaptive("B23A3A", "E05555")
    static let appIncorrectBG    = adaptive("FBEAEA", "2E1A1A")
    // Legacy aliases
    static let appSurface            = adaptive("F2F1EC", "252520")
    static let appSurfaceSecondary   = adaptive("FFFBE8", "2A2618")
    static let appError              = adaptive("B23A3A", "E05555")
    static let appSuccess            = adaptive("2D6A2D", "4CAF4C")
}

extension ShapeStyle where Self == Color {
    static var appBackground: Color     { .appBackground }
    static var appPrimary: Color        { .appPrimary }
    static var appAccent: Color         { .appAccent }
    static var appText: Color           { .appText }
    static var appTextSecondary: Color  { .appTextSecondary }
    static var appTextTertiary: Color   { .appTextTertiary }
    static var appCardBG: Color         { .appCardBG }
    static var appStreakBG: Color       { .appStreakBG }
    static var appBorder: Color         { .appBorder }
    static var appCorrect: Color        { .appCorrect }
    static var appCorrectBG: Color      { .appCorrectBG }
    static var appIncorrect: Color      { .appIncorrect }
    static var appIncorrectBG: Color    { .appIncorrectBG }
    static var appSurface: Color        { .appSurface }
    static var appSurfaceSecondary: Color { .appSurfaceSecondary }
    static var appError: Color          { .appError }
    static var appSuccess: Color        { .appSuccess }
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
