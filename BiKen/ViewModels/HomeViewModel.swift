import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    var featuredArtworks: [Artwork] = []
    var dailyArtwork: Artwork?
    var isLoading = true
    var error: String?

    func load() async {
        isLoading = true
        error = nil

        let queries = [
            Era.impressionism.searchQueries,
            Era.renaissance.searchQueries,
            Era.baroque.searchQueries,
        ].flatMap { $0 }.shuffled().prefix(4)

        let raw = await MetMuseumAPIService.artworksByQueries(Array(queries), limitPerQuery: 10)
        let artworks = convertArtworks(raw)
        let sorted = artworks.sorted { $0.id < $1.id }
        featuredArtworks = sorted

        if !sorted.isEmpty {
            let today = Date()
            let daySeed = Calendar.current.component(.year, from: today) * 366
                + Calendar.current.component(.month, from: today) * 31
                + Calendar.current.component(.day, from: today)
            dailyArtwork = sorted[daySeed % sorted.count]
        } else {
            print("[HomeViewModel] load() returned no artworks")
            error = "作品の読み込みに失敗しました"
        }

        isLoading = false
    }
}
