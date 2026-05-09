import Foundation

// MARK: - Response Types

struct MetSearchResponse: Codable, Sendable {
    let total: Int
    let objectIDs: [Int]?
}

struct MetArtworkResponse: Codable, Sendable {
    let objectID: Int
    let isHighlight: Bool
    let primaryImage: String
    let primaryImageSmall: String
    let department: String
    let title: String
    let culture: String?
    let period: String?
    let artistDisplayName: String?
    let artistDisplayBio: String?
    let objectDate: String?
    let objectBeginDate: Int
    let objectEndDate: Int
    let medium: String?
    let classification: String?
    let isPublicDomain: Bool
}

// MARK: - Service

enum MetMuseumAPIService {
    private static let baseURL = "https://collectionapi.metmuseum.org/public/collection/v1"

    static func artwork(id: Int) async throws -> MetArtworkResponse {
        let key = "artwork-\(id)"
        if let cached = await ArtworkCache.shared.get(MetArtworkResponse.self, forKey: key) {
            return cached
        }
        let url = URL(string: "\(baseURL)/objects/\(id)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let result = try JSONDecoder().decode(MetArtworkResponse.self, from: data)
        await ArtworkCache.shared.set(result, forKey: key)
        return result
    }

    static func search(query: String, isHighlight: Bool = true) async throws -> MetSearchResponse {
        var components = URLComponents(string: "\(baseURL)/search")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "hasImages", value: "true"),
        ]
        if isHighlight { components.queryItems?.append(URLQueryItem(name: "isHighlight", value: "true")) }

        let key = "search-\(components.url!.query ?? query)"
        if let cached = await ArtworkCache.shared.get(MetSearchResponse.self, forKey: key) {
            return cached
        }
        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let result = try JSONDecoder().decode(MetSearchResponse.self, from: data)
        await ArtworkCache.shared.set(result, forKey: key)
        return result
    }

    static func highlightArtworks(query: String, limit: Int = 10, isHighlight: Bool = true) async throws -> [MetArtworkResponse] {
        let searchResult = try await search(query: query, isHighlight: isHighlight)
        guard let ids = searchResult.objectIDs, !ids.isEmpty else { return [] }
        let selected = Array(ids.prefix(min(limit, 30)))
        return try await fetchBatch(ids: selected)
    }

    static func artworksByQueries(_ queries: [String], limitPerQuery: Int = 10) async -> [MetArtworkResponse] {
        await withTaskGroup(of: [MetArtworkResponse].self) { group in
            for query in queries {
                group.addTask {
                    // isHighlight=true で試み、空なら isHighlight=false にフォールバック
                    if let r = try? await highlightArtworks(query: query, limit: limitPerQuery), !r.isEmpty {
                        return r
                    }
                    return (try? await highlightArtworks(query: query, limit: limitPerQuery, isHighlight: false)) ?? []
                }
            }
            var results: [MetArtworkResponse] = []
            for await batch in group { results.append(contentsOf: batch) }
            return results
        }
    }

    private static func fetchBatch(ids: [Int]) async throws -> [MetArtworkResponse] {
        var results: [MetArtworkResponse] = []
        let batchSize = 10
        for start in stride(from: 0, to: ids.count, by: batchSize) {
            let batch = Array(ids[start..<min(start + batchSize, ids.count)])
            let batchResults = await withTaskGroup(of: MetArtworkResponse?.self) { group in
                for id in batch {
                    group.addTask { try? await artwork(id: id) }
                }
                var out: [MetArtworkResponse] = []
                for await item in group { if let r = item { out.append(r) } }
                return out
            }
            results.append(contentsOf: batchResults)
            if start + batchSize < ids.count {
                try await Task.sleep(nanoseconds: 20_000_000)
            }
        }
        return results.filter { !$0.primaryImage.isEmpty && $0.isPublicDomain }
    }
}
