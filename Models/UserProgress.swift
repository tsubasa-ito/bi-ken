import Foundation
import Observation

@MainActor
@Observable
final class UserProgress {
    static let shared = UserProgress()

    private let userDefaults: UserDefaults
    private let now: () -> Date
    private(set) var level: Int
    private(set) var currentXP: Int
    private(set) var totalArtworksMet: Int
    private(set) var totalCorrectAnswers: Int
    private(set) var totalCertificates: Int
    private(set) var currentStreak: Int
    private(set) var wrongArtworkIDs: [String]
    private(set) var studyDateStrings: [String]
    private(set) var userName: String
    private(set) var dailyGoal: Int
    private(set) var todayArtworksMet: Int
    private(set) var todayDateString: String
    private(set) var bookmarkedArtworkIDs: [String]

    private static let dateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        return f
    }()

    var hasMissedQuestions: Bool { !wrongArtworkIDs.isEmpty }
    var hasBookmarks: Bool { !bookmarkedArtworkIDs.isEmpty }

    func isBookmarked(_ artworkID: String) -> Bool {
        bookmarkedArtworkIDs.contains(artworkID)
    }

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

    private convenience init() {
        self.init(userDefaults: .standard)
    }

    init(userDefaults: UserDefaults, now: @escaping () -> Date = { Date() }) {
        self.userDefaults = userDefaults
        self.now = now
        level                = (userDefaults.value(forKey: "level")                as? Int) ?? 1
        currentXP            = (userDefaults.value(forKey: "currentXP")            as? Int) ?? 0
        totalArtworksMet     = (userDefaults.value(forKey: "totalArtworksMet")     as? Int) ?? 0
        totalCorrectAnswers  = (userDefaults.value(forKey: "totalCorrectAnswers")  as? Int) ?? 0
        totalCertificates    = (userDefaults.value(forKey: "totalCertificates")    as? Int) ?? 0
        currentStreak        = (userDefaults.value(forKey: "currentStreak")        as? Int) ?? 0
        wrongArtworkIDs      = userDefaults.stringArray(forKey: "wrongArtworkIDs") ?? []
        studyDateStrings     = userDefaults.stringArray(forKey: "studyDateStrings") ?? []
        userName             = userDefaults.string(forKey: "userName") ?? ""
        dailyGoal            = (userDefaults.value(forKey: "dailyGoal")            as? Int) ?? 10
        todayArtworksMet     = (userDefaults.value(forKey: "todayArtworksMet")     as? Int) ?? 0
        todayDateString      = userDefaults.string(forKey: "todayDateString") ?? ""
        bookmarkedArtworkIDs = userDefaults.stringArray(forKey: "bookmarkedArtworkIDs") ?? []

        let today = UserProgress.dateFormatter.string(from: now())
        if todayDateString != today {
            todayArtworksMet = 0
            todayDateString = today
            userDefaults.set(0, forKey: "todayArtworksMet")
            userDefaults.set(today, forKey: "todayDateString")
        }
    }

    func recordQuizResult(correct: Int, total: Int) {
        let today = UserProgress.dateFormatter.string(from: now())
        if todayDateString == today {
            todayArtworksMet += total
        } else {
            todayArtworksMet = total
            todayDateString = today
        }
        totalArtworksMet += total
        totalCorrectAnswers += correct
        let rawXP = currentXP + correct * 5
        let levelsGained = rawXP / 100
        if levelsGained > 0 {
            level += levelsGained
            totalCertificates += levelsGained
        }
        currentXP = rawXP % 100
        updateStreak()
        recordStudyDate()
        save()
    }

    func recordWrongAnswer(artworkID: String) {
        guard !wrongArtworkIDs.contains(artworkID) else { return }
        wrongArtworkIDs.append(artworkID)
        save()
    }

    func updateUserName(_ name: String) {
        userName = name
        save()
    }

    func updateDailyGoal(_ goal: Int) {
        dailyGoal = goal
        save()
    }

    func reset() {
        level = 1
        currentXP = 0
        totalArtworksMet = 0
        totalCorrectAnswers = 0
        totalCertificates = 0
        currentStreak = 0
        wrongArtworkIDs = []
        studyDateStrings = []
        bookmarkedArtworkIDs = []
        todayArtworksMet = 0
        todayDateString = ""
        userDefaults.removeObject(forKey: "lastStudyDate")
        save()
    }

    func toggleBookmark(artworkID: String) {
        if bookmarkedArtworkIDs.contains(artworkID) {
            bookmarkedArtworkIDs.removeAll { $0 == artworkID }
        } else {
            bookmarkedArtworkIDs.append(artworkID)
        }
        save()
    }

    func markCorrect(artworkID: String) {
        wrongArtworkIDs.removeAll { $0 == artworkID }
        save()
    }

    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: now())
        if let last = userDefaults.object(forKey: "lastStudyDate") as? Date {
            let lastDay = Calendar.current.startOfDay(for: last)
            if lastDay == today { return }
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            guard diff > 0 else { return }
            currentStreak = diff == 1 ? currentStreak + 1 : 1
        } else {
            currentStreak = 1
        }
        userDefaults.set(now(), forKey: "lastStudyDate")
    }

    private func recordStudyDate() {
        let todayStr = UserProgress.dateFormatter.string(from: now())
        guard !studyDateStrings.contains(todayStr) else { return }
        studyDateStrings.append(todayStr)
        if studyDateStrings.count > 28 {
            studyDateStrings = Array(studyDateStrings.suffix(28))
        }
    }

    private func save() {
        userDefaults.set(level,               forKey: "level")
        userDefaults.set(currentXP,           forKey: "currentXP")
        userDefaults.set(totalArtworksMet,    forKey: "totalArtworksMet")
        userDefaults.set(totalCorrectAnswers, forKey: "totalCorrectAnswers")
        userDefaults.set(totalCertificates,   forKey: "totalCertificates")
        userDefaults.set(currentStreak,       forKey: "currentStreak")
        userDefaults.set(wrongArtworkIDs,     forKey: "wrongArtworkIDs")
        userDefaults.set(studyDateStrings,    forKey: "studyDateStrings")
        userDefaults.set(userName,            forKey: "userName")
        userDefaults.set(dailyGoal,           forKey: "dailyGoal")
        userDefaults.set(todayArtworksMet,    forKey: "todayArtworksMet")
        userDefaults.set(todayDateString,     forKey: "todayDateString")
        userDefaults.set(bookmarkedArtworkIDs, forKey: "bookmarkedArtworkIDs")
    }
}
