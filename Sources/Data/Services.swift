import AVFoundation
import GameKit
import UIKit

final class LocalRecordStore: RecordStore {
    private let defaults: UserDefaults
    init(defaults: UserDefaults) { self.defaults = defaults }
    var best: Int { defaults.integer(forKey: "bestScore.v2.points") }
    func save(_ score: Int) { defaults.set(max(best, score), forKey: "bestScore.v2.points") }
}

@MainActor protocol GameAudio {
    func startArena()
    func cue(_ move: Move, delay: Double, beatDuration: Double)
    func hit()
    func finish(quote: String)
    func celebrate(_ threshold: Int)
    func stop()
}
@MainActor final class SynthAudio: GameAudio {
    private let voice = AVSpeechSynthesizer()
    private var countdown: [AVAudioPlayer] = []
    private var ambience: AVAudioPlayer?
    private var ending: AVAudioPlayer?
    private var squeak: AVAudioPlayer?
    private var awards: [Int: AVAudioPlayer] = [:]
    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            for index in 0..<4 {
                if let player = try load("countdown\(index)") { countdown.append(player) }
            }
            ambience = try load("arena")
            ambience?.numberOfLoops = -1
            ambience?.volume = 0.18
            ending = try load("finish")
            squeak = try load("squeak")
            for threshold in [10, 23, 33, 50, 81, 100] { awards[threshold] = try load("award\(threshold)") }
        } catch { print("Audio unavailable: \(error.localizedDescription)") }
    }
    private func load(_ name: String) throws -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return nil }
        let player = try AVAudioPlayer(contentsOf: url)
        player.volume = 0.65
        player.prepareToPlay()
        return player
    }
    func startArena() {
        voice.stopSpeaking(at: .immediate)
        ending?.stop()
        if ambience?.isPlaying == false { ambience?.play() }
    }
    func cue(_ move: Move, delay: Double, beatDuration: Double) {
        // Schedule all four notes on the audio device clock, not on rendering frames.
        for (index, player) in countdown.enumerated() {
            player.stop()
            player.currentTime = 0
            let offset = delay - Double(3 - index) * beatDuration
            if offset >= -0.035 { player.play(atTime: player.deviceCurrentTime + max(0.02, offset)) }
        }
        voice.stopSpeaking(at: .immediate)
        let spoken = move == .between ? "Between" : move == .behind ? "Behind" : move.rawValue
        let utterance = AVSpeechUtterance(string: spoken)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.60
        voice.speak(utterance)
    }
    func hit() {
        squeak?.currentTime = 0
        squeak?.play()
    }
    func finish(quote: String) {
        stop()
        ending?.currentTime = 0
        ending?.play()
        let line = AVSpeechUtterance(string: quote)
        line.voice = AVSpeechSynthesisVoice(language: "en-US")
        line.rate = 0.48
        line.preUtteranceDelay = 1.6
        voice.speak(line)
    }
    func celebrate(_ threshold: Int) {
        stop()
        awards[threshold]?.currentTime = 0
        awards[threshold]?.play()
    }
    func stop() {
        voice.stopSpeaking(at: .immediate)
        for player in countdown { player.stop() }
        ambience?.stop()
        squeak?.stop()
        ending?.stop()
        for award in awards.values { award.stop() }
    }
}

@MainActor final class LeaderboardService: ObservableObject {
    @Published var status = "Your personal best is saved on this iPhone."
    // Create this exact identifier in App Store Connect before enabling online scores.
    private let leaderboardID = Bundle.main.object(forInfoDictionaryKey: "IgnacioLeaderboardID") as? String ?? ""
    var onAuthenticated: (() -> Void)?
    func show(state: GKGameCenterViewControllerState = .leaderboards) {
        guard !leaderboardID.isEmpty else {
            status = "Online leaderboard is not configured. Your best remains saved on this iPhone."
            return
        }
        GKLocalPlayer.local.authenticateHandler = { [weak self] controller, error in
            Task { @MainActor in
                guard let self else { return }
                if let controller {
                    self.presenter?.present(controller, animated: true)
                } else if GKLocalPlayer.local.isAuthenticated {
                    self.status = "Connected to Game Center."
                    GKAccessPoint.shared.location = .topLeading
                    GKAccessPoint.shared.isActive = true
                    self.onAuthenticated?()
                    GKAccessPoint.shared.trigger(state: state) {}
                } else {
                    self.status =
                        "Offline leaderboard • \(error?.localizedDescription ?? "Game Center sign-in unavailable.")"
                }
            }
        }
    }
    func submit(_ score: Int) {
        guard !leaderboardID.isEmpty, GKLocalPlayer.local.isAuthenticated else { return }
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID]) {
            [weak self] error in
            if let error {
                Task { @MainActor in
                    self?.status = "Saved locally. Online score unavailable: \(error.localizedDescription)"
                }
            }
        }
    }
    private var presenter: UIViewController? {
        var controller = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(
            where: \.isKeyWindow)?.rootViewController
        while let presented = controller?.presentedViewController { controller = presented }
        return controller
    }
}
