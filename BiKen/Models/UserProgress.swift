import Foundation
import Observation

@MainActor
@Observable
final class UserProgress {
    static let shared = UserProgress()

    private(set) var level: Int
    private(set) var masteryPercentage: Int
    private(set) var totalArtworksMet: Int
    private(set) var totalCertificates: Int
    private(set) var currentStreak: Int

    var levelTitle: String {
        switch level {
        case 1:     "入門者"
        case 2:     "初級鑑賞者"
        case 3:     "中級鑑賞者"
        case 4:     "見習い鑑賞者"
        case 5:     "熟練鑑賞者"
        case 6...:  "上級鑑賞者"
        default:    "入門者"
        }
    }

    private init() {
        let ud = UserDefaults.standard
        level               = (ud.value(forKey: "level")               as? Int) ?? 1
        masteryPercentage   = (ud.value(forKey: "masteryPercentage")   as? Int) ?? 0
        totalArtworksMet    = (ud.value(forKey: "totalArtworksMet")    as? Int) ?? 0
        totalCertificates   = (ud.value(forKey: "totalCertificates")   as? Int) ?? 0
        currentStreak       = (ud.value(forKey: "currentStreak")       as? Int) ?? 0
    }

    func recordQuizResult(correct: Int, total: Int) {
        totalArtworksMet += total
        masteryPercentage = min(100, masteryPercentage + (correct == total ? 5 : 2))
        updateStreak()
        save()
    }

    private func updateStreak() {
        let ud = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: Date())
        if let last = ud.object(forKey: "lastStudyDate") as? Date {
            let lastDay = Calendar.current.startOfDay(for: last)
            if lastDay == today { return }
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            guard diff > 0 else { return }  // diff <= 0 は無視
            currentStreak = diff == 1 ? currentStreak + 1 : 1
        } else {
            currentStreak = 1
        }
        ud.set(Date(), forKey: "lastStudyDate")
    }

    private func save() {
        let ud = UserDefaults.standard
        ud.set(level,             forKey: "level")
        ud.set(masteryPercentage, forKey: "masteryPercentage")
        ud.set(totalArtworksMet,  forKey: "totalArtworksMet")
        ud.set(totalCertificates, forKey: "totalCertificates")
        ud.set(currentStreak,     forKey: "currentStreak")
    }
}
