import Foundation
import Observation

@MainActor
@Observable
final class CollectionViewModel {
    var artworks: [Artwork] = []
    var isLoading = false
    var error: String?
    var selectedEra: Era?

    func load(era: Era? = nil) async {
        isLoading = true
        artworks = []
        error = nil
        selectedEra = era

        let queries: [String]
        if let era {
            queries = Array(era.searchQueries.shuffled().prefix(5))
        } else {
            queries = Array(Era.allCases.flatMap { $0.searchQueries }.shuffled().prefix(5))
        }

        // 各クエリを並列実行し、完了した順に逐次追加する
        var seen = Set<String>()
        await withTaskGroup(of: [Artwork].self) { group in
            for query in queries {
                group.addTask {
                    await Self.fetchArtworks(query: query)
                }
            }
            for await batch in group {
                let unique = batch.filter { seen.insert($0.id).inserted }
                artworks.append(contentsOf: unique)
                if isLoading { isLoading = false }   // 最初のバッチが届いた時点でローディングを解除
            }
        }

        if artworks.isEmpty { error = "コレクションの読み込みに失敗しました" }
        isLoading = false
    }

    private static func fetchArtworks(query: String) async -> [Artwork] {
        // isHighlight=true で試み、結果が空なら isHighlight=false にフォールバック
        if let raw = try? await MetMuseumAPIService.highlightArtworks(query: query, limit: 20), !raw.isEmpty {
            let converted = convertArtworks(raw)
            if !converted.isEmpty { return converted }
        }
        let fallback = (try? await MetMuseumAPIService.highlightArtworks(query: query, limit: 20, isHighlight: false)) ?? []
        return convertArtworks(fallback)
    }
}
