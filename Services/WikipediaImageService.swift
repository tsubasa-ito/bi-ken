import Foundation

actor WikipediaImageService {
    static let shared = WikipediaImageService()

    private var inFlight: [String: Task<URL?, Never>] = [:]
    private var completed: [String: URL?] = [:]

    func imageURL(wikiTitle: String, lang: String = "en") async -> URL? {
        let key = "\(lang):\(wikiTitle)"

        if completed.keys.contains(key) { return completed[key] ?? nil }
        if let running = inFlight[key] { return await running.value }

        let task = Task<URL?, Never> {
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
            guard let requestURL = components.url,
                  let (data, _) = try? await URLSession.shared.data(from: requestURL),
                  let json   = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let query  = json["query"]  as? [String: Any],
                  let pages  = query["pages"] as? [String: Any],
                  let page   = pages.values.first as? [String: Any],
                  page["missing"] == nil,
                  let thumb  = page["thumbnail"] as? [String: Any],
                  let source = thumb["source"]   as? String else { return nil }
            return URL(string: source)
        }

        inFlight[key] = task
        let url = await task.value
        completed[key] = url
        inFlight[key] = nil
        return url
    }
}
