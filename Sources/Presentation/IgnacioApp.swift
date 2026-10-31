import Combine
import SwiftUI

enum SportsType {
    static func display(_ size: CGFloat, relativeTo style: Font.TextStyle = .title) -> Font {
        .custom("AvenirNextCondensed-Heavy", size: size, relativeTo: style)
    }
    static func score(_ size: CGFloat) -> Font { .custom("Menlo-Bold", size: size, relativeTo: .title) }
}

@main struct IgnacioApp: App {
    @StateObject private var model: GameModel
    init() {
        #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--milestone-review")
                || ProcessInfo.processInfo.arguments.contains("--pace-review")
            {
                _model = StateObject(
                    wrappedValue: ClubReview.model(
                        fastPace: ProcessInfo.processInfo.arguments.contains("--pace-review")))
                return
            }
        #endif
        let leaderboard = LeaderboardService()
        let achievements = AchievementService(
            store: LocalAchievementStore(defaults: .standard),
            transport: GameKitAchievementTransport(), identifiers: AchievementService.configuredIdentifiers,
            clock: { ProcessInfo.processInfo.systemUptime })
        leaderboard.onAuthenticated = { achievements.flushNow() }
        _model = StateObject(
            wrappedValue: GameModel(
                records: LocalRecordStore(defaults: .standard), audio: SynthAudio(), leaderboard: leaderboard,
                achievements: achievements, preferences: LocalAudioPreferences(defaults: .standard),
                clock: { ProcessInfo.processInfo.systemUptime }))
    }
    var body: some Scene {
        WindowGroup {
            #if DEBUG
                if ProcessInfo.processInfo.arguments.contains("--reward-review") {
                    ReactionReviewView()
                } else if ProcessInfo.processInfo.arguments.contains("--launch-review") {
                    LaunchScreenReviewView().ignoresSafeArea()
                } else if ProcessInfo.processInfo.arguments.contains("--motion-review") {
                    MotionReviewView()
                } else {
                    GameView(model: model)
                }
            #else
                GameView(model: model)
            #endif
        }
    }
}

