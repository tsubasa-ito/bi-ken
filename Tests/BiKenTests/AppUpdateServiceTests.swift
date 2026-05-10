import XCTest
@testable import BiKen

final class AppUpdateServiceTests: XCTestCase {

    // MARK: - isUpdateAvailable

    func testIsUpdateAvailable_patchUpdate() {
        XCTAssertTrue(AppUpdateService.isUpdateAvailable(current: "1.0.0", store: "1.0.1"))
    }

    func testIsUpdateAvailable_minorUpdate() {
        XCTAssertTrue(AppUpdateService.isUpdateAvailable(current: "1.0.0", store: "1.1.0"))
    }

    func testIsUpdateAvailable_majorUpdate() {
        XCTAssertTrue(AppUpdateService.isUpdateAvailable(current: "1.0.0", store: "2.0.0"))
    }

    func testIsUpdateAvailable_sameVersion() {
        XCTAssertFalse(AppUpdateService.isUpdateAvailable(current: "1.0.0", store: "1.0.0"))
    }

    func testIsUpdateAvailable_higherCurrentVersion() {
        XCTAssertFalse(AppUpdateService.isUpdateAvailable(current: "1.1.0", store: "1.0.0"))
    }

    func testIsUpdateAvailable_numericComparison() {
        // 辞書順では "1.9" > "1.10" になるが、数値比較では "1.9" < "1.10" が正しい
        XCTAssertTrue(AppUpdateService.isUpdateAvailable(current: "1.9.0", store: "1.10.0"))
    }

    func testIsUpdateAvailable_patchNumericComparison() {
        XCTAssertTrue(AppUpdateService.isUpdateAvailable(current: "1.0.9", store: "1.0.10"))
    }

    // MARK: - shouldCheckToday

    func testShouldCheckToday_nilLastCheck() {
        XCTAssertTrue(AppUpdateService.shouldCheckToday(lastCheckDate: nil))
    }

    func testShouldCheckToday_checkedToday() {
        XCTAssertFalse(AppUpdateService.shouldCheckToday(lastCheckDate: Date()))
    }

    func testShouldCheckToday_checkedYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertTrue(AppUpdateService.shouldCheckToday(lastCheckDate: yesterday))
    }

    func testShouldCheckToday_checkedTwoDaysAgo() {
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        XCTAssertTrue(AppUpdateService.shouldCheckToday(lastCheckDate: twoDaysAgo))
    }
}
