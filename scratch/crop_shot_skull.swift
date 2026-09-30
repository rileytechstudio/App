import AppKit

let shotUrl = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let shotRep = NSBitmapImageRep(data: NSImage(contentsOf: shotUrl)!.tiffRepresentation!)!

// Crop x: 75..140, y: 25..110 from screenshot
let cropRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 65, pixelsHigh: 85, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<85 {
    for x in 0..<65 {
        let sx = 75 + x
        let sy = 25 + y
        let c = shotRep.colorAt(x: sx, y: sy)!
        cropRep.setColor(c, atX: x, y: y)
    }
}

let outPng = cropRep.representation(using: .png, properties: [:])!
try! outPng.write(to: URL(fileURLWithPath: "scratch/cropped_shot_skull.png"))
print("Saved scratch/cropped_shot_skull.png")
