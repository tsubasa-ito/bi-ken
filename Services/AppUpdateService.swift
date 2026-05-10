import Foundation

actor AppUpdateService {
    static let shared = AppUpdateService()

    private static let lastCheckKey = "appUpdateLastCheckDate"
    private static let lookupURL: URL = {
        let bundleId = Bundle.main.bundleIdentifier ?? "com.tebasakin.biken"
        return URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)")!
    }()
    private static let appStoreBaseURL = "https://apps.apple.com/app/id"

    private var isChecking = false

    func checkForUpdate() async -> URL? {
        guard !isChecking else { return nil }
        let userDefaults = UserDefaults.standard
        let lastCheck = userDefaults.object(forKey: Self.lastCheckKey) as? Date
        guard Self.shouldCheckToday(lastCheckDate: lastCheck) else { return nil }

        isChecking = true
        defer { isChecking = false }

        guard
            let (data, response) = try? await URLSession.shared.data(from: Self.lookupURL),
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let results = json["results"] as? [[String: Any]],
            let first = results.first,
            let storeVersion = first["version"] as? String,
            let appId = first["trackId"] as? Int
        else { return nil }

        userDefaults.set(Date(), forKey: Self.lastCheckKey)

        let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        guard Self.isUpdateAvailable(current: current, store: storeVersion) else { return nil }

        return URL(string: "\(Self.appStoreBaseURL)\(appId)")
    }

    static func isUpdateAvailable(current: String, store: String) -> Bool {
        compareVersions(current, store) < 0
    }

    static func compareVersions(_ v1: String, _ v2: String) -> Int {
        let parts1 = v1.split(separator: ".").compactMap { Int($0) }
        let parts2 = v2.split(separator: ".").compactMap { Int($0) }
        let maxLen = max(parts1.count, parts2.count)
        for i in 0..<maxLen {
            let a = i < parts1.count ? parts1[i] : 0
            let b = i < parts2.count ? parts2[i] : 0
            if a < b { return -1 }
            if a > b { return 1 }
        }
        return 0
    }

    static func shouldCheckToday(lastCheckDate: Date?) -> Bool {
        guard let lastCheck = lastCheckDate else { return true }
        let today = Calendar.current.startOfDay(for: Date())
        let lastCheckDay = Calendar.current.startOfDay(for: lastCheck)
        return lastCheckDay < today
    }
}
