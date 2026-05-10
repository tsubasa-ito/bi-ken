import XCTest
@testable import BiKen

@MainActor
final class UserProgressTests: XCTestCase {

    private var suiteName: String!
    private var userDefaults: UserDefaults!
    private var sut: UserProgress!

    override func setUp() {
        super.setUp()
        suiteName = UUID().uuidString
        userDefaults = UserDefaults(suiteName: suiteName)!
        sut = UserProgress(userDefaults: userDefaults)
    }

    override func tearDown() {
        sut = nil
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testRecordQuizResult_xpAccumulates() {
        sut.recordQuizResult(correct: 4, total: 5)
        XCTAssertEqual(sut.currentXP, 20)
    }

    func testRecordQuizResult_levelUp() {
        sut.recordQuizResult(correct: 20, total: 20)
        XCTAssertEqual(sut.level, 2)
        XCTAssertEqual(sut.currentXP, 0)
    }

    func testRecordQuizResult_certificateOnLevelUp() {
        sut.recordQuizResult(correct: 20, total: 20)
        XCTAssertEqual(sut.totalCertificates, 1)
    }

    func testStreak_incrementsOnConsecutiveDays() {
        let fixedToday = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: fixedToday)!
        userDefaults.set(3, forKey: "currentStreak")
        userDefaults.set(yesterday, forKey: "lastStudyDate")
        sut = UserProgress(userDefaults: userDefaults, now: { fixedToday })

        sut.recordQuizResult(correct: 1, total: 1)
        XCTAssertEqual(sut.currentStreak, 4)
    }

    func testStreak_resetsOnMissedDay() {
        let fixedToday = Calendar.current.startOfDay(for: Date())
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: fixedToday)!
        userDefaults.set(5, forKey: "currentStreak")
        userDefaults.set(twoDaysAgo, forKey: "lastStudyDate")
        sut = UserProgress(userDefaults: userDefaults, now: { fixedToday })

        sut.recordQuizResult(correct: 1, total: 1)
        XCTAssertEqual(sut.currentStreak, 1)
    }

    func testRecordWrongAnswer_noDuplicate() {
        sut.recordWrongAnswer(artworkID: "textbook-001")
        sut.recordWrongAnswer(artworkID: "textbook-001")
        XCTAssertEqual(sut.wrongArtworkIDs.count, 1)
    }

    func testMarkCorrect_removesFromWrongIDs() {
        sut.recordWrongAnswer(artworkID: "textbook-001")
        sut.markCorrect(artworkID: "textbook-001")
        XCTAssertFalse(sut.wrongArtworkIDs.contains("textbook-001"))
    }

    func testToggleBookmark_addAndRemove() {
        sut.toggleBookmark(artworkID: "textbook-001")
        XCTAssertTrue(sut.isBookmarked("textbook-001"))
        sut.toggleBookmark(artworkID: "textbook-001")
        XCTAssertFalse(sut.isBookmarked("textbook-001"))
    }

    func testReset_clearsAllState() {
        sut.recordQuizResult(correct: 5, total: 10)
        sut.recordWrongAnswer(artworkID: "textbook-001")
        sut.toggleBookmark(artworkID: "textbook-002")

        sut.reset()

        XCTAssertEqual(sut.level, 1)
        XCTAssertEqual(sut.currentXP, 0)
        XCTAssertEqual(sut.totalArtworksMet, 0)
        XCTAssertEqual(sut.totalCorrectAnswers, 0)
        XCTAssertEqual(sut.totalCertificates, 0)
        XCTAssertEqual(sut.currentStreak, 0)
        XCTAssertTrue(sut.wrongArtworkIDs.isEmpty)
        XCTAssertTrue(sut.bookmarkedArtworkIDs.isEmpty)
    }
}
