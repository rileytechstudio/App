import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

func getCleanPixel(x: Int, y: Int) -> NSColor? {
    guard x >= 0 && x < repSkel.pixelsWide && y >= 0 && y < repSkel.pixelsHigh else { return nil }
    let c = repSkel.colorAt(x: x, y: y)!
    let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
    if r > 0.78 && g > 0.78 && b > 0.78 { return c }
    if b > 0.38 && g > 0.32 && g > r + 0.03 { return c }
    return nil
}

// Extract pelvis: minX: 655, maxX: 875, minY: 935, maxY: 1080
let pw = 875 - 655 + 1
let ph = 1080 - 935 + 1
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pw, pixelsHigh: ph, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<ph {
    for x in 0..<pw {
        let sx = 655 + x
        let sy = 935 + y
        if let color = getCleanPixel(x: sx, y: sy) {
            rep.setColor(color, atX: x, y: y)
        } else {
            rep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
        }
    }
}
let data = rep.representation(using: .png, properties: [:])!
try! data.write(to: URL(fileURLWithPath: "scratch/pelvis_extracted.png"))
print("Saved scratch/pelvis_extracted.png")
