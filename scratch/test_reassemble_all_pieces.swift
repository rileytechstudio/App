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

// Extract slices:
let skullImg = cropRegion(minX: 700, maxX: 863, minY: 372, maxY: 536) { x, y in
    if x < 745 && y > 515 { return false }
    return true
}
let spineImg = cropRegion(minX: 720, maxX: 785, minY: 535, maxY: 945) { x, y in
    if y <= 640 { return x >= 720 && x <= 775 }
    return x >= 735 && x <= 785
}
let ribcageImg = cropRegion(minX: 635, maxX: 870, minY: 625, maxY: 865) { x, y in
    if x < 650 && y >= 670 { return false }
    return true
}
let pelvisImg = cropRegion(minX: 655, maxX: 875, minY: 935, maxY: 1080)

let humerusLImg = cropRegion(minX: 596, maxX: 675, minY: 645, maxY: 810) { x, y in
    if y < 655 && x > 645 { return false }
    return true
}
let radiusUlnaLImg = cropRegion(minX: 596, maxX: 690, minY: 800, maxY: 970)
let handsLImg = cropRegion(minX: 655, maxX: 720, minY: 965, maxY: 1075)

let humerusRImg = cropRegion(minX: 845, maxX: 885, minY: 725, maxY: 840)
let radiusUlnaRImg = cropRegion(minX: 845, maxX: 915, minY: 830, maxY: 965)
let handsRImg = cropRegion(minX: 885, maxX: 935, minY: 965, maxY: 1065)

let femurLImg = cropRegion(minX: 655, maxX: 755, minY: 1040, maxY: 1315)
let fibulaTibiaLImg = cropRegion(minX: 650, maxX: 735, minY: 1300, maxY: 1565)
let feetLImg = cropRegion(minX: 645, maxX: 780, minY: 1545, maxY: 1633)

let femurRImg = cropRegion(minX: 785, maxX: 885, minY: 1040, maxY: 1315)
let fibulaTibiaRImg = cropRegion(minX: 820, maxX: 885, minY: 1300, maxY: 1565)
let feetRImg = cropRegion(minX: 820, maxX: 967, minY: 1540, maxY: 1610)

struct BoneItem {
    let img: NSImage
    let cx: Double
    let cy: Double
    let w: Double
    let h: Double
    let zIndex: Int
}

// Coordinates calibrated directly from Screenshot 2026-09-29 at 9.22.14 AM.png:
let pieces: [BoneItem] = [
    // zIndex: 1
    BoneItem(img: spineImg, cx: 43.0, cy: 30.5, w: 16.0, h: 32.3, zIndex: 1),
    // zIndex: 2
    BoneItem(img: pelvisImg, cx: 48.5, cy: 47.5, w: 52.0, h: 11.1, zIndex: 2),
    BoneItem(img: humerusRImg, cx: 71.0, cy: 30.8, w: 11.5, h: 10.5, zIndex: 2),
    BoneItem(img: radiusUlnaRImg, cx: 74.5, cy: 41.2, w: 17.3, h: 11.5, zIndex: 2),
    BoneItem(img: femurRImg, cx: 66.0, cy: 63.3, w: 26.6, h: 23.5, zIndex: 2),
    // zIndex: 3
    BoneItem(img: ribcageImg, cx: 44.0, cy: 28.0, w: 51.0, h: 17.2, zIndex: 3),
    // zIndex: 4
    BoneItem(img: humerusLImg, cx: 16.0, cy: 28.5, w: 17.2, h: 14.0, zIndex: 4),
    BoneItem(img: femurLImg, cx: 34.0, cy: 63.3, w: 26.6, h: 23.5, zIndex: 4),
    // zIndex: 5
    BoneItem(img: radiusUlnaLImg, cx: 15.5, cy: 41.2, w: 21.5, h: 12.5, zIndex: 5),
    // zIndex: 6
    BoneItem(img: handsLImg, cx: 30.0, cy: 51.2, w: 15.6, h: 8.5, zIndex: 6),
    BoneItem(img: handsRImg, cx: 82.0, cy: 51.2, w: 13.0, h: 8.5, zIndex: 6),
    BoneItem(img: fibulaTibiaRImg, cx: 68.0, cy: 83.8, w: 14.0, h: 18.5, zIndex: 6),
    // zIndex: 7
    BoneItem(img: fibulaTibiaLImg, cx: 30.0, cy: 83.8, w: 18.5, h: 18.5, zIndex: 7),
    BoneItem(img: feetRImg, cx: 75.5, cy: 94.5, w: 38.8, h: 6.0, zIndex: 7),
    // zIndex: 8
    BoneItem(img: feetLImg, cx: 36.0, cy: 95.9, w: 31.9, h: 6.8, zIndex: 8),
    // zIndex: 10
    BoneItem(img: skullImg, cx: 48.0, cy: 8.5, w: 38.0, h: 12.4, zIndex: 10)
]

let sortedPieces = pieces.sorted { $0.zIndex < $1.zIndex }

let canvas = NSImage(size: NSSize(width: charW, height: charH))
canvas.lockFocus()

imgSolo.draw(in: NSRect(x: 0, y: 0, width: charW, height: charH))

for p in sortedPieces {
    let destW = p.w / 100.0 * charW
    let destH = p.h / 100.0 * charH
    let destX = (p.cx / 100.0 * charW) - (destW / 2.0)
    let screenY = (p.cy / 100.0 * charH) - (destH / 2.0)
    let cocoaY = charH - screenY - destH
    
    p.img.draw(in: NSRect(x: destX, y: cocoaY, width: destW, height: destH),
               from: NSRect.zero,
               operation: .sourceOver,
               fraction: 1.0)
}

canvas.unlockFocus()

let outRep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
let outPng = outRep.representation(using: .png, properties: [:])!
try! outPng.write(to: URL(fileURLWithPath: "scratch/test_pieces_reassembled.png"))
print("Saved scratch/test_pieces_reassembled.png")

// Side by side with user screenshot!
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
try! sidePng.write(to: URL(fileURLWithPath: "scratch/side_by_side_pieces_reassembled.png"))
print("Saved scratch/side_by_side_pieces_reassembled.png")
