import XCTest
@testable import BiKen

final class QuizQuestionTests: XCTestCase {

    private func makeArtwork() -> Artwork {
        Artwork(
            id: "test-001",
            title: "The Starry Night",
            titleJa: "星月夜",
            artist: "Vincent van Gogh",
            artistJa: "フィンセント・ファン・ゴッホ",
            artistOriginal: "Vincent van Gogh",
            year: 1889,
            medium: "oil on canvas",
            movement: "Post-Impressionism",
            era: .impressionism,
            imageURL: nil,
            description: "Test description",
            artistBio: nil,
            difficulty: .medium
        )
    }

    private func makeQuestion() -> QuizQuestion {
        QuizQuestion(
            id: "q-001",
            artwork: makeArtwork(),
            question: "この作品の作者は？",
            options: ["Vincent van Gogh", "Claude Monet", "Pablo Picasso", "Rembrandt"],
            correctAnswer: "Vincent van Gogh"
        )
    }

    func testInit_validInputSucceeds() {
        let question = makeQuestion()
        XCTAssertEqual(question.correctAnswer, "Vincent van Gogh")
        XCTAssertEqual(question.options.count, 4)
        XCTAssertTrue(question.options.contains(question.correctAnswer))
    }

    func testAnswerRecord_isCorrect() {
        let record = AnswerRecord(question: makeQuestion(), selectedAnswer: "Vincent van Gogh")
        XCTAssertTrue(record.isCorrect)
    }

    func testAnswerRecord_isIncorrect() {
        let record = AnswerRecord(question: makeQuestion(), selectedAnswer: "Claude Monet")
        XCTAssertFalse(record.isCorrect)
    }
}
