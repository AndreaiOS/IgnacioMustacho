// Layout of real app captures with native typography; gameplay pixels are only scaled.
import AppKit
import ImageIO
import UniformTypeIdentifiers

let paper = NSColor(srgbRed: 0.97, green: 0.98, blue: 1.00, alpha: 1)
let navy = NSColor(srgbRed: 0.035, green: 0.075, blue: 0.16, alpha: 1)
let red = NSColor(srgbRed: 0.79, green: 0.09, blue: 0.17, alpha: 1)
let width = 1320
let height = 2868
let root = "AppStore/"
// Optional output dimensions and folder; retain the design's aspect ratio.
let arguments = CommandLine.arguments
let outputWidth = arguments.count > 1 ? Int(arguments[1]) ?? width : width
let outputHeight = arguments.count > 2 ? Int(arguments[2]) ?? height : height
let outputFolder = arguments.count > 3 ? arguments[3] : root + "Screenshots"
precondition(outputWidth > 0 && outputHeight > 0)
try FileManager.default.createDirectory(atPath: outputFolder, withIntermediateDirectories: true)
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
    guard let canvas = CGContext(data: nil, width: outputWidth, height: outputHeight, bitsPerComponent: 8, bytesPerRow: outputWidth * 4,
        space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue),
        let shot = NSImage(contentsOfFile: root + "RawScreenshots/" + card.1)
    else { fatalError("Missing actual capture: \(card.1)") }
    canvas.setFillColor(navy.cgColor)
    canvas.fill(CGRect(x: 0, y: 0, width: outputWidth, height: outputHeight))
    let scale = min(CGFloat(outputWidth) / CGFloat(width), CGFloat(outputHeight) / CGFloat(height))
    canvas.translateBy(x: (CGFloat(outputWidth) - CGFloat(width) * scale) / 2,
                       y: (CGFloat(outputHeight) - CGFloat(height) * scale) / 2)
    canvas.scaleBy(x: scale, y: scale)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: canvas, flipped: false)
    navy.setFill(); NSBezierPath(rect: NSRect(x: 0, y: 0, width: width, height: height)).fill()
    red.setFill(); NSBezierPath(rect: NSRect(x: 82, y: height - 98, width: 54, height: 7)).fill()
    text("IGNACIO MUSTACHO   /   SHADOW CLUB", x: 158, top: 67, size: 26, color: paper, face: "HelveticaNeue-Medium", maxWidth: 1080)
    text(card.2, x: 82, top: 150, size: 94, color: paper, face: "HelveticaNeue-Bold", maxWidth: 1156)
    text(card.3, x: 86, top: 430, size: 32, color: paper.withAlphaComponent(0.85), face: "HelveticaNeue", maxWidth: 1150)
    let screenWidth: CGFloat = 984
    let screenHeight = screenWidth * shot.size.height / shot.size.width
    let screenRect = NSRect(x: (CGFloat(width) - screenWidth) / 2, y: 132, width: screenWidth, height: screenHeight)
    paper.withAlphaComponent(0.75).setFill()
    NSBezierPath(roundedRect: screenRect.insetBy(dx: -3, dy: -3), xRadius: 8, yRadius: 8).fill()
    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(roundedRect: screenRect, xRadius: 6, yRadius: 6).addClip()
    shot.draw(in: screenRect, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: false, hints: [.interpolation: NSImageInterpolation.high])
    NSGraphicsContext.restoreGraphicsState()
    text("\(index + 1) / \(cards.count)", x: 1130, top: 2790, size: 24, color: paper.withAlphaComponent(0.65), face: "HelveticaNeue-Medium", maxWidth: 160)
    NSGraphicsContext.restoreGraphicsState()
    guard let output = canvas.makeImage(), let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: outputFolder + "/" + card.0) as CFURL, UTType.png.identifier as CFString, 1, nil) else { fatalError("Cannot export") }
    CGImageDestinationAddImage(destination, output, nil)
    guard CGImageDestinationFinalize(destination) else { fatalError("Cannot save") }
}
