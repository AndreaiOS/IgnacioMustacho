import Foundation

@MainActor final class LocalAudioPreferences: AudioPreferencesStore {
    private let defaults: UserDefaults
    init(defaults: UserDefaults) { self.defaults = defaults }
    func load() -> AudioPreferences {
        AudioPreferences(
            soundEnabled: defaults.object(forKey: "audio.soundEnabled") as? Bool ?? true,
            voiceEnabled: defaults.object(forKey: "audio.voiceEnabled") as? Bool ?? true)
    }
    func save(_ preferences: AudioPreferences) {
        defaults.set(preferences.soundEnabled, forKey: "audio.soundEnabled")
        defaults.set(preferences.voiceEnabled, forKey: "audio.voiceEnabled")
    }
}