struct GameView: View {
    @ObservedObject var model: GameModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reducedMotion
    @State private var showLeaderboard = false
    @State private var showGuide = false
    @State private var showSound = false
    private let timer = Timer.publish(every: 1.0 / 60, on: .main, in: .common).autoconnect()
    private let cream = ClubStyle.cream
    private let dark = ClubStyle.green
    private let orange = ClubStyle.orange

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ArenaBackdrop().ignoresSafeArea()
                VStack(spacing: 12) {
                    header
                    if model.screen == .playing, let celebration = model.celebration {
                        VStack(spacing: 4) {
                            Text("\(celebration.threshold) POINTS").font(SportsType.score(22))
                            Text(celebration.title.uppercased()).font(SportsType.display(34))
                        }.accessibilityIdentifier("milestoneTitle")
                    } else if model.screen == .playing {
                        command.overlay { TouchSurface(model: model).accessibilityHidden(true) }
                    } else {
                        title
                    }
                    ZStack(alignment: .bottom) {
                        if model.celebration != nil {
                            VictoryPaper(age: model.reactionAge, reducedMotion: reducedMotion)
                        }
                        IgnacioCharacter(
                            move: model.displayMove, time: model.now, moveAge: model.moveAge,
                            reducedMotion: reducedMotion, anticipation: model.anticipation,
                            reaction: idleReaction ?? model.displayReaction,
                            reactionAge: model.screen == .home ? idleAge : model.reactionAge,
                            moveDuration: model.moveAnimationDuration,
                            reactionScale: model.screen == .home ? 0.77 : 0.65
                        )
                        .frame(maxWidth: 340)
                        .padding(.bottom, model.screen == .playing ? 35 : 0)
                        .scaleEffect(
                            model.celebration != nil && !reducedMotion
                                ? 1 + 0.025 * sin(min(1, model.reactionAge / GameModel.interludeDuration) * .pi) : 1,
                            anchor: .bottom)
                        if model.screen == .playing && model.celebration == nil {
                            VStack(spacing: 3) {
                                HStack(spacing: 8) {
                                    Text(model.feedback)
                                    if model.game.resolved && model.pointsEarned > 0 {
                                        Text("+\(model.pointsEarned)").monospacedDigit()
                                    }
                                }.font(.system(.caption, design: .monospaced, weight: .bold))
                                    .foregroundStyle(model.game.lastError != nil ? ClubStyle.error : dark)
                                    .multilineTextAlignment(.center)
                                Text(model.inputDetail).font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundStyle(dark.opacity(0.75))
                            }.padding(.horizontal, 12).padding(.vertical, 7)
                                .background(
                                    model.game.resolved && model.game.lastJudgement == .perfect
                                        ? ClubStyle.gold : cream, in: RoundedRectangle(cornerRadius: 4))
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .overlay(alignment: .topLeading) {
                        if model.screen == .home {
                            ClubStamp(text: "SELF-APPOINTED MVP", color: ClubStyle.gold)
                                .rotationEffect(.degrees(-4)).padding(.top, 8).allowsHitTesting(false)
                        } else if model.screen == .results && model.isNewBest {
                            ClubStamp(text: "PERSONAL BEST. OBVIOUSLY.", color: ClubStyle.gold)
                                .rotationEffect(.degrees(-3)).padding(.top, 8).allowsHitTesting(false)
                        }
                    }
                    .overlay {
                        if model.screen == .playing && !model.paused && model.celebration == nil {
                            TouchSurface(model: model).accessibilityIdentifier("courtGestureSurface")
                        }
                    }
                    if model.screen == .playing, let celebration = model.celebration {
                        VStack(spacing: 10) {
                            Text(celebration.quip).font(.headline).multilineTextAlignment(.center).fixedSize(
                                horizontal: false, vertical: true)
                            Text("APPLAUSE: PROVIDED BY IGNACIO").font(.caption.bold()).foregroundStyle(ClubStyle.gold)
                            Text("Clock paused. You have time for this.").font(.caption)
                            Button("Keep playing") { model.skipInterlude() }.frame(minHeight: 44)
                        }.padding(18).frame(maxWidth: .infinity).background(dark, in: RoundedRectangle(cornerRadius: 8))
                    } else if model.screen == .playing {
                        rhythmPanel
                    } else if model.screen == .results {
                        results
                    } else {
                        homeControls
                    }
                }
                .padding(.horizontal, 25).padding(.top, 10).padding(.bottom, 16)
                if model.paused { pauseOverlay }
            }
            .foregroundStyle(cream)
            .contentShape(Rectangle())

        }
        .onReceive(timer) { _ in model.tick() }
        .onChange(of: scenePhase) { _, phase in if phase != .active { model.pause() } }
        .sheet(isPresented: $showGuide) {
            HowToPlayView(play: { model.play() }, practice: { model.play(tutorial: true) })
        }
        .sheet(isPresented: $showSound) {
            SoundCheckView(model: model).presentationDetents([.medium, .large]).presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView(service: model.leaderboard, best: model.best, achievements: model.achievements)
        }
        .accessibilityAction(named: "Dribble") { model.gesture(.dribble) }
        .accessibilityAction(named: "Between the legs") { model.gesture(.between) }
        .accessibilityAction(named: "Behind the back") { model.gesture(.behind) }
        .accessibilityAction(named: "Shoot") { model.gesture(.shoot) }
    }
    private var idleAge: Double { model.now.truncatingRemainder(dividingBy: 8) }
    private var idleReaction: Reaction? {
        guard model.screen == .home, !reducedMotion, idleAge < GameModel.interludeDuration else { return nil }
        let reactions: [Reaction] = [.flex, .shrug, .clap]
        return reactions[Int(model.now / 8) % reactions.count]
    }
    private var header: some View {
        HStack {
            if model.screen != .playing {
                Image("ClubBadge").resizable().scaledToFit().frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 7)).accessibilityHidden(true)
            }
            Text("IM / SHADOW CLUB").font(.system(.caption2, design: .monospaced, weight: .bold)).tracking(2)
            Spacer()
            if model.screen == .playing {
                Text("\(model.game.score)").font(SportsType.score(24)).foregroundStyle(orange).monospacedDigit()
                    .accessibilityLabel("Score \(model.game.score)")
                Button {
                    model.pause()
                } label: {
                    Image(systemName: "pause.circle.fill").font(.title2)
                }.accessibilityLabel("Pause")
            } else {
                Button {
                    model.soundEnabled.toggle()
                } label: {
                    Image(systemName: model.soundEnabled ? "speaker.wave.2" : "speaker.slash")
                }.frame(width: 44, height: 44).accessibilityLabel(model.soundEnabled ? "Mute sound" : "Enable sound")
                Button {
                    showSound = true
                } label: {
                    Image(systemName: "slider.horizontal.3").frame(width: 44, height: 44)
                }.accessibilityLabel("Sound check").accessibilityIdentifier("soundCheck")
            }
        }.frame(minHeight: 28)
    }
    private var title: some View {
        VStack(spacing: 3) {
            Text(model.screen == .results ? (model.ending?.title ?? "TACTICAL EXIT.") : "IGNACIO\nMUSTACHO")
                .font(SportsType.display(model.screen == .results ? 52 : 58))
                .fontWidth(.condensed).shadow(color: .black.opacity(0.3), radius: 0, x: 2, y: 3)
                .tracking(-2).lineSpacing(-9).multilineTextAlignment(.center).minimumScaleFactor(0.7)
            Text("SHADOW BASKETBALLING").font(.system(.caption, design: .monospaced, weight: .bold)).tracking(2)
                .foregroundStyle(orange)
            Text("NO BALL. ALL SWAGGER.").font(SportsType.display(18, relativeTo: .subheadline)).tracking(1).padding(
                .top, 5)
        }.fixedSize(horizontal: false, vertical: true)
    }
    private var command: some View {
        VStack(spacing: 9) {
            HStack {
                Text(
                    model.game.tutorial
                        ? "WARM-UP \(model.game.index + 1)/4"
                        : "PACE \(model.game.paceLevel)  /  \(Int((60 / model.game.beatDuration).rounded())) BPM")
                Spacer()
                HStack(spacing: 5) {
                    ForEach(0..<3) { index in
                        Image(systemName: index < model.game.lives ? "heart.fill" : "heart").foregroundStyle(orange)
                    }
                }.accessibilityLabel("\(model.game.lives) lives")
            }.font(.system(.caption, design: .monospaced, weight: .bold))
            VStack(spacing: 5) {
                Text(model.game.move.rawValue.uppercased()).font(SportsType.display(34))
                    .minimumScaleFactor(0.65).lineLimit(1)
                Text(model.game.move.hint).font(.system(.caption, design: .monospaced, weight: .bold)).tracking(2)
            }.foregroundStyle(cream).frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(dark, in: RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(cream.opacity(0.5), lineWidth: 1))
        }
    }
    private var rhythmPanel: some View {
        VStack(spacing: 12) {
            HStack {
                Text("×\(model.game.combo) COMBO")
                Spacer()
                Text(model.game.tutorial ? "NO LIVES LOST" : "FEEL THE BEAT")
            }.font(.system(.caption2, design: .monospaced, weight: .bold))
            GeometryReader { geo in
                let travel = max(0, geo.size.width - 24)
                let zone = model.game.timing.validZone
                let ready = model.game.canAct(at: model.now)
                let green = Color(red: 0.12, green: 0.48, blue: 0.29)
                ZStack(alignment: .leading) {
                    Capsule().fill(orange.opacity(0.18)).frame(width: travel, height: 10).offset(x: 12)
                    Rectangle().fill(green.opacity(ready ? 0.35 : 0.18))
                        .overlay(Rectangle().strokeBorder(green, lineWidth: ready ? 3 : 2))
                        .frame(width: travel * (zone.upperBound - zone.lowerBound), height: 36)
                        .offset(x: 12 + travel * zone.lowerBound)
                        .accessibilityIdentifier("validTimingZone")
                    // Central beat is a guide; the entire outlined box accepts the gesture.
                    Rectangle().fill(green.opacity(0.6)).frame(width: 2, height: 28)
                        .offset(x: 11 + travel * model.game.timing.position(at: model.game.target))
                    Text("HIT ZONE").font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(green)
                        .frame(width: travel * (zone.upperBound - zone.lowerBound))
                        .offset(x: 12 + travel * zone.lowerBound, y: -29)
                    Circle().fill(cream).frame(width: 24, height: 24)
                        .overlay(Circle().strokeBorder(dark, lineWidth: 3))
                        .overlay(Circle().fill(dark).frame(width: 6, height: 6))
                        .offset(x: travel * model.approach)
                }.frame(height: 64, alignment: .bottomLeading)
            }.frame(height: 64)
                .overlay { TouchSurface(model: model).accessibilityHidden(true) }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Move while the center of the dot is inside the outlined hit zone")
                .accessibilityValue(model.timingCue)
            Text(model.timingCue)
                .font(SportsType.display(26, relativeTo: .headline))
                .foregroundStyle(model.game.canAct(at: model.now) ? Color(red: 0.12, green: 0.48, blue: 0.29) : dark)
                .lineLimit(1).minimumScaleFactor(0.65)
                .accessibilityIdentifier("timingCue")
            Text("START GESTURE WHEN DOT IS IN BOX")
                .font(.system(.caption2, design: .monospaced, weight: .bold))
                .lineLimit(1).minimumScaleFactor(0.75)
            HStack(spacing: 4) {
                moveButton("Tap", .dribble)
                moveButton("↓", .between)
                moveButton("↔", .behind)
                moveButton("↑", .shoot)
            }
        }.padding(18).foregroundStyle(dark)
            .background(cream, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(dark.opacity(0.25), lineWidth: 2))
    }
    private func moveButton(_ text: String, _ move: Move) -> some View {
        Button(text) { model.gesture(move) }.font(.caption.bold()).frame(maxWidth: .infinity).frame(height: 44)
            .background(dark.opacity(0.07), in: Capsule()).accessibilityLabel(move.rawValue)
    }
    private var homeControls: some View {
        VStack(spacing: 12) {
            primary("LET’S PLAY", identifier: "play") { model.firstPlay() }
            Button("How to Play") { showGuide = true }.font(SportsType.display(23)).frame(minHeight: 44)
                .accessibilityIdentifier("howToPlay")
            HStack {
                Button("Tutorial") { model.play(tutorial: true) }.accessibilityIdentifier("tutorial")
                Spacer()
                Button("Club records ↗") { showLeaderboard = true }.accessibilityIdentifier("clubRecords")
            }.font(.subheadline.bold())
            Text("PERSONAL BEST  /  \(model.best)").font(.system(.caption2, design: .monospaced, weight: .bold))
                .tracking(2).padding(.top, 6)
        }.padding(15).background(dark.opacity(0.96), in: RoundedRectangle(cornerRadius: 8))
    }
    private var results: some View {
        VStack(spacing: 10) {
            Text("OFFICIAL-ISH BOX SCORE").font(.system(.caption2, design: .monospaced, weight: .bold)).tracking(2)
                .foregroundStyle(ClubStyle.gold)
            Text("\(model.game.score)").font(SportsType.score(48))
                .accessibilityIdentifier("finalScore")
            Text(model.ending?.quip ?? "The moustache remains undefeated.")
                .font(.headline).multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            HStack {
                Text("BEST \(model.best)")
                Spacer()
                Text("\(Int((60 / model.game.beatDuration).rounded())) BPM")
                Spacer()
                Text("HONOURS \(model.earnedMilestones.count)/6")
            }.font(.system(.caption2, design: .monospaced, weight: .bold)).foregroundStyle(cream.opacity(0.85))
                .padding(.vertical, 6)
                .overlay(alignment: .top) { Rectangle().fill(cream.opacity(0.2)).frame(height: 1) }
            primary("PLAY AGAIN", identifier: "playAgain") { model.play() }
            Button("Back to club") { model.home() }.font(.subheadline.bold())
        }.padding(16).background(dark.opacity(0.96), in: RoundedRectangle(cornerRadius: 8))
    }
    private func primary(_ title: String, identifier: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title).tracking(2)
                Spacer()
                Image(systemName: "arrow.right")
            }
            .font(SportsType.display(26, relativeTo: .headline)).padding(20).foregroundStyle(cream)
            .background(orange, in: RoundedRectangle(cornerRadius: 12))
        }.accessibilityIdentifier(identifier)
    }
    private var pauseOverlay: some View {
        ZStack {
            dark.opacity(0.88).ignoresSafeArea()
            VStack(spacing: 22) {
                Text("TACTICAL HAIR BREAK.").font(SportsType.display(34)).foregroundStyle(cream).multilineTextAlignment(
                    .center)
                Text("The crowd is holding its imaginary breath.").font(.subheadline).multilineTextAlignment(.center)
                Button("Sound check") { showSound = true }.foregroundStyle(ClubStyle.gold)
                primary("RESUME", identifier: "resume") { model.resume() }
                Button("Back to club") {
                    model.home()
                    model.paused = false
                }.foregroundStyle(cream)
            }.padding(30)
        }
    }
}

