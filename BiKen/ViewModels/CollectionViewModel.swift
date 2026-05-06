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
            queries = Array(era.searchQueries.shuffled().prefix(3))
        } else {
            queries = Array(Era.allCases.flatMap { $0.searchQueries }.shuffled().prefix(3))
        }

        // 各クエリを並列実行し、完了した順に逐次追加する
        var seen = Set<String>()
        await withTaskGroup(of: [Artwork].self) { group in
            for query in queries {
                group.addTask {
                    let raw = (try? await MetMuseumAPIService.highlightArtworks(query: query, limit: 5)) ?? []
                    return convertArtworks(raw)
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
}
