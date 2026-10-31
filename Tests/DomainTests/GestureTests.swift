import Testing

@testable import IgnacioCore

@Test func swipeUsesTouchDownTimeAndEmitsOnlyOnce() {
    var input = GestureInput(startTime: 2.3, commandID: 4)
    let action = input.update(x: 3, y: -19, at: 2.48)
    #expect(action?.move == .shoot)
    #expect(action?.time == 2.3)
    #expect(action?.commandID == 4)
    #expect(input.update(x: 2, y: 0, at: 2.5) == nil)
    #expect(input.end(x: 0, y: 0, at: 2.6) == nil)
}
@Test(arguments: [-20.0, 20.0]) func eitherHorizontalDirectionWorks(x: Double) {
    var input = GestureInput(startTime: 0, commandID: 0)
    #expect(input.update(x: x, y: 2, at: 0.08)?.move == .behind)
}
@Test func tapToleratesJitterButNotAHoldOrDiagonalDrag() {
    var tap = GestureInput(startTime: 1, commandID: 0)
    #expect(tap.end(x: 5, y: 3, at: 1.12)?.move == .dribble)
    var hold = GestureInput(startTime: 1, commandID: 0)
    #expect(hold.end(x: 0, y: 0, at: 1.5) == nil)
    var diagonal = GestureInput(startTime: 1, commandID: 0)
    #expect(diagonal.update(x: 18, y: 18, at: 1.1) == nil)
    #expect(diagonal.end(x: 0, y: 0, at: 1.2) == nil)
}
@Test func shortDownSwipeIsNotMistakenForTap() {
    var input = GestureInput(startTime: 0, commandID: 0)
    #expect(input.end(x: 0, y: 16, at: 0.1)?.move == .between)
}
@Test func inFlightGestureCanFinishAfterWindowWithoutLosingLife() {
    var game = RhythmGame(tutorial: false)
    let start = game.timing.acceptedTimes.upperBound - 0.01
    game.beginTouch(at: start)
    game.advance(to: start + 0.2)
    #expect(game.index == 0)
    #expect(game.lives == 3)
    #expect(game.perform(.dribble, at: start, commandID: 0) == .good)
    #expect(game.lives == 3)
}
@Test func abandonedTouchCannotKeepCommandAliveForever() {
    var game = RhythmGame(tutorial: false)
    let start = game.timing.acceptedTimes.upperBound
    game.beginTouch(at: start)
    game.advance(to: start + GestureInput.maximumDuration + 0.001)
    #expect(game.lives == 2)
    #expect(game.lastError == .missed)
    #expect(game.target - (start + GestureInput.maximumDuration) >= game.beatDuration * 3)
}
@Test func staleTouchCannotPenalizeNextCommand() {
    var game = RhythmGame(tutorial: false)
    game.advance(to: game.timing.acceptedTimes.upperBound + 0.01)
    #expect(game.perform(.shoot, at: game.target, commandID: 0) == nil)
    #expect(game.lives == 2)
    #expect(!game.resolved)
}
@Test func errorsExplainTimingAndWrongMove() {
    let original = RhythmGame(tutorial: false)
    var early = original
    _ = early.perform(.dribble, at: early.timing.acceptedTimes.lowerBound - 0.01)
    #expect(early.lastError == .early)
    var late = original
    _ = late.perform(.dribble, at: late.timing.acceptedTimes.upperBound + 0.01)
    #expect(late.lastError == .late)
    var wrong = original
    _ = wrong.perform(.shoot, at: wrong.target)
    #expect(wrong.lastError == .wrongMove)
}
