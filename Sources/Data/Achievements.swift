import Foundation
import GameKit

@MainActor protocol AchievementStore {
    func load() -> AchievementLedger
    func save(_ ledger: AchievementLedger)
}
@MainActor final class LocalAchievementStore: AchievementStore {
    private let defaults: UserDefaults
    private let key = "achievements.v2.points"
    init(defaults: UserDefaults) { self.defaults = defaults }
    func load() -> AchievementLedger {
        guard let data = defaults.data(forKey: key),
            let value = try? JSONDecoder().decode(AchievementLedger.self, from: data)
        else { return AchievementLedger() }
        return value
    }
    func save(_ ledger: AchievementLedger) {
        guard let data = try? JSONEncoder().encode(ledger) else { return }
        defaults.set(data, forKey: key)
    }
}
@MainActor protocol AchievementTransport {
    var playerID: String? { get }
    func report(_ values: [String: Double], completion: @escaping @MainActor (Bool) -> Void)
}
@MainActor final class GameKitAchievementTransport: AchievementTransport {
    var playerID: String? {
        GKLocalPlayer.local.isAuthenticated ? GKLocalPlayer.local.gamePlayerID : nil
    }
    func report(_ values: [String: Double], completion: @escaping @MainActor (Bool) -> Void) {
        let achievements = values.map { id, percent in
            let achievement = GKAchievement(identifier: id)
            achievement.percentComplete = percent
            // Our protected interlude owns presentation; never cover a live command.
            achievement.showsCompletionBanner = false
            return achievement
        }
        GKAchievement.report(achievements) { error in
            let succeeded = error == nil
            Task { @MainActor in completion(succeeded) }
        }
    }
}
@MainActor final class AchievementService: ObservableObject {
    @Published private(set) var ledger: AchievementLedger
    @Published private(set) var status = "Awards stay on this iPhone until Game Center connects."
    private let store: AchievementStore
    private let transport: AchievementTransport
    private let clock: () -> Double
    let identifiers: [Int: String]
    private var inFlight = false
    private var nextAttempt = 0.0
    init(
        store: AchievementStore, transport: AchievementTransport, identifiers: [Int: String],
        clock: @escaping () -> Double
    ) {
        self.store = store
        self.transport = transport
        self.identifiers = identifiers
        self.clock = clock
        ledger = store.load()
    }
    static var configuredIdentifiers: [Int: String] {
        let raw = Bundle.main.object(forInfoDictionaryKey: "IgnacioAchievementIDs") as? [String: String] ?? [:]
        return raw.reduce(into: [:]) { result, item in
            if let threshold = Int(item.key), threshold > 0, !item.value.isEmpty, !item.value.contains("$(") {
                result[threshold] = item.value
            }
        }
    }
    func record(score: Int) {
        for (threshold, id) in identifiers {
            ledger.record(id: id, percent: Double(max(0, score)) / Double(threshold) * 100)
        }
        store.save(ledger)
    }
    func percentComplete(_ threshold: Int) -> Double {
        guard let id = identifiers[threshold] else { return 0 }
        return ledger.progress[id, default: 0]
    }
    func isEarned(_ threshold: Int) -> Bool { percentComplete(threshold) >= 100 }
    func flushNow() {
        nextAttempt = 0
        tick()
    }
    func tick() {
        guard !inFlight, clock() >= nextAttempt, let player = transport.playerID else { return }
        let sent = ledger.pending(for: player)
        guard !sent.isEmpty else { return }
        inFlight = true
        nextAttempt = clock() + 15
        transport.report(sent) { [weak self] succeeded in
            guard let self else { return }
            self.inFlight = false
            self.nextAttempt = self.clock() + 15
            if succeeded {
                self.ledger.acknowledge(sent, for: player)
                self.store.save(self.ledger)
                self.status = "Progress synced with Game Center."
            } else {
                self.status = "Awards saved locally. Game Center sync will retry."
            }
        }
    }
}
