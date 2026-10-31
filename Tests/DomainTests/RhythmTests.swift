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
    #expect(game.beatDuration >= 0.36)
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
    #expect(game.timing.halfWindow == 0.28)
    #expect(abs(game.beatDuration - 0.36) < 0.000001)
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
