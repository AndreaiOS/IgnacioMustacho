public struct AudioPreferences: Equatable, Sendable {
    public var soundEnabled: Bool
    public var voiceEnabled: Bool
    public init(soundEnabled: Bool = true, voiceEnabled: Bool = true) {
        self.soundEnabled = soundEnabled
        self.voiceEnabled = voiceEnabled
    }
}

@MainActor public protocol AudioPreferencesStore {
    func load() -> AudioPreferences
    func save(_ preferences: AudioPreferences)
}
