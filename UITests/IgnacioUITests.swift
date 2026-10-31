import XCTest

final class IgnacioUITests: XCTestCase {
    @MainActor func testTutorialPauseAndReturnHome() {
        let app = XCUIApplication()
        app.launch()
        capture(app, "Home")
        app.buttons["tutorial"].tap()
        XCTAssertTrue(app.staticTexts["WARM-UP 1/4"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["WAIT FOR THE BOX"].exists)
        // Screenshot export can outlast the first hit window on a busy simulator.
        // Observe a live NOW cue before capturing, without requiring the first command.
        let nowCue = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "NOW —")).firstMatch
        XCTAssertTrue(nowCue.waitForExistence(timeout: 12))
        capture(app, "TimingNow")
        app.buttons["Pause"].tap()
        XCTAssertTrue(app.buttons["resume"].exists)
        capture(app, "Pause")
        app.buttons["Back to club"].tap()
        XCTAssertTrue(app.buttons["play"].exists)
    }
    @MainActor func testMissesEndRunAndPlayAgainStartsNewRun() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["tutorial"].tap()
        XCTAssertTrue(app.buttons["playAgain"].waitForExistence(timeout: 30))
        XCTAssertEqual(app.staticTexts["finalScore"].label, "0")
        let endingQuote = app.staticTexts["I was saving my best moves. For another game."]
        XCTAssertTrue(endingQuote.exists)
        XCTAssertGreaterThan(endingQuote.frame.height, 30, "The written ending must wrap, not truncate to one line")
        capture(app, "GameOver")
        app.buttons["playAgain"].tap()
        XCTAssertTrue(app.buttons["Pause"].exists)
        capture(app, "Gameplay")
    }
    @MainActor func testCourtRecognizesPhysicalSwipes() {
        let app = XCUIApplication()
        // Isolate physical recognition from real-time command transitions.
        // Scoring and expired-command protection have separate clock-injected tests.
        app.launchArguments = ["--pace-review"]
        app.launch()
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
        capture(app, "GestureRecognitionQA")
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
    @MainActor func testSoundCheckPersistsVoiceChoiceWithoutMutingGameAudio() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["soundCheck"].tap()
        let sound = app.switches["gameAudioToggle"]
        let voice = app.switches["voiceCallsToggle"]
        XCTAssertTrue(sound.waitForExistence(timeout: 3))
        if sound.value as? String == "0" { sound.tap() }
        if voice.value as? String == "1" { voice.tap() }
        XCTAssertEqual(voice.value as? String, "0")
        XCTAssertEqual(sound.value as? String, "1")
        capture(app, "SoundCheck")
        app.scrollViews.firstMatch.swipeUp()
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "privacyPolicy").firstMatch.isHittable)
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "supportEmail").firstMatch.isHittable)
        capture(app, "SupportAndPrivacy")
        app.terminate()
        app.launch()
        app.buttons["soundCheck"].tap()
        XCTAssertEqual(app.switches["voiceCallsToggle"].value as? String, "0")
        XCTAssertEqual(app.switches["gameAudioToggle"].value as? String, "1")
        app.switches["voiceCallsToggle"].tap()
        app.buttons["Done"].tap()
    }
    @MainActor func testClubRecordsShowLocalAwardsAndReturnHome() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["clubRecords"].tap()
        XCTAssertTrue(app.navigationBars["Club records"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["LOCAL CLUB HONOURS"].exists)
        capture(app, "ClubRecords")
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["play"].exists)
    }
    @MainActor func testProtectedMilestoneLayout() {
        let app = XCUIApplication()
        app.launchArguments = ["--milestone-review"]
        app.launch()
        XCTAssertTrue(app.staticTexts["TINY FLEX"].exists)
        XCTAssertTrue(app.buttons["Keep playing"].isHittable)
        XCTAssertFalse(app.otherElements["courtGestureSurface"].exists)
        capture(app, "Milestone10")
    }
    @MainActor func testFastestPaceKeepsTimingCueAndControlsVisible() {
        let app = XCUIApplication()
        app.launchArguments = ["--pace-review"]
        app.launch()
        XCTAssertTrue(app.staticTexts["PACE 33  /  320 BPM"].exists)
        XCTAssertTrue(app.staticTexts["timingCue"].exists)
        XCTAssertTrue(app.buttons["Shoot"].isHittable)
        capture(app, "Pace320")
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
