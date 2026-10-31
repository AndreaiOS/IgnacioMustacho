public enum Move: String, CaseIterable, Sendable {
    case dribble = "Dribble"
    case between = "Between the legs"
    case behind = "Behind the back"
    case shoot = "Shoot"

    public var hint: String {
        switch self {
        case .dribble: return "TAP"
        case .between: return "SWIPE DOWN"
        case .behind: return "SWIPE LEFT OR RIGHT"
        case .shoot: return "SWIPE UP"
        }
    }
}
public enum Judgement: String, Sendable {
    case perfect = "PERFECT"
    case good = "GOOD"
    case miss = "MISS"
}

/// Shared by scoring and presentation: the dot's CENTER enters/exits validZone
/// exactly at the inclusive acceptance boundaries. Travel continues beyond the beat.
public struct RhythmTiming: Sendable {
    public let target: Double
    public let beatDuration: Double
    public let halfWindow: Double
    public let perfectWindow: Double

    public var acceptedTimes: ClosedRange<Double> { (target - halfWindow)...(target + halfWindow) }
    public var validZone: ClosedRange<Double> {
        position(at: acceptedTimes.lowerBound)...position(at: acceptedTimes.upperBound)
    }
    public func position(at time: Double) -> Double {
        let tail = max(beatDuration, halfWindow + 0.12)
        return min(1, max(0, (time - (target - beatDuration * 4)) / (beatDuration * 4 + tail)))
    }
    /// Leave a small gap between organ notes even at the fastest supported pace.
    public static func notePlaybackRate(duration: Double, beatDuration: Double) -> Double {
        min(2, max(1, duration / (beatDuration * 0.9)))
    }
    public func accepts(_ time: Double) -> Bool { acceptedTimes.contains(time) }
    public func isPerfect(_ time: Double) -> Bool {
        ((target - perfectWindow)...(target + perfectWindow)).contains(time)
    }
}

public enum InputError: String, Sendable {
    case early = "TOO EARLY"
    case late = "TOO LATE"
    case wrongMove = "WRONG MOVE"
    case missed = "TOO LATE — NO GESTURE"
}

/// All times are elapsed monotonic seconds supplied by the caller.
public struct RhythmGame: Sendable {
    public private(set) var score = 0
    public private(set) var combo = 0
    public private(set) var lives = 3
    public private(set) var index = 0
    public private(set) var target = 2.4
    public private(set) var resolved = false
    public private(set) var lastJudgement: Judgement?
    public private(set) var lastError: InputError?
    private var touchDeadline: Double?
    public let tutorial: Bool
    /// Four-command stages: a familiar opening, then 28 further increases up to command 129.
    public var paceLevel: Int { tutorial ? 1 : min(33, index / 4 + 1) }
    public var beatDuration: Double {
        guard !tutorial else { return 0.85 }
        let stage = paceLevel - 1
        let bpm = stage <= 4 ? 100 + stage * 20 : 180 + (stage - 4) * 5
        return 60 / Double(bpm)
    }
    public var commandInterval: Double { beatDuration * 4 }
    public var moveAnimationDuration: Double {
        min(0.85, commandInterval - timing.halfWindow * 2 - 0.04)
    }
    public var timing: RhythmTiming {
        let halfWindow = tutorial ? 0.5 : min(max(0.28, 0.4 - Double(index / 8) * 0.02), beatDuration * 0.85)
        return RhythmTiming(
            target: target, beatDuration: beatDuration, halfWindow: halfWindow,
            perfectWindow: tutorial ? 0.18 : min(0.14, halfWindow * 0.5))
    }
    public var isAwaitingGesture: Bool { touchDeadline != nil && !resolved }
    public func canAct(at time: Double) -> Bool { !isOver && !resolved && timing.accepts(time) }
    public var isOver: Bool { lives == 0 || (tutorial && index >= 4) }
    public var move: Move {
        let sequence: [Move] =
            tutorial
            ? Move.allCases
            : [
                .dribble, .between, .behind, .shoot, .behind, .dribble, .shoot, .between, .dribble, .behind, .between,
                .shoot,
            ]
        return sequence[index % sequence.count]
    }
    public init(tutorial: Bool) {
        self.tutorial = tutorial
        target = tutorial ? 3.4 : 2.4
    }

    public mutating func beginTouch(at time: Double) {
        guard canAct(at: time) else { return }
        touchDeadline = time + GestureInput.maximumDuration
    }
    public mutating func cancelTouch() { touchDeadline = nil }

    @discardableResult public mutating func perform(_ move: Move, at time: Double, commandID: Int? = nil) -> Judgement?
    {
        guard commandID == nil || commandID == index else { return nil }
        guard !isOver, !resolved, time >= target - beatDuration * 2 else { return nil }
        touchDeadline = nil
        lastError =
            time < timing.acceptedTimes.lowerBound
            ? .early
            : time > timing.acceptedTimes.upperBound
                ? .late
                : move != self.move ? .wrongMove : nil
        let judgement: Judgement =
            move != self.move || !timing.accepts(time)
            ? .miss : timing.isPerfect(time) ? .perfect : .good
        resolve(judgement)
        return judgement
    }
    public mutating func advance(to time: Double) {
        guard !isOver, time > timing.acceptedTimes.upperBound else { return }
        if let touchDeadline, !resolved, time <= touchDeadline { return }
        if !resolved {
            lastError = .missed
            resolve(.miss)
        }
        guard lives > 0 else { return }
        index += 1
        target = max(target + beatDuration * 4, time + beatDuration * 3)
        touchDeadline = nil
        resolved = false
    }
    /// Used after a protected interlude; the next command receives four fresh beats.
    public mutating func restartCountdown(from time: Double) {
        guard !isOver, !resolved else { return }
        touchDeadline = nil
        target = time + beatDuration * 4
    }
    private mutating func resolve(_ judgement: Judgement) {
        resolved = true
        lastJudgement = judgement
        if judgement == .miss {
            combo = 0
            if !tutorial { lives -= 1 }
        } else {
            combo += 1
            score += (judgement == .perfect ? 2 : 1) * min(3, 1 + combo / 10)
        }
    }
}
public protocol RecordStore {
    var best: Int { get }
    func save(_ score: Int)
}
