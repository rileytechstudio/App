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

func cropRegion(minX: Int, maxX: Int, minY: Int, maxY: Int, predicate: ((Int, Int) -> Bool)? = nil) -> NSImage {
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
    return NSImage(data: data)!
}

// Extract skull
let skullImg = cropRegion(minX: 700, maxX: 863, minY: 372, maxY: 536) { x, y in
    if x < 745 && y > 515 { return false }
    return true
}

// Extract body (without skull, including cervical spine from y=535 down to feet y=1633)
let bodyImg = cropRegion(minX: 596, maxX: 1010, minY: 535, maxY: 1633)

let canvas = NSImage(size: NSSize(width: charW, height: charH))
canvas.lockFocus()

imgSolo.draw(in: NSRect(x: 0, y: 0, width: charW, height: charH))

// Draw body
// In source: minY = 535, maxY = 1633. Clavicles are at y=625.
// In character: clavicles at y = 148.7, feet at y = 676.0.
// bodyScaleY = (676.0 - 148.7) / (1633.0 - 625.0) = 527.3 / 1008.0 = 0.523115
// y for source y=535: 148.7 + (535.0 - 625.0) * bodyScaleY = 148.7 - 90 * 0.523115 = 101.6 px!
// Total body drawn height: (1633 - 535) * bodyScaleY = 1098 * 0.523115 = 574.4 px!
// Body width: 415 * (197.35 / 415) = 197.35 px!
// Body X: 4.85 px!
let bDestX = 4.85
let bDestY = 101.6
let bDestW = 197.35
let bDestH = 574.4

let cocoaBodyY = charH - bDestY - bDestH
bodyImg.draw(in: NSRect(x: bDestX, y: cocoaBodyY, width: bDestW, height: bDestH),
             from: NSRect.zero,
             operation: .sourceOver,
             fraction: 1.0)

// Draw skull
// Let's test skull at:
// top = 32.0, left = 64.0, w = 80.0, h = 80.0
let sDestX = 64.0
let sDestY = 32.0
let sDestW = 80.0
let sDestH = 80.0

let cocoaSkullY = charH - sDestY - sDestH
skullImg.draw(in: NSRect(x: sDestX, y: cocoaSkullY, width: sDestW, height: sDestH),
              from: NSRect.zero,
              operation: .sourceOver,
              fraction: 1.0)

canvas.unlockFocus()

let outRep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
let outPng = outRep.representation(using: .png, properties: [:])!
try! outPng.write(to: URL(fileURLWithPath: "scratch/fitted_overlay_test.png"))
print("Saved scratch/fitted_overlay_test.png")

// Compare side by side with screenshot
let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let imgShot = NSImage(contentsOf: urlShot)!
let repShot = NSBitmapImageRep(data: imgShot.tiffRepresentation!)!

let sideCanvas = NSImage(size: NSSize(width: 480, height: 681))
sideCanvas.lockFocus()

NSColor(calibratedWhite: 0.15, alpha: 1.0).setFill()
NSRect(x: 0, y: 0, width: 480, height: 681).fill()

let scale = 681.0 / 426.0
let shotDrawX = 20.0 - 43.0 * scale
let shotDrawY = 0.0 - (Double(repShot.pixelsHigh) * scale - 450.0 * scale)
imgShot.draw(in: NSRect(x: shotDrawX, y: shotDrawY, width: Double(repShot.pixelsWide) * scale, height: Double(repShot.pixelsHigh) * scale),
             from: NSRect.zero,
             operation: .sourceOver,
             fraction: 1.0)

canvas.draw(in: NSRect(x: 240, y: 0, width: charW, height: charH),
            from: NSRect.zero,
            operation: .sourceOver,
            fraction: 1.0)

sideCanvas.unlockFocus()

let sideRep = NSBitmapImageRep(data: sideCanvas.tiffRepresentation!)!
let sidePng = sideRep.representation(using: .png, properties: [:])!
try! sidePng.write(to: URL(fileURLWithPath: "scratch/side_by_side_fitted.png"))
print("Saved scratch/side_by_side_fitted.png")
