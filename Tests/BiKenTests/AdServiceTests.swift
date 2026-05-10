import XCTest
@testable import BiKen

final class AdServiceTests: XCTestCase {

    func test_shouldShow_everyThirdCall() {
        var controller = AdFrequencyController(showEvery: 3)
        XCTAssertFalse(controller.shouldShow()) // 1
        XCTAssertFalse(controller.shouldShow()) // 2
        XCTAssertTrue(controller.shouldShow())  // 3
        XCTAssertFalse(controller.shouldShow()) // 4
        XCTAssertFalse(controller.shouldShow()) // 5
        XCTAssertTrue(controller.shouldShow())  // 6
    }

    func test_shouldShow_everySecondCall() {
        var controller = AdFrequencyController(showEvery: 2)
        XCTAssertFalse(controller.shouldShow()) // 1
        XCTAssertTrue(controller.shouldShow())  // 2
        XCTAssertFalse(controller.shouldShow()) // 3
        XCTAssertTrue(controller.shouldShow())  // 4
    }

    func test_shouldShow_everySingleCall() {
        var controller = AdFrequencyController(showEvery: 1)
        XCTAssertTrue(controller.shouldShow())
        XCTAssertTrue(controller.shouldShow())
        XCTAssertTrue(controller.shouldShow())
    }

    func test_reset_restartsCounting() {
        var controller = AdFrequencyController(showEvery: 3)
        _ = controller.shouldShow() // 1
        _ = controller.shouldShow() // 2
        controller.reset()
        XCTAssertFalse(controller.shouldShow()) // 1 after reset
        XCTAssertFalse(controller.shouldShow()) // 2 after reset
        XCTAssertTrue(controller.shouldShow())  // 3 after reset
    }
}