struct LeaderboardView: View {
    @ObservedObject var service: LeaderboardService
    let best: Int
    var achievements: AchievementService?
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("TROPHY ROOM.\nPOPULATION: YOU.").font(SportsType.display(36))
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(best)").font(SportsType.score(52)).foregroundStyle(ClubStyle.gold)
                        Text("PERSONAL BEST").font(.system(.caption, design: .monospaced, weight: .bold))
                    }
                    Text("No selection committee. Remarkable taste in winners.").font(.subheadline)
                    if let achievements { AchievementList(service: achievements) }
                    VStack(alignment: .leading, spacing: 12) {
                        Text("BEYOND THE CLUB").font(SportsType.display(24))
                        Text(service.status).font(.subheadline)
                        Button("Connect Game Center") { service.show() }.buttonStyle(.borderedProminent)
                        Button("Game Center awards") { service.show(state: .achievements) }.buttonStyle(.bordered)
                        Text("Club awards are saved on this iPhone and work offline.").font(.caption)
                    }.padding(18).frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                }.padding(24)
            }
            .background(ClubStyle.green).foregroundStyle(ClubStyle.cream)
            .navigationTitle("Club records").navigationBarTitleDisplayMode(.inline)
            .toolbar { Button("Done") { dismiss() } }
            .toolbarBackground(ClubStyle.green, for: .navigationBar).toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }.tint(ClubStyle.orange)
    }
}

