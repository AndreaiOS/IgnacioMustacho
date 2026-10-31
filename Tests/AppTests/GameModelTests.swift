import AVFoundation
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
    var voiceEnabled = true
    func setVoiceEnabled(_ enabled: Bool) { voiceEnabled = enabled }
    func startArena() { onStart() }
    func cue(_ move: Move, delay: Double, beatDuration: Double) { cues += 1 }
    func hit() {}
    func celebrate(_ threshold: Int) { awards.append(threshold) }
    func finish() { finishes += 1 }
    func stop() {}
}
@MainActor private final class RecordingVoice: AVSpeechSynthesizer {
    var spoken: [String] = []
    var stops = 0
    override func speak(_ utterance: AVSpeechUtterance) { spoken.append(utterance.speechString) }
    override func stopSpeaking(at boundary: AVSpeechBoundary) -> Bool {
        stops += 1
        return true
    }
}
@MainActor final class GameModelTests: XCTestCase {
    func testGameOverStopsVoiceWithoutReadingTheEndingQuote() {
        let voice = RecordingVoice()
        let audio = SynthAudio(voice: voice)
        audio.cue(.dribble, delay: 0, beatDuration: 0.6)
        let previousStops = voice.stops
        audio.finish()
        XCTAssertEqual(voice.spoken, [Move.dribble.rawValue])
        XCTAssertGreaterThan(voice.stops, previousStops)
        audio.stop()
    }
    func testGameplayStillAnnouncesAllFourMoves() {
        let voice = RecordingVoice()
        let audio = SynthAudio(voice: voice)
        for move in [Move.dribble, .between, .behind, .shoot] {
            audio.cue(move, delay: 0, beatDuration: 0.6)
        }
        XCTAssertEqual(voice.spoken, [Move.dribble.rawValue, "Between", "Behind", Move.shoot.rawValue])
        audio.stop()
    }

    func testSpokenCallsCanBeDisabledAndEnabledWithoutReadingFinale() {
        let voice = RecordingVoice()
        let audio = SynthAudio(voice: voice)
        audio.setVoiceEnabled(false)
        audio.cue(.shoot, delay: 0, beatDuration: 0.1875)
        XCTAssertTrue(voice.spoken.isEmpty)
        XCTAssertGreaterThan(voice.stops, 0)
        audio.setVoiceEnabled(true)
        audio.cue(.between, delay: 0, beatDuration: 0.1875)
        audio.finish()
        XCTAssertEqual(voice.spoken, ["Between"])
        audio.stop()
    }
    func testAudioPreferencesSurviveModelRecreationAndMasterMuteKeepsVoiceChoice() throws {
        let name = "Ignacio.AudioTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let store = LocalAudioPreferences(defaults: defaults)
        XCTAssertEqual(store.load(), AudioPreferences())
        let audio = SilentAudio()
        let first = GameModel(
            records: MemoryRecords(), audio: audio, leaderboard: LeaderboardService(), preferences: store, clock: { 0 })
        first.voiceEnabled = false
        first.soundEnabled = false
        XCTAssertFalse(audio.voiceEnabled)
        let second = GameModel(
            records: MemoryRecords(), audio: SilentAudio(), leaderboard: LeaderboardService(), preferences: store,
            clock: { 0 })
        XCTAssertFalse(second.voiceEnabled)
        XCTAssertFalse(second.soundEnabled)
        second.soundEnabled = true
        XCTAssertFalse(second.voiceEnabled)
        XCTAssertEqual(store.load(), AudioPreferences(soundEnabled: true, voiceEnabled: false))
    }
    func testFastestAnimationVisitsAllFramesBeforeNextInputWindow() {
        let duration = 0.39
        let samples = stride(from: 0.0, through: duration + 0.02, by: 1.0 / 60).map {
            SpritePlayback.frame(at: $0, duration: duration)
        }
        XCTAssertEqual(Set(samples), Set(0..<12))
        XCTAssertEqual(SpritePlayback.frame(at: duration + 0.01, duration: duration), 0)
    }
    func testLongRunKeepsAcceleratingAcrossAllCelebrationsAndPause() {
        var clock = 1000.0
        let audio = SilentAudio()
        let model = GameModel(
            records: MemoryRecords(), audio: audio, leaderboard: LeaderboardService(), clock: { clock })
        model.play()
        for _ in 0..<140 {
            clock += model.game.target - model.now
            model.gesture(model.game.move)
            clock += model.game.timing.acceptedTimes.upperBound - model.now + 0.001
            model.tick()
            if model.celebration != nil {
                model.pause()
                clock += 30
                model.resume()
                clock += GameModel.interludeDuration + 0.01
                model.tick()
                XCTAssertNil(model.celebration)
                XCTAssertEqual(model.game.target - model.now, model.game.commandInterval, accuracy: 0.00001)
            }
            XCTAssertEqual(model.game.lives, 3)
        }
        XCTAssertEqual(audio.awards, [10, 23, 33, 50, 81, 100])
        XCTAssertEqual(model.game.paceLevel, 33)
        XCTAssertEqual(60 / model.game.beatDuration, 320, accuracy: 0.00001)
        let remaining = model.game.target - model.now
        model.pause()
        clock += 100
        model.resume()
        model.tick()
        XCTAssertEqual(model.game.target - model.now, remaining, accuracy: 0.00001)
    }
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
    func testNewBestIsEarnedAndNextRunClearsTheStamp() {
        var clock = 1000.0
        let model = GameModel(
            records: MemoryRecords(), audio: SilentAudio(), leaderboard: LeaderboardService(), clock: { clock })
        model.play()
        clock = 1000 + model.game.target
        model.gesture(model.game.move)
        XCTAssertEqual(model.pointsEarned, 2)
        clock = 1000 + model.game.timing.acceptedTimes.upperBound + 0.001
        model.tick()
        for _ in 0..<3 {
            clock = 1000 + model.game.timing.acceptedTimes.upperBound + 0.001
            model.tick()
        }
        XCTAssertTrue(model.isNewBest)
        XCTAssertEqual(model.best, 2)
        model.play()
        XCTAssertFalse(model.isNewBest)
        XCTAssertEqual(model.pointsEarned, 0)
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
