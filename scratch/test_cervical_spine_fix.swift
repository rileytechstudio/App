import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!
let charW = 220.0
let charH = 681.0

func cropRegion(minX: Int, maxX: Int, minY: Int, maxY: Int, predicate: ((Int, Int) -> Bool)? = nil) -> (NSBitmapImageRep, Int, Int, Int, Int) {
    var bMinX = maxX, bMaxX = minX, bMinY = maxY, bMaxY = minY
    for y in minY...maxY {
        for x in minX...maxX {
            if let p = predicate, !p(x, y) { continue }
            let c = repSkel.colorAt(x: x, y: y)!
            if c.alphaComponent > 0.05 {
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
            let c = repSkel.colorAt(x: sx, y: sy)!
            if c.alphaComponent > 0.05 {
                rep.setColor(c, atX: x, y: y)
            } else {
                rep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
            }
        }
    }
    return (rep, bMinX, bMinY, pw, ph)
}

// 1. Skull:
let (skullRep, skX, skY, skW, skH) = cropRegion(minX: 45, maxX: 155, minY: 10, maxY: 106) { x, y in
    // Only exclude spine:
    if x < 88 && y > 94 { return false }
    return true
}

// 2. Spine: from under skull (y=95) through thorax and lumbar to pelvis (y=400)
let (spineRep, spX, spY, spW, spH) = cropRegion(minX: 70, maxX: 115, minY: 95, maxY: 400) { x, y in
    if y <= 160 { return x >= 70 && x <= 95 }
    return x >= 75 && x <= 112
}

print("Skull: \(skW)x\(skH) at (\(skX), \(skY))")
print("Spine: \(spW)x\(spH) at (\(spX), \(spY))")

let canvas = NSImage(size: NSSize(width: charW, height: charH))
canvas.lockFocus()

let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let imgSolo = NSImage(contentsOf: urlSolo)!
imgSolo.draw(in: NSRect(x: 0, y: 0, width: charW, height: charH))

// Draw spine (zIndex: 1)
let cocoaSpY = charH - Double(spY) - Double(spH)
let spineImg = NSImage(data: spineRep.representation(using: .png, properties: [:])!)!
spineImg.draw(in: NSRect(x: Double(spX), y: cocoaSpY, width: Double(spW), height: Double(spH)),
              from: NSRect.zero, operation: .sourceOver, fraction: 1.0)

// Draw skull (zIndex: 10)
let cocoaSkY = charH - Double(skY) - Double(skH)
let skullImg = NSImage(data: skullRep.representation(using: .png, properties: [:])!)!
skullImg.draw(in: NSRect(x: Double(skX), y: cocoaSkY, width: Double(skW), height: Double(skH)),
              from: NSRect.zero, operation: .sourceOver, fraction: 1.0)

canvas.unlockFocus()

let outRep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
try! outRep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/test_neck_fixed.png"))
print("Saved scratch/test_neck_fixed.png")
