import AppKit

struct Color {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat

    func nsColor() -> NSColor {
        NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

let ink = Color(red: 0.059, green: 0.067, blue: 0.078, alpha: 1)
let panel = Color(red: 0.086, green: 0.094, blue: 0.110, alpha: 1)
let orange = Color(red: 0.969, green: 0.576, blue: 0.102, alpha: 1)
let amber = Color(red: 1.000, green: 0.752, blue: 0.443, alpha: 1)
let paper = Color(red: 0.957, green: 0.925, blue: 0.855, alpha: 1)

func writePng(_ image: NSImage, to path: String) {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let data = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Could not render PNG for \(path)")
    }

    let url = URL(fileURLWithPath: path)
    try! FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    try! data.write(to: url)
}

func drawCenteredText(_ text: String, rect: NSRect, size: CGFloat, color: NSColor) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: .black),
        .foregroundColor: color,
        .paragraphStyle: paragraph,
        .kern: -1.0
    ]
    let attributed = NSAttributedString(string: text, attributes: attributes)
    let textSize = attributed.size()
    let textRect = NSRect(
        x: rect.midX - textSize.width / 2,
        y: rect.midY - textSize.height / 2,
        width: textSize.width,
        height: textSize.height
    )
    attributed.draw(in: textRect)
}

func drawBookMark(in rect: NSRect, scale: CGFloat) {
    let pageRadius = 24 * scale
    let leftPage = NSBezierPath(roundedRect: NSRect(
        x: rect.minX,
        y: rect.minY,
        width: rect.width * 0.47,
        height: rect.height
    ), xRadius: pageRadius, yRadius: pageRadius)
    let rightPage = NSBezierPath(roundedRect: NSRect(
        x: rect.midX + rect.width * 0.03,
        y: rect.minY,
        width: rect.width * 0.47,
        height: rect.height
    ), xRadius: pageRadius, yRadius: pageRadius)

    paper.nsColor().setFill()
    leftPage.fill()
    rightPage.fill()

    ink.nsColor().withAlphaComponent(0.88).setStroke()
    leftPage.lineWidth = 4 * scale
    rightPage.lineWidth = 4 * scale
    leftPage.stroke()
    rightPage.stroke()

    let spine = NSBezierPath(roundedRect: NSRect(
        x: rect.midX - 7 * scale,
        y: rect.minY + 8 * scale,
        width: 14 * scale,
        height: rect.height - 16 * scale
    ), xRadius: 7 * scale, yRadius: 7 * scale)
    orange.nsColor().setFill()
    spine.fill()

    for line in 0..<3 {
        let y = rect.maxY - CGFloat(24 + line * 22) * scale
        let leftLine = NSBezierPath()
        leftLine.move(to: NSPoint(x: rect.minX + 28 * scale, y: y))
        leftLine.line(to: NSPoint(x: rect.midX - 24 * scale, y: y - 8 * scale))
        ink.nsColor().withAlphaComponent(0.42).setStroke()
        leftLine.lineWidth = 5 * scale
        leftLine.lineCapStyle = .round
        leftLine.stroke()

        let rightLine = NSBezierPath()
        rightLine.move(to: NSPoint(x: rect.midX + 24 * scale, y: y - 8 * scale))
        rightLine.line(to: NSPoint(x: rect.maxX - 28 * scale, y: y))
        rightLine.lineWidth = 5 * scale
        rightLine.lineCapStyle = .round
        rightLine.stroke()
    }
}

func iconImage(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    NSGradient(colors: [panel.nsColor(), ink.nsColor()])!.draw(in: rect, angle: 315)

    let glowRect = rect.insetBy(dx: size * 0.17, dy: size * 0.17)
    let glow = NSBezierPath(ovalIn: glowRect)
    orange.nsColor().withAlphaComponent(0.20).setFill()
    glow.fill()

    let coinRect = rect.insetBy(dx: size * 0.21, dy: size * 0.21)
    let coin = NSBezierPath(ovalIn: coinRect)
    orange.nsColor().setFill()
    coin.fill()
    amber.nsColor().withAlphaComponent(0.45).setStroke()
    coin.lineWidth = max(2, size * 0.018)
    coin.stroke()

    drawBookMark(in: rect.insetBy(dx: size * 0.27, dy: size * 0.32), scale: size / 1024)
    drawCenteredText("S", rect: rect.offsetBy(dx: 0, dy: -size * 0.02), size: size * 0.23, color: ink.nsColor())

    image.unlockFocus()
    return image
}

func launchImage(size: NSSize) -> NSImage {
    let image = NSImage(size: size)
    image.lockFocus()

    NSColor.clear.setFill()
    NSRect(origin: .zero, size: size).fill()
    let markSize = min(size.width, size.height) * 0.68
    let markRect = NSRect(
        x: (size.width - markSize) / 2,
        y: size.height * 0.33,
        width: markSize,
        height: markSize
    )
    orange.nsColor().setFill()
    NSBezierPath(ovalIn: markRect).fill()
    drawBookMark(in: markRect.insetBy(dx: markSize * 0.18, dy: markSize * 0.27), scale: markSize / 512)

    drawCenteredText(
        "SatoWiki",
        rect: NSRect(x: 0, y: size.height * 0.09, width: size.width, height: size.height * 0.18),
        size: size.width * 0.115,
        color: paper.nsColor()
    )

    image.unlockFocus()
    return image
}

let iosIconRoot = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
let iosIconSizes: [(String, CGFloat)] = [
    ("Icon-App-20x20@1x.png", 20),
    ("Icon-App-20x20@2x.png", 40),
    ("Icon-App-20x20@3x.png", 60),
    ("Icon-App-29x29@1x.png", 29),
    ("Icon-App-29x29@2x.png", 58),
    ("Icon-App-29x29@3x.png", 87),
    ("Icon-App-40x40@1x.png", 40),
    ("Icon-App-40x40@2x.png", 80),
    ("Icon-App-40x40@3x.png", 120),
    ("Icon-App-60x60@2x.png", 120),
    ("Icon-App-60x60@3x.png", 180),
    ("Icon-App-76x76@1x.png", 76),
    ("Icon-App-76x76@2x.png", 152),
    ("Icon-App-83.5x83.5@2x.png", 167),
    ("Icon-App-1024x1024@1x.png", 1024)
]
for (name, size) in iosIconSizes {
    writePng(iconImage(size: size), to: "\(iosIconRoot)/\(name)")
}

let androidIconSizes: [(String, CGFloat)] = [
    ("mipmap-mdpi", 48),
    ("mipmap-hdpi", 72),
    ("mipmap-xhdpi", 96),
    ("mipmap-xxhdpi", 144),
    ("mipmap-xxxhdpi", 192)
]
for (folder, size) in androidIconSizes {
    writePng(iconImage(size: size), to: "android/app/src/main/res/\(folder)/ic_launcher.png")
    writePng(launchImage(size: NSSize(width: size * 2, height: size * 2)), to: "android/app/src/main/res/\(folder)/launch_image.png")
}

let launchRoot = "ios/Runner/Assets.xcassets/LaunchImage.imageset"
writePng(launchImage(size: NSSize(width: 168, height: 185)), to: "\(launchRoot)/LaunchImage.png")
writePng(launchImage(size: NSSize(width: 336, height: 370)), to: "\(launchRoot)/LaunchImage@2x.png")
writePng(launchImage(size: NSSize(width: 504, height: 555)), to: "\(launchRoot)/LaunchImage@3x.png")
