import Foundation
import Observation

@MainActor
@Observable
final class UserProgress {
    static let shared = UserProgress()

    private(set) var level: Int
    private(set) var currentXP: Int
    private(set) var totalArtworksMet: Int
    private(set) var totalCertificates: Int
    private(set) var currentStreak: Int
    private(set) var wrongArtworkIDs: [String]
    private(set) var studyDateStrings: [String]

    var hasMissedQuestions: Bool { !wrongArtworkIDs.isEmpty }

    // XP within current level (0–99)
    var masteryPercentage: Int { currentXP }

    var levelTitle: String {
        switch level {
        case 1:     "入門者"
        case 2:     "絵の卵"
        case 3:     "絵描き志望"
        case 4:     "画学生"
        case 5:     "見習い学芸員"
        case 6:     "学芸員"
        case 7...:  "美術鑑定士"
        default:    "入門者"
        }
    }

    var nextLevelTitle: String {
        switch level {
        case 1: "絵の卵"
        case 2: "絵描き志望"
        case 3: "画学生"
        case 4: "見習い学芸員"
        case 5: "学芸員"
        default: "美術鑑定士"
        }
    }

    private init() {
        let ud = UserDefaults.standard
        level             = (ud.value(forKey: "level")           as? Int) ?? 1
        currentXP         = (ud.value(forKey: "currentXP")       as? Int) ?? 0
        totalArtworksMet  = (ud.value(forKey: "totalArtworksMet") as? Int) ?? 0
        totalCertificates = (ud.value(forKey: "totalCertificates") as? Int) ?? 0
        currentStreak     = (ud.value(forKey: "currentStreak")   as? Int) ?? 0
        wrongArtworkIDs   = ud.stringArray(forKey: "wrongArtworkIDs") ?? []
        studyDateStrings  = ud.stringArray(forKey: "studyDateStrings") ?? []
    }

    func recordQuizResult(correct: Int, total: Int) {
        totalArtworksMet += total
        let rawXP = currentXP + correct * 5
        if rawXP >= 100 {
            level += 1
            currentXP = max(0, rawXP - 100)
            totalCertificates += 1
        } else {
            currentXP = rawXP
        }
        updateStreak()
        recordStudyDate()
        save()
    }

    func recordWrongAnswer(artworkID: String) {
        guard !wrongArtworkIDs.contains(artworkID) else { return }
        wrongArtworkIDs.append(artworkID)
        save()
    }

    func markCorrect(artworkID: String) {
        wrongArtworkIDs.removeAll { $0 == artworkID }
        save()
    }

    private func updateStreak() {
        let ud = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: Date())
        if let last = ud.object(forKey: "lastStudyDate") as? Date {
            let lastDay = Calendar.current.startOfDay(for: last)
            if lastDay == today { return }
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            guard diff > 0 else { return }
            currentStreak = diff == 1 ? currentStreak + 1 : 1
        } else {
            currentStreak = 1
        }
        ud.set(Date(), forKey: "lastStudyDate")
    }

    private func recordStudyDate() {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let todayStr = formatter.string(from: Date())
        guard !studyDateStrings.contains(todayStr) else { return }
        studyDateStrings.append(todayStr)
        if studyDateStrings.count > 28 {
            studyDateStrings = Array(studyDateStrings.suffix(28))
        }
    }

    private func save() {
        let ud = UserDefaults.standard
        ud.set(level,             forKey: "level")
        ud.set(currentXP,         forKey: "currentXP")
        ud.set(totalArtworksMet,  forKey: "totalArtworksMet")
        ud.set(totalCertificates, forKey: "totalCertificates")
        ud.set(currentStreak,     forKey: "currentStreak")
        ud.set(wrongArtworkIDs,   forKey: "wrongArtworkIDs")
        ud.set(studyDateStrings,  forKey: "studyDateStrings")
    }
}
