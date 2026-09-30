import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

let silX: Double = 42.0
let silY: Double = 25.0
let silW: Double = 138.0
let silH: Double = 426.0

// Helper to check if a pixel is bone (white, cyan, or dark socket)
func isBonePixel(x: Int, y: Int) -> Bool {
    guard x >= 0 && x < rep.pixelsWide && y >= 0 && y < rep.pixelsHigh else { return false }
    let c = rep.colorAt(x: x, y: y)!
    let r = c.redComponent
    let g = c.greenComponent
    let b = c.blueComponent
    
    // Background is r ~ 0.30, g ~ 0.20, b ~ 0.68
    // Silhouette is r ~ 0.95, g ~ 0.55, b ~ 0.95
    // Bone white:
    if r > 0.80 && g > 0.80 && b > 0.80 { return true }
    // Bone cyan:
    if b > 0.40 && g > 0.32 && g > r + 0.05 { return true }
    // Dark eye socket/nasal cavity in head (x: 105..135, y: 40..75):
    if x >= 105 && x <= 135 && y >= 40 && y <= 75 && r < 0.25 && g < 0.25 && b < 0.35 { return true }
    return false
}

// Let's create an image showing all detected bone pixels in the screenshot
let debugRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: rep.pixelsWide, pixelsHigh: rep.pixelsHigh, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<rep.pixelsHigh {
    for x in 0..<rep.pixelsWide {
        if isBonePixel(x: x, y: y) {
            let orig = rep.colorAt(x: x, y: y)!
            debugRep.setColor(orig, atX: x, y: y)
        } else {
            debugRep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
        }
    }
}

let debugPng = debugRep.representation(using: .png, properties: [:])!
try! debugPng.write(to: URL(fileURLWithPath: "scratch/screenshot_bone_mask.png"))
print("Saved scratch/screenshot_bone_mask.png")

// Now let's print the bounding box of the whole skeleton in the screenshot:
var skelMinX = rep.pixelsWide, skelMaxX = 0, skelMinY = rep.pixelsHigh, skelMaxY = 0
for y in 0..<rep.pixelsHigh {
    for x in 0..<rep.pixelsWide {
        if isBonePixel(x: x, y: y) {
            skelMinX = min(skelMinX, x)
            skelMaxX = max(skelMaxX, x)
            skelMinY = min(skelMinY, y)
            skelMaxY = max(skelMaxY, y)
        }
    }
}

print(String(format: "Whole skeleton in screenshot: x: %d..%d (w:%d), y: %d..%d (h:%d)",
    skelMinX, skelMaxX, skelMaxX - skelMinX + 1, skelMinY, skelMaxY, skelMaxY - skelMinY + 1))

let relSkelX = (Double(skelMinX) - silX) / silW * 100.0
let relSkelY = (Double(skelMinY) - silY) / silH * 100.0
let relSkelW = Double(skelMaxX - skelMinX + 1) / silW * 100.0
let relSkelH = Double(skelMaxY - skelMinY + 1) / silH * 100.0

print(String(format: "Whole skeleton relative to silhouette: left: %.2f%%, top: %.2f%%, width: %.2f%%, height: %.2f%%",
    relSkelX, relSkelY, relSkelW, relSkelH))
