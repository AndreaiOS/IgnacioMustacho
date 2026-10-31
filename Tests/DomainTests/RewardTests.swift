import Foundation
import Testing

@testable import IgnacioCore

@Test func pointsUseSmallRewardsForApprovedMilestones() {
    var perfect = RhythmGame(tutorial: false)
    perfect.perform(.dribble, at: perfect.target)
    #expect(perfect.score == 2)
    var good = RhythmGame(tutorial: false)
    good.perform(.dribble, at: good.target + 0.2)
    #expect(good.score == 1)
}

@Test func allCrossedThresholdsFireOnceAndNewRunResets() {
    var run = RunMilestones()
    #expect(run.advance(score: 9).isEmpty)
    #expect(run.advance(score: 50).map(\.threshold) == [10, 23, 33, 50])
    #expect(run.advance(score: 50).isEmpty)
    #expect(run.advance(score: 5).isEmpty)
    #expect(run.advance(score: 120).map(\.threshold) == [81, 100])
    #expect(RunMilestones().earned.isEmpty)
}

@Test func configuredThresholdsAreHonored() {
    var run = RunMilestones(rules: [.init(4, "Test", "Test", .flex)])
    #expect(run.advance(score: 3).isEmpty)
    #expect(run.advance(score: 4).count == 1)
}

@Test func achievementPersistenceAndAcknowledgementsKeepUnsentProgress() throws {
    var ledger = AchievementLedger()
    ledger.record(id: "a", percent: 50)
    let sent = ledger.pending(for: "playerA")
    ledger.record(id: "a", percent: 100)
    ledger.acknowledge(sent, for: "playerA")
    let restored = try JSONDecoder().decode(AchievementLedger.self, from: JSONEncoder().encode(ledger))
    #expect(restored.pending(for: "playerA")["a"] == 100)
    #expect(restored.pending(for: "playerB")["a"] == 100)
    ledger.acknowledge(ledger.pending(for: "playerA"), for: "playerA")
    #expect(ledger.pending(for: "playerA").isEmpty)
    ledger.record(id: "a", percent: 10)
    #expect(ledger.progress["a"] == 100)
}

@Test func endingChangesAtScoreBands() {
    #expect(GameEnding.forScore(0).reaction == .shrug)
    #expect(GameEnding.forScore(10).reaction == .flex)
    #expect(GameEnding.forScore(33).reaction == .bench)
    #expect(GameEnding.forScore(81).reaction == .bow)
    #expect(GameEnding.forScore(100).reaction == .triumph)
}

@Test func freshCountdownAfterInterludeLeavesFullLeadIn() {
    var game = RhythmGame(tutorial: false)
    game.perform(.dribble, at: game.target)
    let frozen = game.timing.acceptedTimes.upperBound + 0.01
    game.advance(to: frozen)
    game.restartCountdown(from: frozen)
    #expect(game.target == frozen + game.beatDuration * 4)
    #expect(game.lives == 3)
    #expect(!game.resolved)
}

@Test(arguments: [0, 10, 33, 81, 100])
func repeatRunsVaryTheWrittenExcuseWithoutChangingTheEarnedEnding(score: Int) {
    let first = GameEnding.forScore(score)
    let alternatives = (0..<3).map { GameEnding.forScore(score, attempt: $0) }
    #expect(Set(alternatives.map(\.quip)).count == 3)
    #expect(alternatives.allSatisfy { $0.title == first.title && $0.reaction == first.reaction })
    #expect(GameEnding.forScore(score, attempt: 3) == first)
}
