import SwiftUI

extension Color {
    static let appPrimary = Color(hex: "4A7BF7")
    static let appBackground = Color(hex: "0D1117")
    static let appSurface = Color(hex: "161B22")
    static let appSurfaceSecondary = Color(hex: "21262D")
    static let appBorder = Color(hex: "30363D")
    static let appTextSecondary = Color(hex: "8B949E")
    static let appError = Color(hex: "FF6B6B")
    static let appSuccess = Color(hex: "4CAF50")

}

// Enables dot-syntax in .foregroundStyle(.appPrimary) etc.
extension ShapeStyle where Self == Color {
    static var appPrimary: Color         { Color(hex: "4A7BF7") }
    static var appBackground: Color      { Color(hex: "0D1117") }
    static var appSurface: Color         { Color(hex: "161B22") }
    static var appSurfaceSecondary: Color{ Color(hex: "21262D") }
    static var appBorder: Color          { Color(hex: "30363D") }
    static var appTextSecondary: Color   { Color(hex: "8B949E") }
    static var appError: Color           { Color(hex: "FF6B6B") }
    static var appSuccess: Color         { Color(hex: "4CAF50") }
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
