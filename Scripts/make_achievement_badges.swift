// Original vector badge system; no third-party logos or raster manipulation.
import AppKit
import ImageIO
import UniformTypeIdentifiers

let out = URL(fileURLWithPath: "AppStore/GameCenter")
try FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
let paper = NSColor(srgbRed: 0.97, green: 0.98, blue: 1.00, alpha: 1)
let navy = NSColor(srgbRed: 0.035, green: 0.075, blue: 0.16, alpha: 1)
let red = NSColor(srgbRed: 0.79, green: 0.09, blue: 0.17, alpha: 1)
func centered(_ value: String, y: CGFloat, size: CGFloat, face: String, color: NSColor) {
    let attributes: [NSAttributedString.Key: Any] = [.font: NSFont(name: face, size: size) ?? NSFont.boldSystemFont(ofSize: size), .foregroundColor: color]
    let dimensions = (value as NSString).size(withAttributes: attributes)
    (value as NSString).draw(at: NSPoint(x: (1024 - dimensions.width) / 2, y: y), withAttributes: attributes)
}
for threshold in [10, 23, 33, 50, 81, 100] {
    guard let canvas = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8, bytesPerRow: 4096, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { fatalError("Canvas") }
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: canvas, flipped: false)
    navy.setFill(); NSBezierPath(rect: NSRect(x: 0, y: 0, width: 1024, height: 1024)).fill()
    paper.setStroke()
    let ring = NSBezierPath(ovalIn: NSRect(x: 78, y: 78, width: 868, height: 868)); ring.lineWidth = 8; ring.stroke()
    red.setStroke()
    let inset = NSBezierPath(ovalIn: NSRect(x: 100, y: 100, width: 824, height: 824)); inset.lineWidth = 2; inset.stroke()
    centered("SHADOW CLUB", y: 734, size: 40, face: "HelveticaNeue-Medium", color: paper)
    centered(String(threshold), y: 327, size: 340, face: "HelveticaNeue-Bold", color: paper)
    // Bilateral curled moustache, drawn as cubic paths.
    red.setFill()
    for side: CGFloat in [-1, 1] {
        func point(_ x: CGFloat, _ y: CGFloat) -> NSPoint { NSPoint(x: 512 + side * x, y: y) }
        let curl = NSBezierPath(); curl.move(to: point(0, 265))
        curl.curve(to: point(115, 245), controlPoint1: point(40, 315), controlPoint2: point(70, 240))
        curl.curve(to: point(175, 280), controlPoint1: point(145, 238), controlPoint2: point(162, 255))
        curl.curve(to: point(75, 198), controlPoint1: point(165, 205), controlPoint2: point(115, 175))
        curl.curve(to: point(0, 265), controlPoint1: point(35, 200), controlPoint2: point(10, 225))
        curl.close(); curl.fill()
    }
    centered("VERY OFFICIAL", y: 143, size: 23, face: "HelveticaNeue-Medium", color: paper)
    NSGraphicsContext.restoreGraphicsState()
    guard let result = canvas.makeImage(), let destination = CGImageDestinationCreateWithURL(out.appendingPathComponent("award-\(threshold).png") as CFURL, UTType.png.identifier as CFString, 1, nil) else { fatalError("Export") }
    CGImageDestinationAddImage(destination, result, [kCGImagePropertyDPIWidth: 72, kCGImagePropertyDPIHeight: 72] as CFDictionary)
    guard CGImageDestinationFinalize(destination) else { fatalError("Save") }
}
