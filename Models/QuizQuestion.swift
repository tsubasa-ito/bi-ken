import Foundation

struct QuizQuestion: Identifiable, Sendable {
    let id: String
    let artwork: Artwork
    let question: String
    let options: [String]
    let correctAnswer: String

    init(id: String, artwork: Artwork, question: String, options: [String], correctAnswer: String) {
        precondition(options.contains(correctAnswer), "correctAnswer must be in options")
        precondition(options.count == 4, "QuizQuestion requires exactly 4 options")
        self.id = id
        self.artwork = artwork
        self.question = question
        self.options = options
        self.correctAnswer = correctAnswer
    }
}

struct AnswerRecord: Sendable {
    let question: QuizQuestion
    let selectedAnswer: String
    var isCorrect: Bool { selectedAnswer == question.correctAnswer }
}
