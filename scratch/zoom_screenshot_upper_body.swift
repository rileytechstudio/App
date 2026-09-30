import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

// Upper body in screenshot is x: 42..179, y: 25..250
let cropX = 42
let cropY = 25
let cropW = 138
let cropH = 225
let zoom = 2
let outW = cropW * zoom
let outH = cropH * zoom

let outRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: outW, pixelsHigh: outH, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<cropH {
    for x in 0..<cropW {
        let color = rep.colorAt(x: cropX + x, y: cropY + y)!
        for dy in 0..<zoom {
            for dx in 0..<zoom {
                outRep.setColor(color, atX: x * zoom + dx, y: y * zoom + dy)
            }
        }
    }
}

let pngData = outRep.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "scratch/zoomed_screenshot_upper_body.png"))
print("Saved scratch/zoomed_screenshot_upper_body.png")
