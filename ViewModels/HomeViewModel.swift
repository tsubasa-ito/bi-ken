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

        let pool = TextbookArtworkData.all
        guard !pool.isEmpty else {
            error = "作品データの読み込みに失敗しました"
            isLoading = false
            return
        }

        let today = Date()
        let cal = Calendar.current
        let daySeed = cal.component(.year, from: today) * 366
            + cal.component(.month, from: today) * 31
            + cal.component(.day, from: today)
        let dailyTextbook = pool[daySeed % pool.count]

        var dailyImageURL: URL? = nil
        if let wikiTitle = dailyTextbook.wikiTitle {
            dailyImageURL = await WikipediaImageService.shared.imageURL(
                wikiTitle: wikiTitle, lang: dailyTextbook.wikiLang)
        }

        dailyArtwork = dailyTextbook.asArtwork(imageURL: dailyImageURL)
        featuredArtworks = pool.map { $0.asArtwork(imageURL: nil) }
        isLoading = false
    }
}
