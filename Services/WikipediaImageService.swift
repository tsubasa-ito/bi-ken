import Foundation

// MARK: - WikiImageResult

fileprivate enum WikiImageResult {
    case found(URL)
    case absent  // 記事なし・サムネイルなし（恒久的失敗）

    var url: URL? {
        guard case .found(let url) = self else { return nil }
        return url
    }
}

// MARK: - Wikipedia API Decodable Models

fileprivate struct WikipediaResponse: Decodable {
    let query: WikipediaQuery
}

fileprivate struct WikipediaQuery: Decodable {
    let pages: [String: WikipediaPage]
}

fileprivate struct WikipediaPage: Decodable {
    let missing: String?
    let thumbnail: WikipediaThumbnail?
}

fileprivate struct WikipediaThumbnail: Decodable {
    let source: String
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
            return cached.url
        }
        if let running = inFlight[key] {
            return await running.value?.url
        }

        let task = Task<WikiImageResult?, Never> {
            guard var components = URLComponents(string: "https://\(lang).wikipedia.org/w/api.php") else {
                return nil
            }
            components.queryItems = [
                URLQueryItem(name: "action",      value: "query"),
                URLQueryItem(name: "titles",      value: wikiTitle),
                URLQueryItem(name: "prop",        value: "pageimages"),
                URLQueryItem(name: "pithumbsize", value: "800"),
                URLQueryItem(name: "format",      value: "json"),
                URLQueryItem(name: "redirects",   value: "1"),
            ]
            guard let requestURL = components.url else { return nil }

            let data: Data
            do {
                let (d, response) = try await self.session.data(from: requestURL)
                if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                    return nil  // サーバ一時エラー（5xx/4xx）→ キャッシュしない
                }
                data = d
            } catch {
                return nil  // ネットワークエラーは一時的な失敗 → キャッシュしない
            }

            guard let response = try? JSONDecoder().decode(WikipediaResponse.self, from: data),
                  let page = response.query.pages.values.first else {
                return .absent
            }

            guard page.missing == nil,
                  let source = page.thumbnail?.source,
                  let url = URL(string: source) else {
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
        return result?.url
    }
}
