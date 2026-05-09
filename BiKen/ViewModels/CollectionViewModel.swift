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

        let pool = TextbookArtworkData.all
        let filtered: [TextbookArtwork] = era.map { e in pool.filter { $0.era == e } } ?? pool

        // 即座にプレースホルダーで表示（画像なし）
        artworks = filtered.map { $0.asArtwork(imageURL: nil) }
        isLoading = false

        // 画像を並列フェッチして順次更新
        await withTaskGroup(of: (String, URL?).self) { group in
            for artwork in filtered {
                guard let title = artwork.wikiTitle else { continue }
                let lang = artwork.wikiLang
                let id = artwork.id
                group.addTask {
                    let url = await WikipediaImageService.shared.imageURL(wikiTitle: title, lang: lang)
                    return (id, url)
                }
            }
            for await (id, url) in group {
                guard let url else { continue }
                if let idx = artworks.firstIndex(where: { $0.id == id }),
                   let textbook = filtered.first(where: { $0.id == id }) {
                    artworks[idx] = textbook.asArtwork(imageURL: url)
                }
            }
        }

        if filtered.isEmpty { error = "この時代の作品が見つかりませんでした" }
    }
}
