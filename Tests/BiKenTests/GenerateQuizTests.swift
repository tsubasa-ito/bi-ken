import XCTest
@testable import BiKen

@MainActor
final class GenerateQuizTests: XCTestCase {

    private func makeArtwork(id: String = "test-001", artist: String = "Artist A") -> Artwork {
        Artwork(
            id: id,
            title: "Test Title",
            titleJa: nil,
            artist: artist,
            artistJa: nil,
            artistOriginal: artist,
            year: nil,
            medium: "oil on canvas",
            movement: "",
            era: .modernArt,
            imageURL: nil,
            description: "",
            artistBio: nil,
            difficulty: .medium
        )
    }

    func testGenerateQuiz_withEmptyArtworks_throwsLocalizedError() {
        XCTAssertThrowsError(try generateQuiz(from: [], count: 1)) { error in
            XCTAssertEqual(error.localizedDescription, "十分な作品を取得できませんでした")
        }
    }

    func testGenerateQuiz_withSingleArtwork_throwsLocalizedError() {
        let artwork = makeArtwork()
        XCTAssertThrowsError(try generateQuiz(from: [artwork], count: 1)) { error in
            XCTAssertEqual(error.localizedDescription, "十分な作品を取得できませんでした")
        }
    }

    func testGenerateQuiz_withSufficientArtworks_returnsRequestedCount() throws {
        let artworks = (1...4).map { makeArtwork(id: "test-\($0)", artist: "Artist \($0)") }
        let questions = try generateQuiz(from: artworks, count: 3)
        XCTAssertEqual(questions.count, 3)
    }

    func testGenerateQuiz_withSufficientArtworks_eachQuestionHasFourOptions() throws {
        let artworks = (1...4).map { makeArtwork(id: "test-\($0)", artist: "Artist \($0)") }
        let questions = try generateQuiz(from: artworks, count: 4)
        for question in questions {
            XCTAssertEqual(question.options.count, 4)
            XCTAssertTrue(question.options.contains(question.correctAnswer))
        }
    }
}