#if DEBUG
    private struct LaunchScreenReviewView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UIViewController {
            UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController() ?? UIViewController()
        }
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }
#endif

private struct AchievementList: View {
    @ObservedObject var service: AchievementService
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LOCAL CLUB HONOURS").font(SportsType.display(24)).foregroundStyle(ClubStyle.gold)
            ForEach(Milestone.standard) { award in
                HStack(spacing: 14) {
                    ZStack {
                        Circle().strokeBorder(
                            service.isEarned(award.threshold) ? ClubStyle.gold : ClubStyle.cream.opacity(0.25),
                            lineWidth: 2)
                        Text("\(award.threshold)").font(SportsType.score(19))
                    }.frame(width: 56, height: 56).accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(award.title.uppercased()).font(SportsType.display(22, relativeTo: .headline))
                            Spacer(minLength: 4)
                            if service.isEarned(award.threshold) {
                                Image(systemName: "checkmark.seal.fill").foregroundStyle(ClubStyle.gold)
                            }
                        }
                        Text(award.quip).font(.caption).foregroundStyle(ClubStyle.cream.opacity(0.85))
                        ProgressView(value: service.percentComplete(award.threshold), total: 100).tint(ClubStyle.gold)
                            .accessibilityLabel("\(award.title), \(award.threshold) points")
                            .accessibilityValue("\(Int(service.percentComplete(award.threshold))) percent")
                        Text(
                            service.isEarned(award.threshold)
                                ? "OFFICIALLY SELF-CERTIFIED" : "REACH \(award.threshold) POINTS IN ONE RUN"
                        )
                        .font(.system(size: 9, weight: .bold, design: .monospaced)).tracking(0.5)
                    }
                }.padding(14).background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
            }
            Text(service.status).font(.caption).foregroundStyle(ClubStyle.cream.opacity(0.7))
        }
    }
}
