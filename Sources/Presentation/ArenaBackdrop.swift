import SwiftUI

/// Original illustrated fieldhouse: timber, seating tiers and warm overhead light.
struct VectorArenaBackdrop: View {
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let horizon = h * 0.54
                let ink = Color(red: 0.055, green: 0.105, blue: 0.12)
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .linearGradient(
                        Gradient(colors: [ink, Color(red: 0.10, green: 0.22, blue: 0.23)]),
                        startPoint: .zero, endPoint: .init(x: 0, y: horizon)))
                func stroke(_ points: [CGPoint], color: Color, width: Double) {
                    var p = Path()
                    p.addLines(points)
                    context.stroke(p, with: .color(color), lineWidth: width)
                }
                // Roof trusses.
                for i in 0..<8 {
                    let x = Double(i) * w / 7
                    stroke([.init(x: x, y: 0), .init(x: w / 2, y: h * 0.28)], color: .black.opacity(0.2), width: 4)
                }
                // Stepped bleachers with a subdued, hand-patterned crowd.
                for row in 0..<6 {
                    let y = h * 0.35 + Double(row) * h * 0.037
                    context.fill(
                        Path(CGRect(x: 0, y: y, width: w, height: h * 0.027)), with: .color(.black.opacity(0.15)))
                    stroke(
                        [.init(x: 0, y: y + h * 0.027), .init(x: w, y: y + h * 0.027)], color: .white.opacity(0.055),
                        width: 1)
                    for seat in 0..<24 {
                        let x = Double(seat) * w / 23 + Double(row % 2) * 7
                        let shade = (seat * 13 + row * 7) % 5
                        let color: Color =
                            shade == 0
                            ? Color(red: 0.41, green: 0.34, blue: 0.25) : Color(red: 0.13, green: 0.24, blue: 0.24)
                        context.fill(Path(ellipseIn: .init(x: x, y: y - 6, width: 6, height: 7)), with: .color(color))
                        context.fill(
                            Path(roundedRect: .init(x: x - 2, y: y, width: 10, height: 9), cornerRadius: 3),
                            with: .color(color))
                    }
                }
                let boards = CGRect(x: 0, y: horizon, width: w, height: h - horizon)
                context.fill(
                    Path(boards),
                    with: .linearGradient(
                        Gradient(colors: [
                            Color(red: 0.64, green: 0.39, blue: 0.20), Color(red: 0.87, green: 0.66, blue: 0.39),
                        ]),
                        startPoint: .init(x: 0, y: horizon), endPoint: .init(x: 0, y: h)))
                for plank in -8...8 {
                    let topX = w / 2 + Double(plank) * 20
                    let bottomX = w / 2 + Double(plank) * 70
                    stroke(
                        [.init(x: topX, y: horizon), .init(x: bottomX, y: h)], color: .black.opacity(0.10), width: 1)
                }
                for row in 1..<12 {
                    let ratio = Double(row) / 11
                    let y = horizon + ratio * ratio * (h - horizon)
                    stroke([.init(x: 0, y: y), .init(x: w, y: y)], color: .black.opacity(0.075), width: 1)
                }
                let ivory = Color(red: 1, green: 0.94, blue: 0.75)
                stroke(
                    [.init(x: 0, y: horizon + 10), .init(x: w, y: horizon + 10)], color: ivory.opacity(0.75), width: 3)
                context.stroke(
                    Path(ellipseIn: .init(x: -w * 0.1, y: horizon + 45, width: w * 1.2, height: h * 0.27)),
                    with: .color(ivory.opacity(0.5)), lineWidth: 3)
                stroke([.init(x: w / 2, y: horizon), .init(x: w / 2, y: h)], color: ivory.opacity(0.4), width: 2)
                // Pools of light, with lamps and soft translucent beams.
                for x in [w * 0.12, w * 0.5, w * 0.88] {
                    var beam = Path()
                    beam.addLines([
                        .init(x: x - 9, y: h * 0.21), .init(x: x + 9, y: h * 0.21),
                        .init(x: x + 120, y: h * 0.80), .init(x: x - 120, y: h * 0.80),
                    ])
                    beam.closeSubpath()
                    context.fill(beam, with: .color(ivory.opacity(0.035)))
                    context.fill(
                        Path(roundedRect: .init(x: x - 16, y: h * 0.21, width: 32, height: 4), cornerRadius: 2),
                        with: .color(ivory.opacity(0.65)))
                }
            }
            Text("MUSTACHO FIELDHOUSE").font(.system(size: 10, weight: .black, design: .monospaced))
                .tracking(4).foregroundStyle(.white.opacity(0.2)).frame(maxWidth: .infinity)
                .position(x: geo.size.width / 2, y: geo.size.height * 0.32)
        }.accessibilityHidden(true)
    }
}

struct ArenaBackdrop: View {
    var body: some View {
        GeometryReader { geometry in
            if let artwork = UIImage(named: "arena-v1") {
                Image(uiImage: artwork).resizable().scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height).clipped()
                    .overlay(
                        LinearGradient(
                            colors: [.black.opacity(0.38), .clear, .black.opacity(0.05)], startPoint: .top,
                            endPoint: .bottom))
            } else {
                VectorArenaBackdrop()
            }
        }.accessibilityHidden(true)
    }
}
