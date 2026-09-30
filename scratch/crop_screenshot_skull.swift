import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

// Silhouette in screenshot is x: 42..179, y: 25..450
// Let's crop x: 40..180, y: 20..200
let cropW = 140
let cropH = 180
let cropRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: cropW, pixelsHigh: cropH, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<cropH {
    for x in 0..<cropW {
        let color = rep.colorAt(x: 40 + x, y: 20 + y)!
        cropRep.setColor(color, atX: x, y: y)
    }
}

let pngData = cropRep.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "scratch/screenshot_upper_body_crop.png"))
print("Saved scratch/screenshot_upper_body_crop.png")
