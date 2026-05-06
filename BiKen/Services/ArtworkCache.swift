import Foundation

actor ArtworkCache {
    static let shared = ArtworkCache()

    private let cache = NSCache<NSString, CacheEntry>()
    private let ttl: TimeInterval = 300

    private final class CacheEntry: NSObject {
        let value: Any
        let expiresAt: Date
        init(value: Any, expiresAt: Date) {
            self.value = value
            self.expiresAt = expiresAt
        }
    }

    private init() {
        cache.countLimit = 500
    }

    func set<T: Sendable>(_ value: T, forKey key: String) {
        cache.setObject(CacheEntry(value: value, expiresAt: Date().addingTimeInterval(ttl)), forKey: key as NSString)
    }

    func get<T: Sendable>(_: T.Type, forKey key: String) -> T? {
        guard let entry = cache.object(forKey: key as NSString),
              entry.expiresAt > Date(),
              let value = entry.value as? T else { return nil }
        return value
    }
}
