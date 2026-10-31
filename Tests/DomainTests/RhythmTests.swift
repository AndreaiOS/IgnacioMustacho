import Testing

@testable import IgnacioCore

@Test func exactBeatIsPerfectAndScores() {
    var game = RhythmGame(tutorial: false)
    let result = game.perform(game.move, at: game.target)
    #expect(result == .perfect)
    #expect(game.score == 2)
    #expect(game.combo == 1)
}
@Test func wrongGestureCostsOnlyOneLife() {
    var game = RhythmGame(tutorial: false)
    #expect(game.perform(.shoot, at: game.target) == .miss)
    #expect(game.lives == 2)
    #expect(game.perform(.shoot, at: game.target) == nil)
    #expect(game.lives == 2)
}
@Test func threeMissesEndRun() {
    var game = RhythmGame(tutorial: false)
    for _ in 0..<3 { game.advance(to: game.timing.acceptedTimes.upperBound + 0.001) }
    #expect(game.isOver)
    #expect(game.lives == 0)
}
@Test func tutorialNeverLosesLivesAndCoversEveryMove() {
    var game = RhythmGame(tutorial: true)
    var moves: [Move] = []
    for _ in 0..<4 {
        moves.append(game.move)
        game.advance(to: game.timing.acceptedTimes.upperBound + 0.001)
    }
    #expect(moves == Move.allCases)
    #expect(game.lives == 3)
    #expect(game.isOver)
}
@Test func earlyInputAndTimingBoundaries() {
    var game = RhythmGame(tutorial: false)
    #expect(game.perform(.dribble, at: 0) == nil)
    #expect(game.perform(.dribble, at: game.target + 0.15) == .good)
    game.advance(to: game.timing.acceptedTimes.upperBound + 0.001)
    #expect(game.perform(.shoot, at: game.target) == .miss)
    #expect(game.combo == 0)
}
@Test func tempoIncreasesButRemainsPlayable() {
    var game = RhythmGame(tutorial: false)
    let initial = game.beatDuration
    for _ in 0..<200 {
        _ = game.perform(game.move, at: game.target)
        game.advance(to: game.timing.acceptedTimes.upperBound + 0.001)
    }
    #expect(game.beatDuration < initial)
    #expect(game.beatDuration >= 60.0 / 320)
    #expect(game.lives == 3)
}

@Test(arguments: [-0.35, 0.35])
func openingRunAcceptsMoreForgivingTiming(offset: Double) {
    var game = RhythmGame(tutorial: false)
    #expect(game.perform(game.move, at: game.target + offset) == .good)
    #expect(game.lives == 3)
}

@Test(arguments: [-0.48, 0.48])
func tutorialProvidesAnEvenWiderPracticeWindow(offset: Double) {
    var game = RhythmGame(tutorial: true)
    #expect(game.perform(game.move, at: game.target + offset) == .good)
}

@Test(arguments: [true, false])
func exactWindowEdgesAreAcceptedAndOutsideEdgesMiss(tutorial: Bool) {
    let original = RhythmGame(tutorial: tutorial)
    for boundary in [original.timing.acceptedTimes.lowerBound, original.timing.acceptedTimes.upperBound] {
        var game = original
        #expect(game.perform(game.move, at: boundary) == .good)
    }
    for outside in [original.timing.acceptedTimes.lowerBound - 0.001, original.timing.acceptedTimes.upperBound + 0.001]
    {
        var game = original
        #expect(game.perform(game.move, at: outside) == .miss)
    }
}

@Test(arguments: [true, false])
func deadlineWaitsForEntireVisibleWindow(tutorial: Bool) {
    var game = RhythmGame(tutorial: tutorial)
    let deadline = game.timing.acceptedTimes.upperBound
    game.advance(to: deadline)
    #expect(game.index == 0)
    #expect(game.lives == 3)
    game.advance(to: deadline + 0.001)
    #expect(game.index == 1)
    #expect(game.lives == (tutorial ? 3 : 2))
}

@Test func drawnZoneAndAcceptanceAgreeAtEveryDifficulty() {
    for tutorial in [true, false] {
        var game = RhythmGame(tutorial: tutorial)
        for _ in 0..<(tutorial ? 4 : 160) {
            let timing = game.timing
            let start = timing.acceptedTimes.lowerBound
            let end = timing.acceptedTimes.upperBound
            #expect(timing.validZone.lowerBound > 0)
            #expect(timing.validZone.upperBound < 1)
            #expect(timing.position(at: timing.target) > timing.validZone.lowerBound)
            #expect(timing.position(at: timing.target) < timing.validZone.upperBound)
            #expect(timing.position(at: end) > timing.position(at: timing.target))
            for time in [start - 0.001, start, start + 0.001, timing.target, end - 0.001, end, end + 0.001] {
                let inside = timing.validZone.contains(timing.position(at: time))
                #expect(inside == timing.accepts(time))
                #expect(inside == game.canAct(at: time))
                var attempt = game
                let judgement = attempt.perform(attempt.move, at: time)
                #expect(inside == (judgement == .perfect || judgement == .good))
            }
            _ = game.perform(game.move, at: game.target)
            #expect(!game.canAct(at: game.target))
            game.advance(to: end + 0.001)
        }
    }
}

