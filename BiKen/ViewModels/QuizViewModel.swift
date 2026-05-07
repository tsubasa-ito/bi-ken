import Foundation
import Observation

enum QuizMode: Equatable, Hashable {
    case random
    case era(Era)
    case review
    case specificIDs([String])
}

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
    private(set) var mode: QuizMode = .random

    var currentQuestion: QuizQuestion? { questions[safe: currentIndex] }
    var totalQuestions: Int { questions.count }
    var progress: Double { totalQuestions > 0 ? Double(currentIndex) / Double(totalQuestions) : 0 }
    var incorrectRecords: [AnswerRecord] { answerRecords.filter { !$0.isCorrect } }

    func load(mode: QuizMode) async {
        self.mode = mode
        isLoading = true
        error = nil
        reset()
        defer { isLoading = false }
        do {
            let raw: [MetArtworkResponse]
            switch mode {
            case .random:
                let queries = Array(Era.allCases.flatMap { $0.searchQueries }.shuffled().prefix(4))
                raw = await MetMuseumAPIService.artworksByQueries(queries, limitPerQuery: 10)

            case .era(let era):
                let queries = Array(era.searchQueries.shuffled().prefix(4))
                raw = await MetMuseumAPIService.artworksByQueries(queries, limitPerQuery: 10)

            case .review:
                let ids = UserProgress.shared.wrongArtworkIDs
                guard !ids.isEmpty else {
                    self.error = "間違えた問題はありません。すべて正解済みです！"
                    return
                }
                raw = await fetchByIDs(ids)

            case .specificIDs(let ids):
                guard !ids.isEmpty else {
                    self.error = "復習する問題がありません"
                    return
                }
                raw = await fetchByIDs(ids)
            }

            let artworks = convertArtworks(raw)
            questions = try generateQuiz(from: artworks, count: 10)
        } catch is CancellationError {
            return
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
            self.error = "データの読み込みに失敗しました。しばらく待ってから再試行してください"
        }
    }

    func selectAnswer(_ answer: String) {
        guard selectedAnswer == nil, let question = currentQuestion else { return }
        selectedAnswer = answer
        showResult = true
        let correct = answer == question.correctAnswer
        if correct {
            correctCount += 1
            UserProgress.shared.markCorrect(artworkID: question.artwork.id)
        } else {
            UserProgress.shared.recordWrongAnswer(artworkID: question.artwork.id)
        }
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
        case 100:   return ("完璧！", "全問正解です。素晴らしい美術知識ですね。")
        case 80...: return ("素晴らしい！", "美術への深い理解が感じられます。")
        case 60...: return ("よくできました", "着実に知識が身についています。")
        case 40...: return ("もう少し", "復習して知識を定着させましょう。")
        default:    return ("復習しましょう", "繰り返し学習で上達します。")
        }
    }

    private func fetchByIDs(_ ids: [String]) async -> [MetArtworkResponse] {
        let intIDs = ids.compactMap { Int($0) }
        assert(intIDs.count == ids.count, "wrongArtworkIDs に非数値IDが含まれています")
        return await withTaskGroup(of: MetArtworkResponse?.self) { group in
            for id in intIDs.prefix(20) {
                group.addTask { try? await MetMuseumAPIService.artwork(id: id) }
            }
            var results: [MetArtworkResponse] = []
            for await item in group {
                if let r = item { results.append(r) }
            }
            return results
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
