import SwiftUI

/// Hand-authored sports-poster puppet. Canonical face: Documentation/CharacterReferences.
/// Keyframes animate planted feet, bent knees, weight transfer and follow-through.
struct VectorIgnacioCharacter: View {
    var move: Move?
    var time: Double
    var moveAge: Double
    var reducedMotion: Bool
    var anticipation = 0.0

    private var pose: AthletePose {
        let idle = AthletePose.idle
        guard let move else { return idle }
        let ready = AthletePose.ready(for: move)
        let action = AthletePose.action(for: move)
        if anticipation > 0 { return idle.blend(to: ready, amount: anticipation) }
        if reducedMotion { return action }
        let t = max(0, moveAge)
        if t < 0.12 { return idle.blend(to: ready, amount: t / 0.12) }
        if t < 0.32 { return ready.blend(to: action, amount: (t - 0.12) / 0.20) }
        if t < 0.48 { return action }
        return action.blend(to: idle, amount: min(1, (t - 0.48) / 0.37))
    }
    var body: some View {
        Canvas { context, size in
            let scale = min(size.width / 300, size.height / 440)
            context.translateBy(x: (size.width - 300 * scale) / 2, y: (size.height - 440 * scale) / 2)
            context.scaleBy(x: scale, y: scale)
            let pose = pose
            let skin = Color(red: 0.48, green: 0.25, blue: 0.14)
            let lightSkin = Color(red: 0.72, green: 0.44, blue: 0.27)
            let ink = Color(red: 0.07, green: 0.10, blue: 0.10)
            let green = Color(red: 0.09, green: 0.34, blue: 0.27)
            let ivory = Color(red: 0.97, green: 0.92, blue: 0.77)
            func ellipse(_ rect: CGRect, _ color: Color) { context.fill(Path(ellipseIn: rect), with: .color(color)) }
            func line(_ points: [CGPoint], _ color: Color, _ width: Double) {
                var path = Path()
                path.addLines(points)
                context.stroke(
                    path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
            }
            func polygon(_ points: [CGPoint], _ color: Color) {
                var path = Path()
                path.addLines(points)
                path.closeSubpath()
                context.fill(path, with: .color(color))
                context.stroke(path, with: .color(ink), style: StrokeStyle(lineWidth: 2, lineJoin: .round))
            }
            func limb(_ points: [CGPoint], _ color: Color, width: Double = 15) {
                line(points, ink, width + 4)
                line(points, color, width)
            }
            ellipse(.init(x: 57, y: 406, width: 188, height: 17), .black.opacity(0.22))
            ellipse(.init(x: 85, y: 410, width: 130, height: 9), .black.opacity(0.15))
            // Feet stay planted in crouches and lift independently during the shot.
            for (hipX, knee, ankle, color) in [
                (129.0, pose.leftKnee, pose.leftFoot, skin),
                (169.0, pose.rightKnee, pose.rightFoot, lightSkin),
            ] {
                limb([.init(x: hipX + pose.shift, y: 268 + pose.drop), knee, ankle], color)
                line([.init(x: ankle.x, y: ankle.y - 22), ankle], ivory, 17)
                line([.init(x: ankle.x - 8, y: ankle.y - 18), .init(x: ankle.x + 8, y: ankle.y - 18)], green, 3)
                polygon(
                    [
                        .init(x: ankle.x - 9, y: ankle.y - 3), .init(x: ankle.x + 8, y: ankle.y - 5),
                        .init(x: ankle.x + 25, y: ankle.y + 7), .init(x: ankle.x + 25, y: ankle.y + 14),
                        .init(x: ankle.x - 13, y: ankle.y + 14), .init(x: ankle.x - 16, y: ankle.y + 8),
                    ], ivory)
                line([.init(x: ankle.x - 10, y: ankle.y + 11), .init(x: ankle.x + 23, y: ankle.y + 11)], ink, 3)
                line([.init(x: ankle.x - 2, y: ankle.y + 1), .init(x: ankle.x + 9, y: ankle.y + 4)], green, 4)
            }
            context.translateBy(x: pose.shift, y: pose.drop + (reducedMotion ? 0 : sin(time * 4) * 1.5))
            context.translateBy(x: 150, y: 245)
            context.rotate(by: .degrees(pose.lean))
            context.translateBy(x: -150, y: -245)
            // Action arcs describe the empty-handed movement; no ball graphic.
            if move == .behind && moveAge > 0.12 && moveAge < 0.55 && anticipation == 0 {
                var arc = Path()
                arc.move(to: .init(x: 65, y: 223))
                arc.addCurve(to: .init(x: 229, y: 235), control1: .init(x: 76, y: 285), control2: .init(x: 211, y: 285))
                context.stroke(arc, with: .color(ivory.opacity(0.7)), style: StrokeStyle(lineWidth: 3, dash: [12, 7]))
            }
            for (shoulder, elbow, hand, color) in [
                (CGPoint(x: 118, y: 151), pose.leftElbow, pose.leftHand, skin),
                (CGPoint(x: 181, y: 151), pose.rightElbow, pose.rightHand, lightSkin),
            ] {
                limb([shoulder, elbow, hand], color, width: 13)
                ellipse(.init(x: hand.x - 7, y: hand.y - 5, width: 14, height: 18), color)
                let direction: Double = move == .shoot ? -1 : 1
                for finger in 0..<3 {
                    let dx = Double(finger - 1) * 4
                    line(
                        [
                            .init(x: hand.x + dx, y: hand.y + direction * 4),
                            .init(
                                x: hand.x + dx + (move == .shoot ? 5 : 0), y: hand.y + direction * (13 - abs(dx) / 2)),
                        ], color, 3)
                }
            }
            polygon(
                [
                    .init(x: 114, y: 230), .init(x: 184, y: 230), .init(x: 192, y: 280),
                    .init(x: 159, y: 282), .init(x: 150, y: 255), .init(x: 141, y: 283), .init(x: 104, y: 280),
                ], green)
            line([.init(x: 110, y: 275), .init(x: 138, y: 277)], ivory, 5)
            line([.init(x: 163, y: 276), .init(x: 188, y: 275)], ivory, 5)
            polygon(
                [
                    .init(x: 120, y: 139), .init(x: 137, y: 135), .init(x: 164, y: 135),
                    .init(x: 181, y: 139), .init(x: 175, y: 182), .init(x: 183, y: 235),
                    .init(x: 113, y: 235), .init(x: 123, y: 185),
                ], green)
            polygon(
                [.init(x: 120, y: 148), .init(x: 130, y: 180), .init(x: 123, y: 229), .init(x: 114, y: 229)],
                .black.opacity(0.17))
            line([.init(x: 121, y: 144), .init(x: 126, y: 173)], ivory, 5)
            line([.init(x: 180, y: 144), .init(x: 175, y: 173)], ivory, 5)
            line([.init(x: 115, y: 230), .init(x: 181, y: 230)], ivory, 4)
            context.draw(
                Text("SHADOW").font(.system(size: 10, weight: .black, design: .monospaced)).foregroundStyle(ivory),
                at: .init(x: 151, y: 174))
            context.draw(
                Text("00").font(SportsType.display(39)).foregroundStyle(ivory),
                at: .init(x: 150, y: 202))
            // Fabric folds and side seam reinforce the screen-printed sports illustration.
            line([.init(x: 168, y: 211), .init(x: 160, y: 221)], ivory.opacity(0.3), 1)
            line([.init(x: 128, y: 207), .init(x: 133, y: 222)], .black.opacity(0.25), 2)
            limb([.init(x: 149, y: 120), .init(x: 149, y: 141)], skin, width: 20)
            // Face proportions are reduced slightly relative to the more athletic body.
            context.translateBy(x: 150, y: 136)
            context.scaleBy(x: 0.87, y: 0.92)
            context.translateBy(x: -150, y: -136)
            ellipse(.init(x: 116, y: 63, width: 68, height: 77), lightSkin)
            ellipse(.init(x: 111, y: 94, width: 13, height: 22), skin)
            ellipse(.init(x: 177, y: 94, width: 13, height: 22), lightSkin)
            let hair = Color(red: 0.075, green: 0.065, blue: 0.06)
            let hairHighlight = Color(red: 0.19, green: 0.16, blue: 0.14)
            // Full fringe and large swept-up side wings, not curls or a sweatband.
            var coiffure = Path()
            coiffure.move(to: .init(x: 113, y: 78))
            coiffure.addCurve(to: .init(x: 145, y: 40), control1: .init(x: 108, y: 50), control2: .init(x: 126, y: 36))
            coiffure.addCurve(to: .init(x: 184, y: 76), control1: .init(x: 175, y: 31), control2: .init(x: 190, y: 51))
            coiffure.addCurve(to: .init(x: 208, y: 64), control1: .init(x: 193, y: 89), control2: .init(x: 207, y: 83))
            coiffure.addCurve(
                to: .init(x: 179, y: 121), control1: .init(x: 225, y: 91), control2: .init(x: 202, y: 120))
            coiffure.addCurve(to: .init(x: 176, y: 81), control1: .init(x: 182, y: 108), control2: .init(x: 179, y: 92))
            coiffure.addCurve(to: .init(x: 123, y: 82), control1: .init(x: 162, y: 86), control2: .init(x: 138, y: 77))
            coiffure.addCurve(
                to: .init(x: 121, y: 121), control1: .init(x: 120, y: 94), control2: .init(x: 117, y: 107))
            coiffure.addCurve(to: .init(x: 91, y: 64), control1: .init(x: 93, y: 119), control2: .init(x: 76, y: 92))
            coiffure.addCurve(to: .init(x: 113, y: 78), control1: .init(x: 88, y: 86), control2: .init(x: 103, y: 90))
            coiffure.closeSubpath()
            context.fill(coiffure, with: .color(hair))
            // Flowing strand highlights preserve the broad, smooth silhouette.
            for side in [-1.0, 1.0] {
                for strand in 0..<3 {
                    let inset = Double(strand) * 4
                    var sweep = Path()
                    sweep.move(to: .init(x: 150 + side * (29 + inset / 2), y: 85 + inset))
                    sweep.addCurve(
                        to: .init(x: 150 + side * (55 - inset / 2), y: 78 + inset),
                        control1: .init(x: 150 + side * 43, y: 108 + inset),
                        control2: .init(x: 150 + side * 57, y: 96 + inset))
                    context.stroke(
                        sweep, with: .color(hairHighlight), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
                }
            }
            for strand in 0..<7 {
                let x = 124 + Double(strand) * 8
                var fringe = Path()
                fringe.move(to: .init(x: 149 + (x - 149) * 0.65, y: 46))
                fringe.addCurve(
                    to: .init(x: x, y: 76), control1: .init(x: x - 5, y: 51), control2: .init(x: x + 4, y: 66))
                context.stroke(fringe, with: .color(hairHighlight.opacity(0.7)), lineWidth: 1)
            }
            // Large expressive eyes and heavy, angled brows are identity anchors.
            for x in [127.0, 157.0] {
                ellipse(.init(x: x - 1, y: 93, width: 19, height: 17), skin)
                ellipse(.init(x: x, y: 94, width: 17, height: 14), .init(red: 1, green: 0.96, blue: 0.88))
                ellipse(.init(x: x + 4, y: 94, width: 10, height: 13), hairHighlight)
                ellipse(.init(x: x + 6, y: 96, width: 6, height: 9), hair)
                ellipse(.init(x: x + 6, y: 96, width: 3, height: 3), .white)
            }
            line([.init(x: 126, y: 87), .init(x: 133, y: 86), .init(x: 143, y: 90)], hair, 7)
            line([.init(x: 157, y: 90), .init(x: 167, y: 86), .init(x: 174, y: 87)], hair, 7)
            ellipse(.init(x: 142, y: 103, width: 16, height: 15), skin)
            ellipse(.init(x: 146, y: 104, width: 9, height: 9), lightSkin)
            ellipse(.init(x: 142, y: 124, width: 18, height: 8), .init(red: 0.57, green: 0.28, blue: 0.23))
            line([.init(x: 146, y: 127), .init(x: 156, y: 127)], .init(red: 0.85, green: 0.53, blue: 0.43), 2)
            // Oversized moustache spans beyond both cheeks, with visibly lifted tips.
            for side in [-1.0, 1.0] {
                func point(_ x: Double, _ y: Double) -> CGPoint { .init(x: 150 + side * x, y: y) }
                var moustache = Path()
                moustache.move(to: point(0, 115))
                moustache.addCurve(to: point(40, 105), control1: point(14, 104), control2: point(31, 122))
                moustache.addCurve(to: point(30, 129), control1: point(47, 112), control2: point(42, 127))
                moustache.addCurve(to: point(0, 121), control1: point(19, 132), control2: point(6, 123))
                moustache.closeSubpath()
                context.fill(moustache, with: .color(hair))
                var ridge = Path()
                ridge.move(to: point(8, 116))
                ridge.addCurve(to: point(38, 113), control1: point(23, 124), control2: point(33, 121))
                context.stroke(ridge, with: .color(hairHighlight), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
            }

        }
        .accessibilityLabel(
            "Ignacio Mustacho, swept black hair and broad moustache, performing \(move?.rawValue ?? "his ready stance") without a ball"
        )
    }
}

private struct AthletePose {
    var shift = 0.0
    var drop = 0.0
    var lean = 0.0
    var leftElbow = CGPoint(x: 87, y: 204)
    var rightElbow = CGPoint(x: 208, y: 192)
    var leftHand = CGPoint(x: 109, y: 234)
    var rightHand = CGPoint(x: 193, y: 230)
    var leftKnee = CGPoint(x: 116, y: 328)
    var rightKnee = CGPoint(x: 188, y: 326)
    var leftFoot = CGPoint(x: 100, y: 390)
    var rightFoot = CGPoint(x: 201, y: 390)
    static let idle = AthletePose()
    static func ready(for move: Move) -> AthletePose {
        var p = idle
        p.drop = 12
        p.leftKnee.x = 103
        p.rightKnee.x = 196
        switch move {
        case .dribble:
            p.rightElbow = .init(x: 208, y: 163)
            p.rightHand = .init(x: 223, y: 183)
            p.lean = -4
        case .between:
            p.leftHand = .init(x: 90, y: 209)
            p.rightHand = .init(x: 198, y: 245)
            p.lean = -5
        case .behind:
            p.rightHand = .init(x: 232, y: 222)
            p.rightElbow = .init(x: 220, y: 181)
            p.lean = 6
        case .shoot:
            p.drop = 19
            p.leftElbow = .init(x: 106, y: 176)
            p.rightElbow = .init(x: 196, y: 174)
            p.leftHand = .init(x: 139, y: 127)
            p.rightHand = .init(x: 163, y: 119)
        }
        return p
    }
    static func action(for move: Move) -> AthletePose {
        var p = idle
        switch move {
        case .dribble:
            p.shift = 10
            p.drop = 10
            p.lean = 8
            p.rightElbow = .init(x: 220, y: 211)
            p.rightHand = .init(x: 228, y: 270)
            p.leftElbow = .init(x: 87, y: 179)
            p.leftHand = .init(x: 116, y: 207)
            p.leftKnee = .init(x: 106, y: 329)
            p.rightKnee = .init(x: 194, y: 337)
        case .between:
            p.drop = 29
            p.shift = -6
            p.lean = -7
            p.leftElbow = .init(x: 96, y: 222)
            p.leftHand = .init(x: 156, y: 291)
            p.rightElbow = .init(x: 216, y: 202)
            p.rightHand = .init(x: 193, y: 250)
            p.leftKnee = .init(x: 81, y: 326)
            p.rightKnee = .init(x: 218, y: 328)
            p.leftFoot = .init(x: 63, y: 390)
            p.rightFoot = .init(x: 235, y: 390)
        case .behind:
            p.shift = -8
            p.drop = 7
            p.lean = -12
            p.leftElbow = .init(x: 77, y: 205)
            p.leftHand = .init(x: 134, y: 239)
            p.rightElbow = .init(x: 228, y: 221)
            p.rightHand = .init(x: 143, y: 247)
            p.leftKnee = .init(x: 108, y: 329)
            p.rightKnee = .init(x: 176, y: 321)
            p.rightFoot = .init(x: 171, y: 384)
        case .shoot:
            p.drop = -8
            p.lean = -3
            p.leftElbow = .init(x: 114, y: 83)
            p.rightElbow = .init(x: 193, y: 76)
            p.leftHand = .init(x: 139, y: 37)
            p.rightHand = .init(x: 166, y: 29)
            p.leftKnee = .init(x: 128, y: 318)
            p.rightKnee = .init(x: 176, y: 317)
            p.leftFoot = .init(x: 121, y: 374)
            p.rightFoot = .init(x: 184, y: 369)
        }
        return p
    }
    func blend(to other: AthletePose, amount: Double) -> AthletePose {
        let t = max(0, min(1, amount))
        let eased = t * t * (3 - 2 * t)
        func scalar(_ a: Double, _ b: Double) -> Double { a + (b - a) * eased }
        func point(_ a: CGPoint, _ b: CGPoint) -> CGPoint { .init(x: scalar(a.x, b.x), y: scalar(a.y, b.y)) }
        return AthletePose(
            shift: scalar(shift, other.shift), drop: scalar(drop, other.drop), lean: scalar(lean, other.lean),
            leftElbow: point(leftElbow, other.leftElbow), rightElbow: point(rightElbow, other.rightElbow),
            leftHand: point(leftHand, other.leftHand), rightHand: point(rightHand, other.rightHand),
            leftKnee: point(leftKnee, other.leftKnee), rightKnee: point(rightKnee, other.rightKnee),
            leftFoot: point(leftFoot, other.leftFoot), rightFoot: point(rightFoot, other.rightFoot))
    }
}

#if DEBUG
    struct MotionReviewView: View {
        var body: some View {
            ZStack {
                ArenaBackdrop().ignoresSafeArea()
                VStack(spacing: 12) {
                    Text("MOVEMENT STUDIES").font(.system(.title2, design: .monospaced, weight: .black))
                        .foregroundStyle(.white)
                    Text("IGNACIO MUSTACHO / EMPTY-HANDED BASKETBALL").font(
                        .system(size: 9, weight: .bold, design: .monospaced)
                    )
                    .foregroundStyle(.white.opacity(0.6))
                    ForEach(0..<2) { row in
                        HStack(spacing: 8) {
                            ForEach(0..<2) { column in
                                let move = Move.allCases[row * 2 + column]
                                VStack(spacing: 0) {
                                    Text(move.rawValue.uppercased()).font(
                                        .system(size: 10, weight: .black, design: .monospaced)
                                    )
                                    .foregroundStyle(.white).padding(.top, 12)
                                    TimelineView(.animation) { timeline in
                                        let animate = ProcessInfo.processInfo.arguments.contains("--motion-loop")
                                        let phase = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(
                                            dividingBy: 1.4)
                                        IgnacioCharacter(
                                            move: move, time: 0, moveAge: animate ? phase : 0.36, reducedMotion: false)
                                    }
                                }.background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 6))
                            }
                        }
                    }
                    Text("Sprite keyframes · preparation / action / follow-through")
                        .font(.system(size: 9, weight: .medium, design: .monospaced)).foregroundStyle(
                            .white.opacity(0.7))
                }.padding(16)
            }
        }
    }
#endif

#if DEBUG
    struct ReactionReviewView: View {
        @Environment(\.accessibilityReduceMotion) private var reducedMotion
        var body: some View {
            ZStack {
                ArenaBackdrop().ignoresSafeArea()
                VStack(spacing: 8) {
                    Text("THE VERY OFFICIAL TROPHY ROOM").font(SportsType.display(25))
                    Text("ANIMATION REVIEW · SIX POINT MILESTONES").font(.system(size: 9, design: .monospaced))
                    TimelineView(.animation(minimumInterval: 1.0 / 24, paused: reducedMotion)) { context in
                        let age = context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1.8)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(Milestone.standard) { award in
                                VStack(spacing: 3) {
                                    Text("\(award.threshold) · \(award.title)").font(SportsType.display(20))
                                    IgnacioCharacter(
                                        move: nil, time: 0, moveAge: 0, reducedMotion: reducedMotion,
                                        reaction: award.reaction, reactionAge: age
                                    ).frame(height: 155)
                                    Text(award.quip).font(.system(size: 10, weight: .medium)).multilineTextAlignment(
                                        .center
                                    )
                                    .frame(height: 30)
                                }.padding(6).background(.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    Text("No scouts were inconvenienced.").font(.caption)
                }.padding(12).foregroundStyle(.white)
            }
        }
    }
#endif