@Test func toleranceNarrowsGraduallyWithFasterTempo() {
    var game = RhythmGame(tutorial: false)
    #expect(game.timing.halfWindow == 0.4)
    #expect(game.beatDuration == 0.6)
    for _ in 0..<48 {
        _ = game.perform(game.move, at: game.target)
        game.advance(to: game.timing.acceptedTimes.upperBound + 0.001)
    }
    #expect(game.timing.halfWindow < 0.28)
    #expect(abs(game.beatDuration - 60.0 / 220) < 0.000001)
}

@Test func paceBecomesClearlyFasterWithinFirstSixteenCommands() {
    var game = RhythmGame(tutorial: false)
    let initial = game.beatDuration
    for _ in 0..<16 {
        _ = game.perform(game.move, at: game.target)
        game.advance(to: game.timing.acceptedTimes.upperBound + 0.001)
    }
    #expect(game.beatDuration <= initial * 0.65)
    #expect(game.target < 35)
}

@Test func fastestPaceKeepsVisibleSpaceAfterTheAcceptanceZone() {
    var game = RhythmGame(tutorial: false)
    for _ in 0..<16 {
        _ = game.perform(game.move, at: game.target)
        game.advance(to: game.timing.acceptedTimes.upperBound + 0.001)
    }
    #expect(game.timing.validZone.upperBound < 0.98)
}

@Test func tempoKeepsGrowingFarBeyondOldCeiling() {
    var game = RhythmGame(tutorial: false)
    var samples: [Int: Double] = [:]
    for index in 0...160 {
        samples[index] = 60 / game.beatDuration
        if index > 0 && index <= 128 && index % 4 == 0 {
            #expect(samples[index, default: 0] > samples[index - 4, default: 0])
        }
        let previousTarget = game.target
        game.perform(game.move, at: game.target)
        game.advance(to: game.timing.acceptedTimes.upperBound + 0.001)
        #expect(abs(game.target - previousTarget - game.beatDuration * 4) < 0.00001)
    }
    for (index, bpm) in [(0, 100.0), (16, 180), (32, 200), (64, 240), (96, 280), (128, 320), (160, 320)] {
        #expect(abs(samples[index, default: 0] - bpm) < 0.00001)
    }
    #expect(game.lives == 3)
}

@Test func lateGameGesturesFinishAfterVisibleWindowWithoutPenalty() {
    var game = RhythmGame(tutorial: false)
    for _ in 0..<128 {
        game.perform(game.move, at: game.target)
        game.advance(to: game.timing.acceptedTimes.upperBound + 0.001)
    }
    for _ in 0..<12 {
        let command = game.index
        let start = game.timing.acceptedTimes.upperBound - 0.001
        game.beginTouch(at: start)
        let duration = game.move == .dribble ? 0.2 : 0.44
        game.advance(to: start + duration)
        #expect(game.index == command)
        var gesture = GestureInput(startTime: start, commandID: command)
        let displacement: (Double, Double) =
            switch game.move {
            case .dribble: (0, 0)
            case .between: (0, 20)
            case .behind: (-20, 0)
            case .shoot: (0, -20)
            }
        let action = gesture.end(x: displacement.0, y: displacement.1, at: start + duration)
        #expect(action?.move == game.move)
        if let action { #expect(game.perform(action.move, at: action.time, commandID: action.commandID) == .good) }
        game.advance(to: start + duration + 0.001)
        #expect(game.lives == 3)
        #expect(game.target - (start + duration + 0.001) >= game.beatDuration * 3 - 0.00001)
        #expect(game.perform(.shoot, at: game.target, commandID: command) == nil)
    }
}

@Test func fastestPaceLeavesRoomForAudioAnimationAndFreshCountdown() {
    var game = RhythmGame(tutorial: false)
    for _ in 0..<160 {
        let timing = game.timing
        let rate = RhythmTiming.notePlaybackRate(duration: 0.32, beatDuration: game.beatDuration)
        #expect(0.32 / rate <= game.beatDuration * 0.9 + 0.00001)
        #expect(rate <= 2)
        #expect(game.moveAnimationDuration > 0.35)
        #expect(game.moveAnimationDuration < game.commandInterval - timing.halfWindow * 2)
        #expect(timing.perfectWindow < timing.halfWindow)
        game.perform(game.move, at: game.target)
        game.advance(to: timing.acceptedTimes.upperBound + 0.001)
        let frozen = game.target - game.beatDuration
        game.restartCountdown(from: frozen)
        #expect(abs(game.target - frozen - game.commandInterval) < 0.00001)
        #expect(!game.resolved)
    }
}
