import Foundation
import Observation

@MainActor
@Observable
final class QuizViewModel {
    var questions: [QuizQuestion] = []
    var isLoading = true
    var error: String?
    var currentIndex = 0
    var selectedAnswer: String?
    var showResult = false
    var correctCount = 0
    var isCompleted = false
    var answerRecords: [AnswerRecord] = []

    var currentQuestion: QuizQuestion? { questions[safe: currentIndex] }
    var totalQuestions: Int { questions.count }
    var progress: Double { totalQuestions > 0 ? Double(currentIndex + 1) / Double(totalQuestions) : 0 }

    func load(era: Era?) async {
        isLoading = true
        error = nil
        reset()
        do {
            let queries: [String]
            if let era {
                queries = Array(era.searchQueries.shuffled().prefix(4))
            } else {
                queries = Array([Era.renaissance, .baroque, .impressionism]
                    .flatMap { $0.searchQueries }.shuffled().prefix(4))
            }
            let raw = await MetMuseumAPIService.artworksByQueries(queries, limitPerQuery: 10)
            let artworks = convertArtworks(raw)
            questions = try generateQuiz(from: artworks, count: 10)
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                self.error = "インターネットに接続されていません"
            case .timedOut:
                self.error = "接続がタイムアウトしました。再試行してください"
            default:
                self.error = "作品の読み込みに失敗しました"
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func selectAnswer(_ answer: String) {
        guard selectedAnswer == nil, let question = currentQuestion else { return }
        selectedAnswer = answer
        showResult = true
        let correct = answer == question.correctAnswer
        if correct { correctCount += 1 }
        answerRecords.append(AnswerRecord(question: question, selectedAnswer: answer))
    }

    func nextQuestion() {
        if currentIndex < totalQuestions - 1 {
            currentIndex += 1
            selectedAnswer = nil
            showResult = false
        } else {
            isCompleted = true
        }
    }

    func scoreMessage() -> (title: String, subtitle: String) {
        let pct = totalQuestions > 0 ? Double(correctCount) / Double(totalQuestions) * 100 : 0
        switch pct {
        case 100:       return ("完璧！", "全問正解です。素晴らしい美術知識ですね。")
        case 80...:     return ("素晴らしい！", "美術への深い理解が感じられます。")
        case 60...:     return ("よくできました", "着実に知識が身についています。")
        case 40...:     return ("もう少し", "復習して知識を定着させましょう。")
        default:        return ("復習しましょう", "繰り返し学習で上達します。")
        }
    }

    private func reset() {
        currentIndex = 0
        selectedAnswer = nil
        showResult = false
        correctCount = 0
        isCompleted = false
        answerRecords = []
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
