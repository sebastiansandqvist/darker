import AppKit

// Use the same native SF Symbols as the app, including at menu-bar size.
let output = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let fileManager = FileManager.default
let iconset = output.appendingPathComponent("Darker.iconset", isDirectory: true)
try fileManager.createDirectory(at: iconset, withIntermediateDirectories: true)

func bitmap(width: Int, height: Int, draw: (NSRect) -> Void) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    draw(NSRect(x: 0, y: 0, width: width, height: height))
    NSGraphicsContext.restoreGraphicsState()
    return rep
}

func save(_ rep: NSBitmapImageRep, to url: URL) throws {
    try rep.representation(using: .png, properties: [:])!.write(to: url)
}

func symbol(_ name: String, in rect: NSRect, color: NSColor = .white) {
    guard let image = NSImage(systemSymbolName: name, accessibilityDescription: nil)?
        .withSymbolConfiguration(.init(pointSize: rect.height, weight: .regular)) else {
        fatalError("Missing SF Symbol: \(name)")
    }
    let scale = min(rect.width / image.size.width, rect.height / image.size.height)
    let size = NSSize(width: image.size.width * scale, height: image.size.height * scale)
    let destination = NSRect(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2,
                             width: size.width, height: size.height)
    let tinted = NSImage(size: image.size, flipped: false) { bounds in
        image.draw(in: bounds)
        color.setFill()
        bounds.fill(using: .sourceIn)
        return true
    }
    tinted.draw(in: destination)
}

func text(_ string: String, at point: NSPoint, size: CGFloat,
          weight: NSFont.Weight = .regular, color: NSColor = .white) {
    (string as NSString).draw(at: point, withAttributes: [
        .font: NSFont.systemFont(ofSize: size, weight: weight), .foregroundColor: color
    ])
}

for size in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = size * scale
        let rep = bitmap(width: pixels, height: pixels) { bounds in
            let side = bounds.width
            let badge = bounds.insetBy(dx: side * 0.07, dy: side * 0.07)
            let path = NSBezierPath(roundedRect: badge, xRadius: side * 0.2, yRadius: side * 0.2)
            NSGradient(starting: NSColor(srgbRed: 0.28, green: 0.30, blue: 0.46, alpha: 1),
                       ending: NSColor(srgbRed: 0.10, green: 0.12, blue: 0.22, alpha: 1))!
                .draw(in: path, angle: 90)
            // Original geometric crescent for the application icon.
            let center = NSPoint(x: side * 0.5, y: side * 0.5)
            let inner = NSPoint(x: side * 0.635, y: side * 0.615)
            let radius = side * 0.23, innerRadius = side * 0.215
            let dx = inner.x - center.x, dy = inner.y - center.y
            let distance = hypot(dx, dy)
            let along = (radius * radius - innerRadius * innerRadius + distance * distance) / (2 * distance)
            let across = sqrt(radius * radius - along * along)
            let middle = NSPoint(x: center.x + along * dx / distance, y: center.y + along * dy / distance)
            let top = NSPoint(x: middle.x - across * dy / distance, y: middle.y + across * dx / distance)
            let bottom = NSPoint(x: middle.x + across * dy / distance, y: middle.y - across * dx / distance)
            func angle(_ point: NSPoint, from origin: NSPoint) -> CGFloat {
                atan2(point.y - origin.y, point.x - origin.x) * 180 / .pi
            }
            let moon = NSBezierPath()
            moon.appendArc(withCenter: center, radius: radius, startAngle: angle(top, from: center),
                           endAngle: angle(bottom, from: center), clockwise: false)
            moon.appendArc(withCenter: inner, radius: innerRadius, startAngle: angle(bottom, from: inner),
                           endAngle: angle(top, from: inner), clockwise: true)
            moon.close()
            NSColor(srgbRed: 0.94, green: 0.92, blue: 0.83, alpha: 1).setFill()
            moon.fill()
        }
        let suffix = scale == 2 ? "@2x" : ""
        try save(rep, to: iconset.appendingPathComponent("icon_\(size)x\(size)\(suffix).png"))
    }
}

let sheet = bitmap(width: 500, height: 180) { bounds in
    NSColor(srgbRed: 0.075, green: 0.085, blue: 0.11, alpha: 1).setFill()
    bounds.fill()
    for (index, name) in ["moon.zzz", "moon.zzz.fill"].enumerated() {
        let x = CGFloat(125 + index * 250)
        symbol(name, in: NSRect(x: x - 30, y: 83, width: 60, height: 60))
        let label = index == 0 ? "Off" : "Dimming"
        let width = (label as NSString).size(withAttributes: [.font: NSFont.systemFont(ofSize: 16)]).width
        text(label, at: NSPoint(x: x - width / 2, y: 35), size: 16)
    }
}
try save(sheet, to: output.appendingPathComponent("icon-states.png"))
