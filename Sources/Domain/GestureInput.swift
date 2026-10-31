public struct GestureAction: Equatable, Sendable {
    public let move: Move
    public let time: Double
    public let commandID: Int
}

/// One physical contact produces at most one action, judged at contact onset.
public struct GestureInput: Sendable {
    public static let maximumDuration = 0.45
    public let startTime: Double
    public let commandID: Int
    public private(set) var emitted = false
    private var maximumTravel = 0.0
    public init(startTime: Double, commandID: Int) {
        self.startTime = startTime
        self.commandID = commandID
    }
    public mutating func update(x: Double, y: Double, at time: Double) -> GestureAction? {
        maximumTravel = max(maximumTravel, max(abs(x), abs(y)))
        guard !emitted, time - startTime <= Self.maximumDuration else { return nil }
        let horizontal = abs(x)
        let vertical = abs(y)
        guard max(horizontal, vertical) >= 14, max(horizontal, vertical) >= min(horizontal, vertical) * 1.2 else {
            return nil
        }
        return action(horizontal > vertical ? .behind : y < 0 ? .shoot : .between)
    }
    public mutating func end(x: Double, y: Double, at time: Double) -> GestureAction? {
        if let swipe = update(x: x, y: y, at: time) { return swipe }
        guard !emitted, maximumTravel <= 10, time - startTime <= 0.3 else { return nil }
        return action(.dribble)
    }
    private mutating func action(_ move: Move) -> GestureAction {
        emitted = true
        return GestureAction(move: move, time: startTime, commandID: commandID)
    }
}
