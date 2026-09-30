import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

func getCleanPixel(x: Int, y: Int) -> NSColor? {
    guard x >= 0 && x < repSkel.pixelsWide && y >= 0 && y < repSkel.pixelsHigh else { return nil }
    let c = repSkel.colorAt(x: x, y: y)!
    let r = c.redComponent
    let g = c.greenComponent
    let b = c.blueComponent
    
    // White bone:
    if r > 0.78 && g > 0.78 && b > 0.78 { return c }
    // Cyan bone:
    if b > 0.38 && g > 0.32 && g > r + 0.03 { return c }
    // Eye socket / nasal cavity in head (x: 810..865, y: 440..515):
    if x >= 810 && x <= 865 && y >= 440 && y <= 515 && r < 0.25 && g < 0.25 && b < 0.35 { return c }
    return nil
}

// Whole skeleton in Older Boy Skeleton.png is x: 596..967 (w:372), y: 372..1633 (h:1262)
// Skull is x: 700..863, y: 372..536
// Rest of body is from y: 536 to 1633

// Let's create an assembled image where the skull is shifted:
// Try dx: -20, dy: +26
for dy in [20, 24, 28, 32] {
    for dx in [-24, -20, -16] {
        let W = 390
        let H = 1270
        let outRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        
        // Clear to transparent
        for y in 0..<H {
            for x in 0..<W {
                outRep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
            }
        }
        
        // 1. Draw body (y from 525 to 1633, x from 596 to 967)
        for y in 525...1633 {
            for x in 596...967 {
                if let c = getCleanPixel(x: x, y: y) {
                    let outX = (x - 596) + 15
                    let outY = (y - 372)
                    if outX >= 0 && outX < W && outY >= 0 && outY < H {
                        outRep.setColor(c, atX: outX, y: outY)
                    }
                }
            }
        }
        
        // 2. Draw skull (shifted by dx, dy)
        for y in 372...536 {
            for x in 700...863 {
                // exclude bottom-left spine fragment of skull crop
                if x < 745 && y > 515 { continue }
                if let c = getCleanPixel(x: x, y: y) {
                    let outX = (x - 596) + 15 + dx
                    let outY = (y - 372) + dy
                    if outX >= 0 && outX < W && outY >= 0 && outY < H {
                        outRep.setColor(c, atX: outX, y: outY)
                    }
                }
            }
        }
        
        let outPng = outRep.representation(using: .png, properties: [:])!
        try! outPng.write(to: URL(fileURLWithPath: "scratch/test_shift_dx\(dx)_dy\(dy).png"))
    }
}
print("Saved shift tests")
