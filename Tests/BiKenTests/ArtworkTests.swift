import XCTest
@testable import BiKen

@MainActor
final class ArtworkTests: XCTestCase {

    private func makeArtwork(
        title: String = "Test Title",
        titleJa: String? = nil,
        artist: String = "Test Artist",
        artistJa: String? = nil,
        medium: String = "oil on canvas"
    ) -> Artwork {
        Artwork(
            id: "test-001",
            title: title,
            titleJa: titleJa,
            artist: artist,
            artistJa: artistJa,
            artistOriginal: artist,
            year: nil,
            medium: medium,
            movement: "Test",
            era: .modernArt,
            imageURL: nil,
            description: "",
            artistBio: nil,
            difficulty: .medium
        )
    }

    func testDisplayTitle_fallsBackToTitle() {
        let artwork = makeArtwork(title: "The Starry Night", titleJa: nil)
        XCTAssertEqual(artwork.displayTitle, "The Starry Night")
    }

    func testDisplayTitle_prefersJapanese() {
        let artwork = makeArtwork(title: "The Starry Night", titleJa: "星月夜")
        XCTAssertEqual(artwork.displayTitle, "星月夜")
    }

    func testDisplayArtist_fallsBackToArtist() {
        let artwork = makeArtwork(artist: "Van Gogh", artistJa: nil)
        XCTAssertEqual(artwork.displayArtist, "Van Gogh")
    }

    func testDisplayArtist_prefersJapanese() {
        let artwork = makeArtwork(artist: "Van Gogh", artistJa: "フィンセント・ファン・ゴッホ")
        XCTAssertEqual(artwork.displayArtist, "フィンセント・ファン・ゴッホ")
    }

    func testShortMediumJa_oilReturnsOilJa() {
        let artwork = makeArtwork(medium: "oil on canvas")
        XCTAssertEqual(artwork.shortMediumJa, "油彩")
    }

    func testShortMediumJa_tempera() {
        let artwork = makeArtwork(medium: "tempera on panel")
        XCTAssertEqual(artwork.shortMediumJa, "テンペラ")
    }

    func testShortMediumJa_woodblock() {
        let artwork = makeArtwork(medium: "woodblock print")
        XCTAssertEqual(artwork.shortMediumJa, "木版画")
    }
}
