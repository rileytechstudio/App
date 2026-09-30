import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let repShot = NSBitmapImageRep(data: NSImage(contentsOf: urlShot)!.tiffRepresentation!)!

// In repSkel, skeleton bbox is x: 596..1010, y: 371..1633. (w: 415, h: 1263)
// First, create a clean transparent image of the skeleton from Older Boy Skeleton.png
let skelW = 415
let skelH = 1263
let cleanSkel = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: skelW, pixelsHigh: skelH, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<skelH {
    for x in 0..<skelW {
        let sx = 596 + x
        let sy = 371 + y
        let c = repSkel.colorAt(x: sx, y: sy)!
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        // Keep bone (white), dark eye/nasal cavity, and blue shading:
        let isWhite = (r > 0.78 && g > 0.78 && b > 0.78)
        let isShading = (b > 0.38 && g > 0.32 && g > r + 0.03)
        let isCavity = (sx >= 810 && sx <= 865 && sy >= 440 && sy <= 515 && r < 0.25 && g < 0.25 && b < 0.35)
        
        if isWhite || isShading || isCavity {
            cleanSkel.setColor(c, atX: x, y: y)
        } else {
            cleanSkel.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
        }
    }
}

// Now, let's scale cleanSkel to repShot skeleton bbox:
// In repShot:
// Skull top is at y = 33
// Feet bottom is at y = 447 (h = 415)
// Let's test drawing cleanSkel into repShot at x: 46, y: 33, w: 122, h: 415
let canvas = NSImage(size: NSSize(width: repShot.pixelsWide, height: repShot.pixelsHigh))
canvas.lockFocus()

// Draw screenshot
let shotImg = NSImage(contentsOf: urlShot)!
shotImg.draw(in: NSRect(x: 0, y: 0, width: repShot.pixelsWide, height: repShot.pixelsHigh))

// Overlay cleanSkel in red with 50% alpha so we can see the difference!
let skelImg = NSImage(data: cleanSkel.representation(using: .png, properties: [:])!)!

// Cocoa coordinates: y is inverted
let destX: Double = 46.0
let destYFromTop: Double = 33.0
let destW: Double = 122.0
let destH: Double = 415.0
let cocoaY = Double(repShot.pixelsHigh) - destYFromTop - destH

skelImg.draw(in: NSRect(x: destX, y: cocoaY, width: destW, height: destH),
            from: NSRect.zero,
            operation: .sourceOver,
            fraction: 0.5)

canvas.unlockFocus()

let outRep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
let outPng = outRep.representation(using: .png, properties: [:])!
try! outPng.write(to: URL(fileURLWithPath: "scratch/overlay_test.png"))
print("Saved scratch/overlay_test.png")
