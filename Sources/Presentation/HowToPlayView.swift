import SwiftUI

struct HowToPlayView: View {
    let play: () -> Void
    let practice: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reducedMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    private let cream = Color(red: 0.97, green: 0.94, blue: 0.84)
    private let green = Color(red: 0.10, green: 0.25, blue: 0.20)
    private let orange = Color(red: 0.94, green: 0.35, blue: 0.17)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("FOUR MOVES.\nFIND YOUR RHYTHM.").font(SportsType.display(36))
                        Text("No ball. No scouts. An unreasonable amount of confidence.").font(.subheadline)
                    }
                    TimelineView(.animation(minimumInterval: 1.0 / 24, paused: reducedMotion)) { context in
                        LazyVGrid(
                            columns: Array(
                                repeating: GridItem(.flexible()), count: typeSize.isAccessibilitySize ? 1 : 2),
                            spacing: 12
                        ) {
                            ForEach(Move.allCases, id: \.self) { move in
                                moveCard(move, time: context.date.timeIntervalSinceReferenceDate)
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        Text("WAIT FOR NOW").font(SportsType.display(28))
                        HStack(spacing: 0) {
                            Capsule().fill(green.opacity(0.2)).frame(height: 8)
                            ZStack {
                                Rectangle().fill(green.opacity(0.16)).frame(width: 98, height: 42)
                                    .overlay(Rectangle().strokeBorder(green, lineWidth: 2))
                                Circle().fill(cream).frame(width: 22, height: 22)
                                    .overlay(Circle().strokeBorder(green, lineWidth: 3))
                            }
                            Capsule().fill(green.opacity(0.2)).frame(width: 28, height: 8)
                        }.accessibilityHidden(true)
                        Text("HIT ZONE  ·  NOW").font(.caption.bold()).foregroundStyle(green)
                        Text(
                            "Listen to the call. Start your tap or swipe when the dot is inside the outlined hit zone and NOW appears. A short swipe is enough."
                        )
                        .font(.subheadline)
                        Label("Three lives. A wrong move or missed beat costs one.", systemImage: "heart.fill")
                        Label(
                            "The pace rises every four commands, up to 320 BPM. Calls come faster and the hit zone tightens.",
                            systemImage: "speedometer")
                        Text(
                            "Good: 1 point. Perfect: 2. Combo boosts rewards up to ×3. A missed beat resets the combo, not your magnificent moustache."
                        ).font(.subheadline)
                        Text(
                            "Trophy stops: 10, 23, 33, 50, 81 and 100 points in one game. Ignacio celebrates between commands; the clock waits for his ego."
                        ).font(.subheadline)
                        Text("Warm-up lets you try all four moves without losing lives, then starts a game.").font(
                            .subheadline)
                    }.font(.subheadline).padding(18).background(
                        .white.opacity(0.55), in: RoundedRectangle(cornerRadius: 8))
                }.padding(20)
            }
            .background(cream).foregroundStyle(green)
            .navigationTitle("How to Play").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 10) {
                    Button {
                        dismiss()
                        play()
                    } label: {
                        Text("LET’S PLAY").font(SportsType.display(25)).frame(maxWidth: .infinity).padding(12)
                            .background(orange, in: RoundedRectangle(cornerRadius: 8)).foregroundStyle(cream)
                    }.accessibilityIdentifier("guidePlay")
                    Button("Try the warm-up") {
                        dismiss()
                        practice()
                    }
                    .font(.subheadline.bold()).frame(minHeight: 44).accessibilityIdentifier("guidePractice")
                }.padding(.horizontal, 20).padding(.top, 12).background(cream).foregroundStyle(green)
            }
        }.tint(green)
    }

    private func moveCard(_ move: Move, time: Double) -> some View {
        VStack(spacing: 5) {
            IgnacioCharacter(
                move: move, time: time, moveAge: time.truncatingRemainder(dividingBy: 1.7), reducedMotion: reducedMotion
            )
            .frame(height: 154).accessibilityHidden(true)
            Text(move.rawValue.uppercased()).font(SportsType.display(21, relativeTo: .headline))
                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            Text(gesture(move)).font(.subheadline.bold()).multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }.padding(10).frame(maxWidth: .infinity, minHeight: 252, alignment: .top)
            .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 8))
            .accessibilityElement(children: .ignore).accessibilityLabel("\(move.rawValue). \(gesture(move))")
    }

    private func gesture(_ move: Move) -> String {
        switch move {
        case .dribble: "Tap"
        case .between: "↓ Swipe down"
        case .behind: "↔ Swipe left/right"
        case .shoot: "↑ Swipe up"
        }
    }
}
