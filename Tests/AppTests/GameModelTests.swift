import UIKit
import XCTest

@testable import Ignacio

private final class MemoryRecords: RecordStore {
    var best = 0
    func save(_ score: Int) { best = max(best, score) }
}
@MainActor private final class SilentAudio: GameAudio {
    var finishes = 0
    var cues = 0
    var awards: [Int] = []
    var onStart: () -> Void = {}
    func startArena() { onStart() }
    func cue(_ move: Move, delay: Double, beatDuration: Double) { cues += 1 }
    func hit() {}
    func celebrate(_ threshold: Int) { awards.append(threshold) }
    func finish(quote: String) { finishes += 1 }
    func stop() {}
}
@MainActor final class GameModelTests: XCTestCase {
    func testMilestoneFreezesInputAndPauseThenRestartsFullCountdown() {
        var clock = 1000.0
        let audio = SilentAudio()
        let model = GameModel(
            records: MemoryRecords(), audio: audio, leaderboard: LeaderboardService(), clock: { clock })
        model.play()
        for _ in 0..<5 {
            clock = 1000 + model.game.target
            model.gesture(model.game.move)
            clock = 1000 + model.game.timing.acceptedTimes.upperBound + 0.01
            model.tick()
        }
        XCTAssertEqual(model.game.score, 10)
        XCTAssertEqual(model.celebration?.threshold, 10)
        XCTAssertEqual(audio.awards, [10])
        let index = model.game.index
        model.gesture(.shoot)
        XCTAssertEqual(model.game.score, 10)
        XCTAssertEqual(model.game.lives, 3)
        clock += 0.4
        model.tick()
        model.pause()
        clock += 100
        model.pause()
        model.tick()
        XCTAssertEqual(model.game.index, index)
        model.resume()
        clock += 0.5
        model.tick()
        XCTAssertNotNil(model.celebration)
        clock += 0.5
        model.tick()
        XCTAssertNil(model.celebration)
        XCTAssertEqual(model.game.index, index + 1)
        XCTAssertEqual(model.game.target - model.now, model.game.beatDuration * 4, accuracy: 0.001)
        XCTAssertEqual(audio.awards, [10])
    }
    func testTutorialAndMutedRunDoNotPlayAwardSound() {
        var clock = 1000.0
        let audio = SilentAudio()
        let model = GameModel(
            records: MemoryRecords(), audio: audio, leaderboard: LeaderboardService(), clock: { clock })
        model.soundEnabled = false
        model.play()
        for _ in 0..<5 {
            clock = 1000 + model.game.target
            model.gesture(model.game.move)
            clock = 1000 + model.game.timing.acceptedTimes.upperBound + 0.01
            model.tick()
        }
        XCTAssertNotNil(model.celebration)
        XCTAssertTrue(audio.awards.isEmpty)
        model.home()
        model.play(tutorial: true)
        XCTAssertNil(model.celebration)
        XCTAssertTrue(model.earnedMilestones.isEmpty)
    }
    func testBuiltAppContainsLeaderboardConfiguration() {
        let identifier = Bundle.main.object(forInfoDictionaryKey: "IgnacioLeaderboardID") as? String
        XCTAssertNotNil(identifier)
        XCTAssertFalse(identifier?.isEmpty ?? true)
        XCTAssertFalse(identifier?.contains("$(") ?? true)
    }
    func testAudioActivationDoesNotConsumeInitialCountdown() {
        var clock = 1000.0
        let audio = SilentAudio()
        audio.onStart = { clock += 0.8 }
        let model = GameModel(
            records: MemoryRecords(), audio: audio, leaderboard: LeaderboardService(), clock: { clock })
        model.play()
        model.tick()
        XCTAssertEqual(model.now, 0, accuracy: 0.001)
    }
    func testProductionArtworkIsBundledAndAllAnimationFramesLoad() {
        XCTAssertNotNil(UIImage(named: "arena-v1"))
        XCTAssertEqual(IgnacioSprites.frames.count, 10)
        for row in IgnacioSprites.frames {
            XCTAssertEqual(row.count, 12)
            for frame in row { XCTAssertGreaterThan(frame.image.size.height, 200) }
        }
    }
    func testPlaybackVisitsEveryDrawnFrameAndReturnsToIdle() {
        let samples = stride(from: 0.0, through: 0.9, by: 0.01).map { SpritePlayback.frame(at: $0) }
        XCTAssertEqual(Set(samples), Set(0..<12))
        XCTAssertEqual(SpritePlayback.frame(at: 0.86), 0)
    }
    func testSportsFontsAreAvailableOnDevice() {
        XCTAssertNotNil(UIFont(name: "AvenirNextCondensed-Heavy", size: 32))
        XCTAssertNotNil(UIFont(name: "Menlo-Bold", size: 24))
    }
    func testTouchStartingInsideNOWIsAcceptedAfterRenderedWindowCloses() {
        var clock = 1000.0
        let model = GameModel(
            records: MemoryRecords(), audio: SilentAudio(), leaderboard: LeaderboardService(), clock: { clock })
        model.play()
        model.touchBegan(at: 1002.75)
        clock = 1002.95
        model.tick()
        XCTAssertEqual(model.game.index, 0)
        XCTAssertEqual(model.timingCue, "FINISH YOUR GESTURE")
        model.touchEnded(x: 3, y: 2, at: 1002.93)
        XCTAssertEqual(model.game.score, 1)
        XCTAssertEqual(model.game.lives, 3)
        XCTAssertEqual(model.feedback, "GOOD")
    }
    func testSwipeScoresAtThresholdAndReleaseDoesNotSubmitSecondAction() {
        var clock = 1000.0
        let model = GameModel(
            records: MemoryRecords(), audio: SilentAudio(), leaderboard: LeaderboardService(), clock: { clock })
        model.play()
        clock = 1000 + model.game.target
        model.gesture(.dribble)
        clock = 1000 + model.game.timing.acceptedTimes.upperBound + 0.01
        model.tick()
        clock = 1000 + model.game.target
        model.touchBegan(at: clock)
        model.touchMoved(x: 2, y: 16, at: clock + 0.08)
        XCTAssertEqual(model.game.score, 4)
        model.touchEnded(x: 0, y: 0, at: clock + 0.2)
        XCTAssertEqual(model.game.score, 4)
        XCTAssertEqual(model.game.lives, 3)
    }
    func testExpiredContactCannotBecomeWrongMoveOnNextCommand() {
        var clock = 1000.0
        let model = GameModel(
            records: MemoryRecords(), audio: SilentAudio(), leaderboard: LeaderboardService(), clock: { clock })
        model.play()
        let start = 1000 + model.game.target
        model.touchBegan(at: start)
        clock = start + 0.9
        model.tick()
        XCTAssertEqual(model.game.index, 1)
        model.touchEnded(x: -100, y: 0, at: clock)
        XCTAssertEqual(model.game.lives, 2)
        XCTAssertFalse(model.game.resolved)
    }
    func testGameOverPlaysFinaleOnlyOnce() {
        var clock = 1000.0
        let audio = SilentAudio()
        let model = GameModel(
            records: MemoryRecords(), audio: audio, leaderboard: LeaderboardService(), clock: { clock })
        model.play()
        for _ in 0..<3 {
            clock = 1000 + model.game.timing.acceptedTimes.upperBound + 0.01
            model.tick()
        }
        model.tick()
        XCTAssertEqual(audio.finishes, 1)
        XCTAssertEqual(model.screen, .results)
    }
}
