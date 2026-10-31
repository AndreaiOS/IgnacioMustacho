import SwiftUI
import UIKit

private struct SpriteLayout: Decodable {
    struct Frame: Decodable {
        let rect: [Int]
        let anchor: [Double]
        let exclusions: [[Int]]
    }
    let asset: String
    let neutralHeight: Double
    let frames: [Frame]
}
struct RegisteredSprite {
    let image: UIImage
    let anchor: CGPoint
    let neutralHeight: Double
    let exclusions: [CGRect]
}

/// Reads original PNGs without modifying pixels; explicit crop/foot registration
/// prevents the imperfect generated grid from clipping hands or moving the floor.
@MainActor enum IgnacioSprites {
    static let frames: [[RegisteredSprite]] = {
        guard let url = Bundle.main.url(forResource: "SpriteLayout", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let layouts = try? JSONDecoder().decode([SpriteLayout].self, from: data)
        else { return [] }
        return layouts.map { layout in
            guard let atlas = UIImage(named: layout.asset)?.cgImage else { return [] }
            return layout.frames.compactMap { frame in
                guard frame.rect.count == 4, frame.anchor.count == 2,
                    let image = atlas.cropping(
                        to: CGRect(x: frame.rect[0], y: frame.rect[1], width: frame.rect[2], height: frame.rect[3]))
                else { return nil }
                return RegisteredSprite(
                    image: UIImage(cgImage: image), anchor: CGPoint(x: frame.anchor[0], y: frame.anchor[1]),
                    neutralHeight: layout.neutralHeight,
                    exclusions: frame.exclusions.filter { $0.count == 4 }.map {
                        CGRect(x: $0[0], y: $0[1], width: $0[2], height: $0[3])
                    })
            }
        }
    }()
}

/// Distinct drawn in-betweens, never opacity blends or optical-flow limbs.
enum SpritePlayback {
    static func frame(at age: Double) -> Int {
        let ends = [0.045, 0.095, 0.15, 0.21, 0.28, 0.36, 0.45, 0.55, 0.65, 0.75, 0.85]
        return ends.firstIndex(where: { age < $0 }).map { $0 + 1 } ?? 0
    }
}
struct IgnacioCharacter: View {
    var move: Move?
    var time: Double
    var moveAge: Double
    var reducedMotion: Bool
    var anticipation = 0.0
    var reaction: Reaction? = nil
    var reactionAge = 0.0
    private var row: Int {
        if let reaction { return 4 + (Reaction.allCases.firstIndex(of: reaction) ?? 0) }
        return Move.allCases.firstIndex(of: move ?? .dribble) ?? 0
    }
    private var frame: Int {
        if reaction != nil {
            return reducedMotion ? 5 : min(11, max(0, Int(reactionAge / GameModel.interludeDuration * 12)))
        }
        guard move != nil else { return 0 }
        if anticipation > 0 { return anticipation > 0.25 ? 1 : 0 }
        return reducedMotion ? 6 : SpritePlayback.frame(at: moveAge)
    }
    var body: some View {
        if IgnacioSprites.frames.count == 10, IgnacioSprites.frames[row].count == 12 {
            GeometryReader { geometry in
                let sprite = IgnacioSprites.frames[row][frame]
                let scale = geometry.size.height * (reaction == nil ? 0.77 : 0.65) / sprite.neutralHeight
                let floor = geometry.size.height * 0.95
                let lift =
                    reaction == nil && move == .shoot && (6...8).contains(frame) ? geometry.size.height * 0.025 : 0
                ZStack {
                    Ellipse().fill(.black.opacity(0.22))
                        .frame(width: geometry.size.width * 0.48, height: 10)
                        .position(x: geometry.size.width / 2, y: floor)
                    Image(uiImage: sprite.image).resizable().interpolation(.high)
                        .frame(width: sprite.image.size.width * scale, height: sprite.image.size.height * scale)
                        .mask(
                            SpriteWindow(exclusions: sprite.exclusions, sourceSize: sprite.image.size).fill(
                                style: FillStyle(eoFill: true))
                        )
                        .position(
                            x: geometry.size.width / 2 + (sprite.image.size.width / 2 - sprite.anchor.x) * scale,
                            y: floor + (sprite.image.size.height / 2 - sprite.anchor.y) * scale - lift)
                }
                .transaction { $0.animation = nil }
                .offset(y: reducedMotion || move != nil || reaction != nil ? 0 : sin(time * 2.6) * 1.2)
            }
            .accessibilityLabel(
                "Ignacio Mustacho performing \(reaction?.rawValue ?? move?.rawValue ?? "his ready stance") without a ball"
            )
        } else {
            VectorIgnacioCharacter(
                move: move, time: time, moveAge: moveAge, reducedMotion: reducedMotion, anticipation: anticipation)
        }
    }
}

/// Atlas fragments from adjacent figures are clipped in the view, not painted over.
private struct SpriteWindow: Shape {
    let exclusions: [CGRect]
    let sourceSize: CGSize
    func path(in rect: CGRect) -> Path {
        var path = Path(rect)
        let sx = rect.width / sourceSize.width
        let sy = rect.height / sourceSize.height
        for exclusion in exclusions {
            path.addRect(
                CGRect(
                    x: exclusion.minX * sx, y: exclusion.minY * sy, width: exclusion.width * sx,
                    height: exclusion.height * sy))
        }
        return path
    }
}
