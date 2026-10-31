import XCTest

@testable import Ignacio

@MainActor private final class MemoryAwards: AchievementStore {
    var ledger = AchievementLedger()
    func load() -> AchievementLedger { ledger }
    func save(_ ledger: AchievementLedger) { self.ledger = ledger }
}
@MainActor private final class FakeAwardTransport: AchievementTransport {
    var playerID: String?
    var calls: [[String: Double]] = []
    var completion: (@MainActor (Bool) -> Void)?
    func report(_ values: [String: Double], completion: @escaping @MainActor (Bool) -> Void) {
        calls.append(values)
        self.completion = completion
    }
}
@MainActor final class AchievementTests: XCTestCase {
    func testOfflineProgressSurvivesRestartAndFailedReportRetriesWithoutDuplicates() {
        let store = MemoryAwards()
        let transport = FakeAwardTransport()
        var now = 0.0
        var service = AchievementService(
            store: store, transport: transport, identifiers: [10: "a", 23: "b"], clock: { now })
        service.record(score: 10)
        service.tick()
        XCTAssertTrue(transport.calls.isEmpty)
        service = AchievementService(
            store: store, transport: transport, identifiers: [10: "a", 23: "b"], clock: { now })
        XCTAssertTrue(service.isEarned(10))
        transport.playerID = "player-one"
        service.flushNow()
        XCTAssertEqual(transport.calls.count, 1)
        service.tick()
        XCTAssertEqual(transport.calls.count, 1)
        transport.completion?(false)
        now = 14
        service.tick()
        XCTAssertEqual(transport.calls.count, 1)
        now = 15
        service.tick()
        XCTAssertEqual(transport.calls.count, 2)
        transport.completion?(true)
        service.flushNow()
        XCTAssertEqual(transport.calls.count, 2)
        transport.playerID = "player-two"
        service.flushNow()
        XCTAssertEqual(transport.calls.count, 3)
    }
    func testProgressEarnedDuringRequestRemainsPending() {
        let store = MemoryAwards()
        let transport = FakeAwardTransport()
        transport.playerID = "player"
        let service = AchievementService(store: store, transport: transport, identifiers: [100: "a"], clock: { 0 })
        service.record(score: 50)
        service.flushNow()
        service.record(score: 100)
        transport.completion?(true)
        service.flushNow()
        XCTAssertEqual(transport.calls.last?["a"], 100)
    }
    func testLegacyScoreIsNotComparedWithNewPointScale() {
        let name = "IgnacioRecordTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: name) else { return XCTFail("Cannot create isolated preferences") }
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set(9000, forKey: "bestScore")
        let records = LocalRecordStore(defaults: defaults)
        XCTAssertEqual(records.best, 0)
        records.save(23)
        XCTAssertEqual(LocalRecordStore(defaults: defaults).best, 23)
        records.save(10)
        XCTAssertEqual(records.best, 23)
    }
    func testAllSixAchievementIDsArePackagedAndUnique() {
        let values = AchievementService.configuredIdentifiers
        XCTAssertEqual(Set(values.keys), Set([10, 23, 33, 50, 81, 100]))
        XCTAssertEqual(Set(values.values).count, 6)
    }
}
