import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let imgSolo = NSImage(contentsOf: urlSolo)!
let repSolo = NSBitmapImageRep(data: imgSolo.tiffRepresentation!)!
let charW = Double(repSolo.pixelsWide) // 220
let charH = Double(repSolo.pixelsHigh) // 681

func getCleanPixel(x: Int, y: Int) -> NSColor? {
    guard x >= 0 && x < repSkel.pixelsWide && y >= 0 && y < repSkel.pixelsHigh else { return nil }
    let c = repSkel.colorAt(x: x, y: y)!
    let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
    if r > 0.78 && g > 0.78 && b > 0.78 { return c }
    if b > 0.38 && g > 0.32 && g > r + 0.03 { return c }
    if x >= 810 && x <= 865 && y >= 440 && y <= 515 && r < 0.25 && g < 0.25 && b < 0.35 { return c }
    return nil
}

func cropRegion(minX: Int, maxX: Int, minY: Int, maxY: Int, predicate: ((Int, Int) -> Bool)? = nil) -> (NSImage, Int, Int, Int, Int) {
    var bMinX = maxX, bMaxX = minX, bMinY = maxY, bMaxY = minY
    for y in minY...maxY {
        for x in minX...maxX {
            if let p = predicate, !p(x, y) { continue }
            if getCleanPixel(x: x, y: y) != nil {
                bMinX = min(bMinX, x)
                bMaxX = max(bMaxX, x)
                bMinY = min(bMinY, y)
                bMaxY = max(bMaxY, y)
            }
        }
    }
    let pw = max(1, bMaxX - bMinX + 1)
    let ph = max(1, bMaxY - bMinY + 1)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pw, pixelsHigh: ph, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    
    for y in 0..<ph {
        for x in 0..<pw {
            let sx = bMinX + x
            let sy = bMinY + y
            if let p = predicate, !p(sx, sy) {
                rep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
                continue
            }
            if let color = getCleanPixel(x: sx, y: sy) {
                rep.setColor(color, atX: x, y: y)
            } else {
                rep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
            }
        }
    }
    let data = rep.representation(using: .png, properties: [:])!
    return (NSImage(data: data)!, bMinX, bMinY, pw, ph)
}

// Extract skull
let (skullImg, skMinX, skMinY, skW, skH) = cropRegion(minX: 700, maxX: 863, minY: 372, maxY: 536) { x, y in
    if x < 745 && y > 515 { return false }
    return true
}

// Extract rest of skeleton (neck to feet: minY: 535, maxY: 1633, minX: 596, maxX: 1010)
let (bodyImg, bdMinX, bdMinY, bdW, bdH) = cropRegion(minX: 596, maxX: 1010, minY: 535, maxY: 1633)

// Skeleton placement on Character_OlderBoy_Solo.png:
let skelMinX = 4.85
let skelMinY = 12.79
let skelW = 192.5
let skelH = 661.8

let srcSkelMinX = 596.0
let srcSkelMinY = 371.0
let srcSkelW = 414.0
let srcSkelH = 1262.0

// Body coords:
let bCharLeft = skelMinX + Double(bdMinX - Int(srcSkelMinX)) / srcSkelW * skelW
let bCharTop = skelMinY + Double(bdMinY - Int(srcSkelMinY)) / srcSkelH * skelH
let bCharWidth = Double(bdW) / srcSkelW * skelW
let bCharHeight = Double(bdH) / srcSkelH * skelH

// Base skull coords (before shift):
let sCharLeftBase = skelMinX + Double(skMinX - Int(srcSkelMinX)) / srcSkelW * skelW
let sCharTopBase = skelMinY + Double(skMinY - Int(srcSkelMinY)) / srcSkelH * skelH
let sCharWidth = Double(skW) / srcSkelW * skelW
let sCharHeight = Double(skH) / srcSkelH * skelH

// Test 3 skull shifts: dx = 8, 10, 12, and dy = 0, 2
for (dx, dy) in [(8.0, 0.0), (10.0, 0.0), (12.0, 0.0), (10.0, 2.0)] {
    let canvas = NSImage(size: NSSize(width: charW, height: charH))
    canvas.lockFocus()
    imgSolo.draw(in: NSRect(x: 0, y: 0, width: charW, height: charH))
    
    // Draw body
    let cocoaBY = charH - bCharTop - bCharHeight
    bodyImg.draw(in: NSRect(x: bCharLeft, y: cocoaBY, width: bCharWidth, height: bCharHeight),
                 from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
    
    // Draw skull shifted
    let sCharLeft = sCharLeftBase + dx
    let sCharTop = sCharTopBase + dy
    let cocoaSY = charH - sCharTop - sCharHeight
    skullImg.draw(in: NSRect(x: sCharLeft, y: cocoaSY, width: sCharWidth, height: sCharHeight),
                  from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
    
    canvas.unlockFocus()
    
    let outRep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
    let outPng = outRep.representation(using: .png, properties: [:])!
    try! outPng.write(to: URL(fileURLWithPath: "scratch/test_shift_dx\(Int(dx))_dy\(Int(dy)).png"))
}
print("Generated shift variations")
