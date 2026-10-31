// Deterministic platform renditions of the generated master, plus preview sizes.
import AppKit
import ImageIO
import UniformTypeIdentifiers

func export(_ source: CGImage, size: Int, to path: String) throws {
    guard let canvas = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8,
        bytesPerRow: size * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
    else { throw NSError(domain: "Icon", code: 1) }
    canvas.interpolationQuality = .high
    canvas.draw(source, in: CGRect(x: 0, y: 0, width: size, height: size))
    guard let outputImage = canvas.makeImage(),
        let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.png.identifier as CFString, 1, nil)
    else { throw NSError(domain: "Icon", code: 2) }
    CGImageDestinationAddImage(destination, outputImage, nil)
    guard CGImageDestinationFinalize(destination) else { throw NSError(domain: "Icon", code: 3) }
}
let path = "AppStore/Icons/CharacterIcon-Master.png"
guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil),
    let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else { fatalError("Missing generated master") }
for size in [1024, 180, 120, 60, 40] {
    try export(image, size: size, to: "AppStore/Icons/AppIcon-\(size).png")
}
try export(image, size: 1024, to: "Sources/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
try export(image, size: 180, to: "Sources/Assets.xcassets/ClubBadge.imageset/ClubBadge.png")
