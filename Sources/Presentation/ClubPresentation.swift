import SwiftUI

enum ClubStyle {
    static let cream = Color(red: 0.97, green: 0.94, blue: 0.84)
    static let green = Color(red: 0.10, green: 0.25, blue: 0.20)
    static let orange = Color(red: 0.94, green: 0.35, blue: 0.17)
    static let gold = Color(red: 0.97, green: 0.76, blue: 0.35)
    static let error = Color(red: 0.56, green: 0.16, blue: 0.10)
}

struct ClubStamp: View {
    let text: String
    var color = ClubStyle.cream
    var body: some View {
        Text(text).font(SportsType.display(17, relativeTo: .caption)).tracking(1)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .foregroundStyle(color).background(ClubStyle.green.opacity(0.94))
            .overlay(Rectangle().strokeBorder(color.opacity(0.8), lineWidth: 1))
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
                Ellipse().fill(
                    RadialGradient(
                        colors: [ClubStyle.gold.opacity(0.25), .clear], center: .center, startRadius: 5, endRadius: 180)
                ).frame(width: geometry.size.width, height: geometry.size.height * 0.8)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.55)
                if !reducedMotion {
                    ForEach(0..<12, id: \.self) { index in
                        let side = index.isMultiple(of: 2) ? -1.0 : 1.0
                        let spread = 0.12 + Double(index / 2) * 0.065
                        RoundedRectangle(cornerRadius: 1)
                            .fill(index.isMultiple(of: 3) ? ClubStyle.orange : ClubStyle.gold)
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
                    Text("LET THE ORGAN TALK.").font(SportsType.display(34))
                    Text("The coach is optional. The moustache is not.")
                        .font(.subheadline).foregroundStyle(ClubStyle.cream.opacity(0.8))
                    Toggle(isOn: $model.soundEnabled) {
                        Label("Game audio", systemImage: "speaker.wave.2.fill").font(.headline)
                    }.accessibilityIdentifier("gameAudioToggle")
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle(isOn: $model.voiceEnabled) {
                            Label("Spoken move calls", systemImage: "quote.bubble.fill").font(.headline)
                        }.accessibilityIdentifier("voiceCallsToggle").disabled(!model.soundEnabled)
                        Text("Keep the organ and effects. Let the move cards do the coaching.")
                            .font(.caption).foregroundStyle(ClubStyle.cream.opacity(0.8))
                    }
                    Text("Your choices stay on this iPhone. Silent mode still applies.")
                        .font(.caption).foregroundStyle(ClubStyle.cream.opacity(0.65))
                }.padding(24)
            }
            .background(ClubStyle.green).foregroundStyle(ClubStyle.cream)
            .navigationTitle("Sound check").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
            .toolbarBackground(ClubStyle.green, for: .navigationBar).toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }.tint(ClubStyle.orange)
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
