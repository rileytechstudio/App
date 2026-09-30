import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

// Skull is x: 75..140, y: 30..85
let cropW = 65
let cropH = 55
let zoom = 4
let outW = cropW * zoom
let outH = cropH * zoom

let outRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: outW, pixelsHigh: outH, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<cropH {
    for x in 0..<cropW {
        let color = rep.colorAt(x: 75 + x, y: 30 + y)!
        for dy in 0..<zoom {
            for dx in 0..<zoom {
                outRep.setColor(color, atX: x * zoom + dx, y: y * zoom + dy)
            }
        }
    }
}

let pngData = outRep.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "scratch/zoomed_screenshot_skull.png"))
print("Saved scratch/zoomed_screenshot_skull.png")

