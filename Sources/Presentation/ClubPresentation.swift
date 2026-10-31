import SwiftUI

enum ClubStyle {
    static let paper = Color(red: 0.97, green: 0.98, blue: 1.00)
    static let navy = Color(red: 0.035, green: 0.075, blue: 0.16)
    static let red = Color(red: 0.79, green: 0.09, blue: 0.17)
    static let silver = Color(red: 0.74, green: 0.79, blue: 0.87)
    static let ink = Color(red: 0.055, green: 0.065, blue: 0.085)
    static let error = Color(red: 0.70, green: 0.04, blue: 0.12)
}

struct ClubStamp: View {
    let text: String
    var color = ClubStyle.paper
    var body: some View {
        HStack(spacing: 8) {
            Rectangle().fill(ClubStyle.red).frame(width: 3)
            Text(text).font(.caption2.weight(.semibold)).tracking(0.8)
        }
        .fixedSize(horizontal: true, vertical: false).frame(height: 26)
        .padding(.trailing, 10).foregroundStyle(color)
        .background(ClubStyle.navy)
    }
}

/// A few paper streamers, confined to the protected victory lap. Never a live-input effect.
struct VictoryPaper: View {
    let age: Double
    let reducedMotion: Bool
    var body: some View {
        GeometryReader { geometry in
            let progress = min(1, max(0, age / GameModel.interludeDuration))
            ZStack {
                if !reducedMotion {
                    ForEach(0..<12, id: \.self) { index in
                        let side = index.isMultiple(of: 2) ? -1.0 : 1.0
                        let spread = 0.12 + Double(index / 2) * 0.065
                        RoundedRectangle(cornerRadius: 1)
                            .fill(index.isMultiple(of: 3) ? ClubStyle.red : ClubStyle.silver)
                            .frame(width: 4, height: 9)
                            .rotationEffect(.degrees(Double(index * 29) + progress * side * 150))
                            .position(
                                x: geometry.size.width * (0.5 + side * spread * progress),
                                y: geometry.size.height * (0.13 + progress * progress * 0.65)
                            )
                            .opacity((1 - progress) * 0.8)
                    }
                }
            }
        }.allowsHitTesting(false).accessibilityHidden(true)
    }
}

struct SoundCheckView: View {
    @ObservedObject var model: GameModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Audio & commentary").font(SportsType.display(26))
                    Text("The coach is optional. The moustache is not.")
                        .font(.subheadline).foregroundStyle(ClubStyle.paper.opacity(0.8))
                    Toggle(isOn: $model.soundEnabled) {
                        Label("Game audio", systemImage: "speaker.wave.2.fill").font(.headline)
                    }.tint(ClubStyle.red).accessibilityIdentifier("gameAudioToggle")
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle(isOn: $model.voiceEnabled) {
                            Label("Spoken move calls", systemImage: "quote.bubble.fill").font(.headline)
                        }.tint(ClubStyle.red).accessibilityIdentifier("voiceCallsToggle").disabled(!model.soundEnabled)
                        Text("Keep the organ and effects. Let the move cards do the coaching.")
                            .font(.caption).foregroundStyle(ClubStyle.paper.opacity(0.8))
                    }
                    Text("Your choices stay on this iPhone. Silent mode still applies.")
                        .font(.caption).foregroundStyle(ClubStyle.paper.opacity(0.65))
                    VStack(alignment: .leading, spacing: 4) {
                        if let privacy = URL(string: "https://andreaios.github.io/IgnacioMustacho/privacy.html") {
                            Link("Privacy policy", destination: privacy)
                                .frame(minHeight: 44).accessibilityIdentifier("privacyPolicy")
                        }
                        if let support = URL(string: "mailto:an.murru@gmail.com?subject=Ignacio%20Mustacho%20support") {
                            Link("Contact support", destination: support)
                                .frame(minHeight: 44).accessibilityIdentifier("supportEmail")
                        }
                    }.font(.subheadline.weight(.semibold))
                }.padding(24)
            }
            .background(ClubStyle.navy).foregroundStyle(ClubStyle.paper)
            .navigationTitle("Sound check").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
            .toolbarBackground(ClubStyle.navy, for: .navigationBar).toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }.tint(ClubStyle.paper)
    }
}

#if DEBUG
    /// Fixed-clock scenes for visual QA only: no persistence, sound or automatic online reporting.
    @MainActor enum ClubReview {
        private final class Clock { var time = 1000.0 }
        private final class Records: RecordStore {
            var best = 0
            func save(_ score: Int) { best = max(best, score) }
        }
        private final class Audio: GameAudio {
            func setVoiceEnabled(_ enabled: Bool) {}
            func startArena() {}
            func cue(_ move: Move, delay: Double, beatDuration: Double) {}
            func hit() {}
            func finish() {}
            func celebrate(_ threshold: Int) {}
            func stop() {}
        }
        static func model(fastPace: Bool) -> GameModel {
            let clock = Clock()
            let model = GameModel(
                records: Records(), audio: Audio(), leaderboard: LeaderboardService(), clock: { clock.time })
            model.play()
            if fastPace {
                var game = RhythmGame(tutorial: false)
                for _ in 0..<128 {
                    game.perform(game.move, at: game.target)
                    game.advance(to: game.timing.acceptedTimes.upperBound + 0.001)
                }
                game.restartCountdown(from: 0)
                model.game = game
                clock.time += game.target - 0.03
                model.tick()
            } else {
                for _ in 0..<5 {
                    clock.time = 1000 + model.game.target
                    model.gesture(model.game.move)
                    clock.time = 1000 + model.game.timing.acceptedTimes.upperBound + 0.001
                    model.tick()
                }
                clock.time += 0.55
                model.tick()
            }
            return model
        }
    }
#endif
