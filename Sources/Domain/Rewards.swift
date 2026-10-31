public enum Reaction: String, CaseIterable, Sendable {
    case flex, shrug, bench, clap, bow, triumph
}

public struct Milestone: Equatable, Sendable, Identifiable {
    public let threshold: Int
    public let title: String
    public let quip: String
    public let reaction: Reaction
    public var id: Int { threshold }
    public init(_ threshold: Int, _ title: String, _ quip: String, _ reaction: Reaction) {
        self.threshold = threshold
        self.title = title
        self.quip = quip
        self.reaction = reaction
    }
    public static let standard: [Milestone] = [
        .init(10, "Tiny Flex", "Ten points. The sleeve never stood a chance.", .flex),
        .init(23, "MJ-ish", "Same number. Slightly different career.", .shrug),
        .init(33, "Bench Legend", "Still undefeated. Mostly unselected.", .bench),
        .init(50, "Self-Applause", "Someone had to start the applause.", .clap),
        .init(81, "Imaginary MVP", "The crowd in my head is going wild.", .bow),
        .init(100, "Hall of Me", "I would like to thank my moustache.", .triumph),
    ]
}

/// Run-specific awards: crossing several thresholds yields every event exactly once.
public struct RunMilestones: Sendable {
    public let rules: [Milestone]
    public private(set) var earned: Set<Int> = []
    public init(rules: [Milestone] = Milestone.standard) {
        self.rules = rules.filter { $0.threshold > 0 }.sorted { $0.threshold < $1.threshold }
    }
    public mutating func advance(score: Int) -> [Milestone] {
        rules.filter { score >= $0.threshold && earned.insert($0.threshold).inserted }
    }
}

public struct GameEnding: Equatable, Sendable {
    public let title: String
    public let quip: String
    public let reaction: Reaction
    public static func forScore(_ score: Int, attempt: Int = 0) -> GameEnding {
        let variant = max(0, attempt) % 3
        return switch score {
        case ..<10:
            .init(
                title: "TACTICAL EXIT.",
                quip: [
                    "I was saving my best moves. For another game.", "Excellent warm-up. Unfortunate that it counted.",
                    "The floor and I had creative differences.",
                ][variant], reaction: .shrug)
        case ..<33:
            .init(
                title: "SCOUTS MISSED IT.",
                quip: [
                    "The talent was here. The scouts were not.", "My agent is imaginary. His phone is off.",
                    "I peaked during the introduction.",
                ][variant], reaction: .flex)
        case ..<81:
            .init(
                title: "BENCH ROYALTY.",
                quip: [
                    "My imaginary contract just got extended.", "First name on the bench. That is still a list.",
                    "My highlight reel includes the warm-up.",
                ][variant], reaction: .bench)
        case ..<100:
            .init(
                title: "CROWD OF ONE.",
                quip: [
                    "A standing ovation. From me.", "All this talent. Absolutely no witnesses.",
                    "I demand a recount of the applause.",
                ][variant], reaction: .bow)
        default:
            .init(
                title: "LEGEND, ALLEGEDLY.",
                quip: [
                    "No ball. Somehow, still a legend.", "Please retire my imaginary jersey.",
                    "The hall of fame is currently my hallway.",
                ][variant], reaction: .triumph)
        }
    }
}

/// Highest progress per achievement, with acknowledgements scoped to the Apple player.
/// An acknowledgement only covers the submitted snapshot, never newer local progress.
public struct AchievementLedger: Codable, Sendable {
    public private(set) var progress: [String: Double] = [:]
    private var acknowledged: [String: [String: Double]] = [:]
    public init() {}
    public mutating func record(id: String, percent: Double) {
        guard !id.isEmpty, percent.isFinite else { return }
        progress[id] = max(progress[id, default: 0], min(100, max(0, percent)))
    }
    public func pending(for player: String) -> [String: Double] {
        progress.filter { $0.value > acknowledged[player, default: [:]][$0.key, default: 0] }
    }
    public mutating func acknowledge(_ sent: [String: Double], for player: String) {
        for (id, percent) in sent {
            acknowledged[player, default: [:]][id] = max(acknowledged[player, default: [:]][id, default: 0], percent)
        }
    }
}
