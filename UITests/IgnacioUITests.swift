import XCTest

final class IgnacioUITests: XCTestCase {
    @MainActor func testTutorialPauseAndReturnHome() {
        let app = XCUIApplication()
        app.launch()
        capture(app, "Home")
        app.buttons["tutorial"].tap()
        XCTAssertTrue(app.staticTexts["WARM-UP 1/4"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["WAIT FOR THE BOX"].exists)
        capture(app, "TimingTutorial")
        XCTAssertTrue(app.staticTexts["NOW — TAP"].waitForExistence(timeout: 5))
        capture(app, "TimingNow")
        app.buttons["Pause"].tap()
        XCTAssertTrue(app.buttons["resume"].exists)
        app.buttons["Back to club"].tap()
        XCTAssertTrue(app.buttons["play"].exists)
    }
    @MainActor func testMissesEndRunAndPlayAgainStartsNewRun() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["tutorial"].tap()
        XCTAssertTrue(app.buttons["playAgain"].waitForExistence(timeout: 30))
        XCTAssertEqual(app.staticTexts["finalScore"].label, "0")
        capture(app, "GameOver")
        app.buttons["playAgain"].tap()
        XCTAssertTrue(app.buttons["Pause"].exists)
        capture(app, "Gameplay")
    }
    @MainActor func testCourtRecognizesPhysicalSwipes() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["tutorial"].tap()
        let court = app.otherElements["courtGestureSurface"]
        XCTAssertTrue(court.waitForExistence(timeout: 3))
        court.swipeUp()
        XCTAssertTrue(app.staticTexts["YOU: SHOOT"].exists)
        court.swipeDown()
        XCTAssertTrue(app.staticTexts["YOU: BETWEEN THE LEGS"].exists)
        court.swipeLeft()
        XCTAssertTrue(app.staticTexts["YOU: BEHIND THE BACK"].exists)
        court.swipeRight()
        XCTAssertTrue(app.staticTexts["YOU: BEHIND THE BACK"].exists)
        capture(app, "RecognizedInput")
    }
    @MainActor func testCourtRecognizesTapOnFreshCommand() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["tutorial"].tap()
        let court = app.otherElements["courtGestureSurface"]
        XCTAssertTrue(court.waitForExistence(timeout: 3))
        court.tap()
        XCTAssertTrue(app.staticTexts["YOU: DRIBBLE"].exists)
    }
    @MainActor func testGuideAndWarmUpNavigation() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["howToPlay"].tap()
        XCTAssertTrue(app.navigationBars["How to Play"].waitForExistence(timeout: 3))
        capture(app, "HowToPlay")
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["WAIT FOR NOW"].exists)
        capture(app, "HowToPlayRhythm")
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["play"].exists)
        app.buttons["howToPlay"].tap()
        app.buttons["guidePractice"].tap()
        XCTAssertTrue(app.staticTexts["WARM-UP 1/4"].waitForExistence(timeout: 3))
        app.buttons["Pause"].tap()
        app.buttons["Back to club"].tap()
        app.buttons["howToPlay"].tap()
        app.buttons["guidePlay"].tap()
        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["WARM-UP 1/4"].exists)
    }
    @MainActor func testRewardAnimationSheet() {
        let app = XCUIApplication()
        app.launchArguments = ["--reward-review"]
        app.launch()
        XCTAssertTrue(app.staticTexts["10 · Tiny Flex"].exists)
        XCTAssertTrue(app.staticTexts["100 · Hall of Me"].exists)
        capture(app, "RewardAnimations")
    }
    @MainActor func testLaunchArtworkLayout() {
        let app = XCUIApplication()
        app.launchArguments = ["--launch-review"]
        app.launch()
        capture(app, "LaunchScreen")
    }
    @MainActor func testMovementArtSheet() {
        let app = XCUIApplication()
        app.launchArguments = ["--motion-review"]
        app.launch()
        XCTAssertTrue(app.staticTexts["MOVEMENT STUDIES"].exists)
        capture(app, "MovementStudies")
    }
    @MainActor private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
