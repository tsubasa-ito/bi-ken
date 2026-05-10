import XCTest
@testable import BiKen

final class TextbookArtworkDataTests: XCTestCase {

    func testAll_countIs100() {
        XCTAssertEqual(TextbookArtworkData.all.count, 100)
    }

    func testAll_idsAreUnique() {
        let ids = TextbookArtworkData.all.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    func testAll_idFormat() {
        let prefix = "textbook-"
        for artwork in TextbookArtworkData.all {
            XCTAssertTrue(artwork.id.hasPrefix(prefix), "\(artwork.id) はtextbook-XXX形式ではありません")
            let suffix = artwork.id.dropFirst(prefix.count)
            XCTAssertNotNil(Int(suffix), "\(artwork.id) のサフィックスが数値ではありません")
        }
    }

    func testAll_wikiLangIsValid() {
        let validLangs: Set<String> = ["en", "ja"]
        for artwork in TextbookArtworkData.all {
            XCTAssertTrue(
                validLangs.contains(artwork.wikiLang),
                "不正なwikiLang: \(artwork.wikiLang) (\(artwork.id))"
            )
        }
    }

    func testAll_eraMapping() {
        for artwork in TextbookArtworkData.all {
            let era = artwork.era
            XCTAssertTrue(
                Era.allCases.contains(era),
                "\(artwork.id) の periodJa '\(artwork.periodJa)' が Era にマップされていません"
            )
        }
    }
}
