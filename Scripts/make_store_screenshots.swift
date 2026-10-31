// Layout of real app captures with native typography; gameplay pixels are only scaled.
import AppKit
import ImageIO
import UniformTypeIdentifiers

let cream = NSColor(srgbRed: 0.97, green: 0.94, blue: 0.84, alpha: 1)
let green = NSColor(srgbRed: 0.075, green: 0.19, blue: 0.15, alpha: 1)
let orange = NSColor(srgbRed: 0.94, green: 0.35, blue: 0.17, alpha: 1)
let width = 1320
let height = 2868
let root = "AppStore/"
let cards = [
    ("01-Shadow-Basketball.png", "Home.png", "NO BALL.\nALL SWAGGER.", "Shadow basketball. Real rhythm."),
    ("02-Hit-The-Zone.png", "TimingNow.png", "FOUR MOVES.\nONE BEAT.", "Tap. Swipe. Hit the zone."),
    ("03-Find-Your-Flow.png", "HowToPlay.png", "START SLOW.\nFIND YOUR FLOW.", "Learn the moves. Then own the rhythm."),
    ("04-Keep-The-Ego.png", "GameOver.png", "LOSE THE GAME.\nKEEP THE EGO.", "Even defeat deserves a dramatic exit."),
]
func text(_ value: String, x: CGFloat, top: CGFloat, size: CGFloat, color: NSColor, face: String, maxWidth: CGFloat) {
    let font = NSFont(name: face, size: size) ?? NSFont.boldSystemFont(ofSize: size)
    let paragraph = NSMutableParagraphStyle()
    paragraph.lineSpacing = -5
    let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color, .paragraphStyle: paragraph]
    let rect = (value as NSString).boundingRect(with: NSSize(width: maxWidth, height: 1000), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes)
    (value as NSString).draw(in: NSRect(x: x, y: CGFloat(height) - top - rect.height, width: maxWidth, height: rect.height + 4), withAttributes: attributes)
}
for (index, card) in cards.enumerated() {
    guard let canvas = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
        space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue),
        let shot = NSImage(contentsOfFile: root + "RawScreenshots/" + card.1)
    else { fatalError("Missing actual capture: \(card.1)") }
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: canvas, flipped: false)
    green.setFill(); NSBezierPath(rect: NSRect(x: 0, y: 0, width: width, height: height)).fill()
    orange.setFill(); NSBezierPath(rect: NSRect(x: 82, y: height - 98, width: 54, height: 7)).fill()
    text("IGNACIO MUSTACHO   /   SHADOW CLUB", x: 158, top: 67, size: 26, color: cream, face: "Menlo-Bold", maxWidth: 1080)
    text(card.2, x: 82, top: 150, size: 116, color: cream, face: "AvenirNextCondensed-Heavy", maxWidth: 1156)
    text(card.3, x: 86, top: 465, size: 36, color: cream.withAlphaComponent(0.85), face: "AvenirNext-Medium", maxWidth: 1150)
    let screenWidth: CGFloat = 984
    let screenHeight = screenWidth * shot.size.height / shot.size.width
    let screenRect = NSRect(x: (CGFloat(width) - screenWidth) / 2, y: 132, width: screenWidth, height: screenHeight)
    cream.withAlphaComponent(0.75).setFill()
    NSBezierPath(roundedRect: screenRect.insetBy(dx: -3, dy: -3), xRadius: 38, yRadius: 38).fill()
    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(roundedRect: screenRect, xRadius: 36, yRadius: 36).addClip()
    shot.draw(in: screenRect, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: false, hints: [.interpolation: NSImageInterpolation.high])
    NSGraphicsContext.restoreGraphicsState()
    text("\(index + 1) / \(cards.count)", x: 1130, top: 2790, size: 24, color: cream.withAlphaComponent(0.65), face: "Menlo-Bold", maxWidth: 160)
    NSGraphicsContext.restoreGraphicsState()
    guard let output = canvas.makeImage(), let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: root + "Screenshots/" + card.0) as CFURL, UTType.png.identifier as CFString, 1, nil) else { fatalError("Cannot export") }
    CGImageDestinationAddImage(destination, output, nil)
    guard CGImageDestinationFinalize(destination) else { fatalError("Cannot save") }
}
