import Foundation

// MARK: - WikiImageResult

enum WikiImageResult {
    case found(URL)
    case absent  // 記事なし・サムネイルなし（恒久的失敗）
}

// MARK: - WikipediaImageService

actor WikipediaImageService {
    static let shared = WikipediaImageService()

    private let session: URLSession
    private var inFlight: [String: Task<WikiImageResult?, Never>] = [:]
    private var completed: [String: WikiImageResult] = [:]

    init(session: URLSession = .shared) {
        self.session = session
    }

    func imageURL(wikiTitle: String, lang: String = "en") async -> URL? {
        let key = "\(lang):\(wikiTitle)"

        if let cached = completed[key] {
            if case .found(let url) = cached { return url }
            return nil
        }
        if let running = inFlight[key] {
            let result = await running.value
            if let result, case .found(let url) = result { return url }
            return nil
        }

        let task = Task<WikiImageResult?, Never> {
            guard var components = URLComponents(string: "https://\(lang).wikipedia.org/w/api.php") else {
                return .absent
            }
            components.queryItems = [
                URLQueryItem(name: "action",      value: "query"),
                URLQueryItem(name: "titles",      value: wikiTitle),
                URLQueryItem(name: "prop",        value: "pageimages"),
                URLQueryItem(name: "pithumbsize", value: "800"),
                URLQueryItem(name: "format",      value: "json"),
                URLQueryItem(name: "redirects",   value: "1"),
            ]
            guard let requestURL = components.url else { return .absent }

            let data: Data
            do {
                (data, _) = try await self.session.data(from: requestURL)
            } catch {
                return nil  // ネットワークエラーは一時的な失敗 → キャッシュしない
            }

            guard let json  = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let query = json["query"]  as? [String: Any],
                  let pages = query["pages"] as? [String: Any],
                  let page  = pages.values.first as? [String: Any] else {
                return .absent
            }

            guard page["missing"] == nil,
                  let thumb  = page["thumbnail"] as? [String: Any],
                  let source = thumb["source"]   as? String,
                  let url    = URL(string: source) else {
                return .absent
            }

            return .found(url)
        }

        inFlight[key] = task
        let result = await task.value
        if let result {
            completed[key] = result
        }
        inFlight[key] = nil
        if let result, case .found(let url) = result { return url }
        return nil
    }
}
