import Foundation
import Observation

enum QuizMode: Equatable, Hashable {
    case random
    case era(Era)
    case review
    case specificIDs([String])
    case bookmark
    case artist(String)
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

        let pool = TextbookArtworkData.all

        let selected: [TextbookArtwork]
        switch mode {
        case .random:
            selected = Array(pool.shuffled().prefix(10))

        case .era(let era):
            let filtered = pool.filter { $0.era == era }
            guard !filtered.isEmpty else {
                self.error = "この時代の作品が見つかりませんでした"
                return
            }
            selected = Array(filtered.shuffled().prefix(10))

        case .review:
            let ids = UserProgress.shared.wrongArtworkIDs
            guard !ids.isEmpty else {
                self.error = "間違えた問題はありません。すべて正解済みです！"
                return
            }
            let matched = pool.filter { ids.contains($0.id) }
            guard !matched.isEmpty else {
                self.error = "復習する作品が見つかりませんでした"
                return
            }
            selected = Array(matched.shuffled().prefix(20))

        case .specificIDs(let ids):
            guard !ids.isEmpty else {
                self.error = "復習する問題がありません"
                return
            }
            let matched = pool.filter { ids.contains($0.id) }
            guard !matched.isEmpty else {
                self.error = "指定された作品が見つかりませんでした"
                return
            }
            selected = matched

        case .bookmark:
            let ids = UserProgress.shared.bookmarkedArtworkIDs
            guard !ids.isEmpty else {
                self.error = "ブックマークした作品がありません"
                return
            }
            let matched = pool.filter { ids.contains($0.id) }
            guard !matched.isEmpty else {
                self.error = "ブックマークした作品が見つかりませんでした"
                return
            }
            selected = Array(matched.shuffled().prefix(20))

        case .artist(let artistName):
            let filtered = pool.filter { $0.artist == artistName }
            guard !filtered.isEmpty else {
                self.error = "「\(artistName)」の作品が見つかりませんでした"
                return
            }
            selected = Array(filtered.shuffled().prefix(10))
        }

        // 画像を並列フェッチ
        var fetchedImages: [String: URL] = [:]
        await withTaskGroup(of: (String, URL?).self) { group in
            for artwork in selected {
                guard let title = artwork.wikiTitle else { continue }
                let lang = artwork.wikiLang
                let id = artwork.id
                group.addTask {
                    let url = await WikipediaImageService.shared.imageURL(wikiTitle: title, lang: lang)
                    return (id, url)
                }
            }
            for await (id, url) in group {
                if let url { fetchedImages[id] = url }
            }
        }

        let artworks = selected.map { $0.asArtwork(imageURL: fetchedImages[$0.id]) }

        do {
            questions = try generateQuiz(from: artworks, count: min(10, artworks.count))
        } catch {
            self.error = "問題の生成に失敗しました"
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

    private func reset() {
        currentIndex = 0
        selectedAnswer = nil
        showResult = false
        correctCount = 0
        isCompleted = false
        answerRecords = []
    }
}
