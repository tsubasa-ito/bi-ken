import Foundation
import Observation

@MainActor
@Observable
final class AppSettings {
    static let shared = AppSettings()

    private static let colorSchemeKey = "app.colorScheme"

    var colorScheme: AppColorScheme {
        didSet {
            UserDefaults.standard.set(colorScheme.rawValue, forKey: Self.colorSchemeKey)
        }
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: Self.colorSchemeKey) ?? ""
        colorScheme = AppColorScheme(rawValue: saved) ?? .system
    }
}
