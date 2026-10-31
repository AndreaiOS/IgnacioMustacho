import SwiftUI
import UIKit

@MainActor final class GameModel: ObservableObject {
    enum Screen { case home, playing, results }
    @Published var screen: Screen = .home
    @Published var game = RhythmGame(tutorial: false)
    @Published var now = 0.0
    @Published var paused = false
    @Published var best: Int
    @Published var animatedMove: Move?
    @Published var feedback = "FIND YOUR RHYTHM"
    @Published var inputDetail = "TAP OR SWIPE ON THE COURT"
    @Published var soundEnabled = true { didSet { if !soundEnabled { audio.stop() } } }
    @Published private(set) var celebration: Milestone?
    @Published private(set) var ending: GameEnding?
    @Published private(set) var reactionAge = 0.0
    let achievements: AchievementService?
    private var milestones = RunMilestones()
    private var pendingMilestones: [Milestone] = []
    private var reactionOrigin = 0.0
    static let interludeDuration = 1.35
    private let records: RecordStore
    private let audio: GameAudio
    private let clock: () -> Double
    let leaderboard: LeaderboardService
    private var origin = 0.0
    private var announced = -1
    private var feedbackTime = -10.0
    private var input: GestureInput?
    private var tutorialCompleted = false

    init(
        records: RecordStore, audio: GameAudio, leaderboard: LeaderboardService,
        achievements: AchievementService? = nil, clock: @escaping () -> Double
    ) {
        self.achievements = achievements
        self.records = records
        self.audio = audio
        self.leaderboard = leaderboard
        self.clock = clock
        best = records.best
    }
    func play(tutorial: Bool = false) {
        game = RhythmGame(tutorial: tutorial)
        milestones = RunMilestones()
        pendingMilestones = []
        celebration = nil
        ending = nil
        reactionAge = 0
        now = 0
        announced = -1
        feedback = tutorial ? "LET’S LEARN THE MOVES" : "FIND YOUR RHYTHM"
        animatedMove = nil
        inputDetail = "TOUCH WHEN NOW APPEARS"
        input = nil
        if soundEnabled { audio.startArena() }
        origin = clock()
        paused = false
        screen = .playing
    }
    func firstPlay() { play(tutorial: !tutorialCompleted) }
    func tick() {
        achievements?.tick()
        guard screen == .playing else {
            now = clock()
            if ending != nil { reactionAge = clock() - reactionOrigin }
            return
        }
        guard !paused else { return }
        if celebration != nil {
            reactionAge = clock() - reactionOrigin
            if reactionAge >= Self.interludeDuration { finishInterlude() }
            return
        }
        now = clock() - origin
        if game.resolved, !pendingMilestones.isEmpty, now > game.timing.acceptedTimes.upperBound, !game.isOver {
            celebration = pendingMilestones.last
            pendingMilestones = []
            cancelTouch()
            animatedMove = nil
            audio.stop()
            if soundEnabled, let celebration { audio.celebrate(celebration.threshold) }
            reactionOrigin = clock()
            reactionAge = 0
            achievements?.flushNow()
            return
        }
        let oldIndex = game.index
        let oldLives = game.lives
        game.advance(to: now)
        if game.lives < oldLives || (game.tutorial && oldIndex != game.index && game.lastJudgement == .miss) {
            feedback = game.lastError?.rawValue ?? "MISS"
            inputDetail = "NO CLEAR GESTURE RECEIVED"
            feedbackTime = now
        }
        if game.isOver {
            audio.stop()
            if game.tutorial {
                tutorialCompleted = true
                play()
            } else {
                ending = GameEnding.forScore(game.score)
                reactionOrigin = clock()
                reactionAge = 0
                animatedMove = nil
                if soundEnabled, let ending { audio.finish(quote: ending.quip) }
                achievements?.record(score: game.score)
                achievements?.flushNow()
                records.save(game.score)
                best = records.best
                leaderboard.submit(game.score)
                screen = .results
            }
            return
        }
        if announced != game.index {
            announced = game.index
            if soundEnabled { audio.cue(game.move, delay: game.target - now, beatDuration: game.beatDuration) }
        }
        if now - feedbackTime > 0.85 { animatedMove = nil }
    }
    func gesture(_ move: Move) {
        guard screen == .playing, !paused, celebration == nil else { return }
        handle(GestureAction(move: move, time: clock() - origin, commandID: game.index))
    }
    func touchBegan(at timestamp: Double) {
        guard screen == .playing, !paused, celebration == nil, input == nil else { return }
        let time = timestamp - origin
        input = GestureInput(startTime: time, commandID: game.index)
        game.beginTouch(at: time)
    }
    func touchMoved(x: Double, y: Double, at timestamp: Double) {
        guard screen == .playing, !paused, celebration == nil else { return }
        if let action = input?.update(x: x, y: y, at: timestamp - origin) { handle(action) }
    }
    func touchEnded(x: Double, y: Double, at timestamp: Double) {
        guard screen == .playing, !paused, celebration == nil else { return }
        if let action = input?.end(x: x, y: y, at: timestamp - origin) {
            handle(action)
        } else if let input, !input.emitted, input.commandID == game.index, !game.resolved {
            feedback = "USE A SHORT, CLEAR TAP OR SWIPE"
        }
        cancelTouch()
    }
    func cancelTouch() {
        input = nil
        game.cancelTouch()
    }
    private func handle(_ action: GestureAction) {
        now = clock() - origin
        guard action.commandID == game.index else { return }
        inputDetail = "YOU: \(action.move.rawValue.uppercased())"
        guard let judgement = game.perform(action.move, at: action.time, commandID: action.commandID) else {
            if !game.resolved { feedback = "WAIT — NO LIFE LOST" }
            return
        }
        animatedMove = action.move
        feedback =
            game.lastError.map { error in
                error == .wrongMove ? "WRONG MOVE — \(game.move.hint)" : error.rawValue
            } ?? judgement.rawValue
        feedbackTime = now
        if judgement == .miss {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        } else {
            if !game.tutorial {
                pendingMilestones += milestones.advance(score: game.score)
                achievements?.record(score: game.score)
            }
            if soundEnabled { audio.hit() }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
    func pause() {
        guard screen == .playing, !paused else { return }
        if celebration != nil { reactionAge = clock() - reactionOrigin }
        paused = true
        cancelTouch()
        audio.stop()
    }
    func resume() {
        guard paused else { return }
        if celebration != nil {
            reactionOrigin = clock() - reactionAge
        } else if soundEnabled {
            audio.startArena()
        }
        origin = clock() - now
        paused = false
        announced = -1
        achievements?.flushNow()
    }
    func skipInterlude() {
        guard celebration != nil, !paused else { return }
        finishInterlude()
    }
    private func finishInterlude() {
        celebration = nil
        game.advance(to: now)
        game.restartCountdown(from: now)
        audio.stop()
        if soundEnabled { audio.startArena() }
        origin = clock() - now
        announced = -1
        feedback = "BACK TO BUSINESS. IMAGINARY BUSINESS."
        inputDetail = "WAIT FOR THE NEXT CALL"
    }
    func home() {
        audio.stop()
        celebration = nil
        ending = nil
        paused = false
        screen = .home
    }
    var anticipation: Double {
        guard screen == .playing, celebration == nil, animatedMove == nil, !game.resolved else { return 0 }
        return max(0, min(0.8, (0.35 - (game.target - now)) / 0.35))
    }
    var displayReaction: Reaction? { celebration?.reaction ?? ending?.reaction }
    var earnedMilestones: [Milestone] { milestones.rules.filter { milestones.earned.contains($0.threshold) } }
    var displayMove: Move? { animatedMove ?? (anticipation > 0 ? game.move : nil) }
    var moveAge: Double { now - feedbackTime }
    var approach: Double { game.timing.position(at: now) }
    var timingCue: String {
        if game.resolved { return game.lastError?.rawValue ?? game.lastJudgement?.rawValue ?? "" }
        if game.isAwaitingGesture && !game.timing.accepts(now) { return "FINISH YOUR GESTURE" }
        return game.canAct(at: now) ? "NOW — \(game.move.hint)" : "WAIT FOR THE BOX"
    }
}
