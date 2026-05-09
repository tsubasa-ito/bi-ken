import UIKit

final class ImageCache: @unchecked Sendable {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.totalCostLimit = 100 * 1024 * 1024  // 100MB
    }

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url.absoluteString as NSString)
    }

    func store(_ image: UIImage, for url: URL) {
        let bytes = Int(image.size.width * image.size.height * image.scale * image.scale * 4)
        cache.setObject(image, forKey: url.absoluteString as NSString, cost: bytes)
    }
}
