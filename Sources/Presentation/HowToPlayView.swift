import SwiftUI

struct HowToPlayView: View {
    let play: () -> Void
    let practice: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reducedMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    private let paper = ClubStyle.paper
    private let navy = ClubStyle.navy
    private let red = ClubStyle.red

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Four moves. One rhythm.").font(SportsType.display(24))
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
                        Text("WAIT FOR NOW").font(SportsType.display(24))
                        HStack(spacing: 0) {
                            Capsule().fill(navy.opacity(0.2)).frame(height: 8)
                            ZStack {
                                Rectangle().fill(navy.opacity(0.16)).frame(width: 98, height: 42)
                                    .overlay(Rectangle().strokeBorder(navy, lineWidth: 2))
                                Circle().fill(paper).frame(width: 22, height: 22)
                                    .overlay(Circle().strokeBorder(navy, lineWidth: 3))
                            }
                            Capsule().fill(navy.opacity(0.2)).frame(width: 28, height: 8)
                        }.accessibilityHidden(true)
                        Text("HIT ZONE  ·  NOW").font(.caption.bold()).foregroundStyle(navy)
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
                        .white, in: RoundedRectangle(cornerRadius: 4))
                }.padding(20)
            }
            .background(paper).foregroundStyle(navy)
            .navigationTitle("How to Play").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 10) {
                    Button {
                        dismiss()
                        play()
                    } label: {
                        Text("LET’S PLAY").font(SportsType.display(18)).frame(maxWidth: .infinity).padding(12)
                            .background(red, in: RoundedRectangle(cornerRadius: 4)).foregroundStyle(paper)
                    }.accessibilityIdentifier("guidePlay")
                    Button("Try the warm-up") {
                        dismiss()
                        practice()
                    }
                    .font(.subheadline.bold()).frame(minHeight: 44).accessibilityIdentifier("guidePractice")
                }.padding(.horizontal, 20).padding(.top, 12).background(paper).foregroundStyle(navy)
            }
        }.tint(navy)
    }

    private func moveCard(_ move: Move, time: Double) -> some View {
        VStack(spacing: 5) {
            IgnacioCharacter(
                move: move, time: time, moveAge: time.truncatingRemainder(dividingBy: 1.7), reducedMotion: reducedMotion
            )
            .frame(height: 154).accessibilityHidden(true)
            Text(move.rawValue.uppercased()).font(SportsType.display(16, relativeTo: .headline))
                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            Text(gesture(move)).font(.subheadline.bold()).multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }.padding(10).frame(maxWidth: .infinity, minHeight: 252, alignment: .top)
            .background(.white, in: RoundedRectangle(cornerRadius: 4))
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
