import AppKit

// Load high-res Older Boy Skeleton.png
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

func cropRegion(minX: Int, maxX: Int, minY: Int, maxY: Int, exclude: ((Int, Int) -> Bool)? = nil) -> NSBitmapImageRep {
    var bMinX = maxX, bMaxX = minX, bMinY = maxY, bMaxY = minY
    for y in minY...maxY {
        for x in minX...maxX {
            if let ex = exclude, ex(x, y) { continue }
            if getCleanPixel(x: x, y: y) != nil {
                bMinX = min(bMinX, x)
                bMaxX = max(bMaxX, x)
                bMinY = min(bMinY, y)
                bMaxY = max(bMaxY, y)
            }
        }
    }
    let pw = bMaxX - bMinX + 1
    let ph = bMaxY - bMinY + 1
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pw, pixelsHigh: ph, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    for y in 0..<ph {
        for x in 0..<pw {
            let sx = bMinX + x
            let sy = bMinY + y
            if let ex = exclude, ex(sx, sy) {
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
    return rep
}

// 1. Skull: x: 700..863, y: 372..536, exclude bottom-left spine fragment (x < 745, y > 515)
let skullRep = cropRegion(minX: 700, maxX: 863, minY: 372, maxY: 536, exclude: { x, y in x < 745 && y > 515 })

// 2. Spine: we need the cervical spine to connect nicely to the skull and through ribcage to pelvis
// In Older Boy Skeleton.png, cervical spine is x: 720..770, y: 515..650. Lumbar spine is x: 740..780, y: 840..945.
// Let's crop the whole spine: x: 720..785, y: 520..945
let spineRep = cropRegion(minX: 720, maxX: 785, minY: 520, maxY: 945)

// 3. Ribcage: x: 640..855, y: 625..865
let ribcageRep = cropRegion(minX: 640, maxX: 855, minY: 625, maxY: 865)

// 4. Pelvis: x: 655..875, y: 935..1080
let pelvisRep = cropRegion(minX: 655, maxX: 875, minY: 935, maxY: 1080)

// 5. Limbs:
let humerusLRep = cropRegion(minX: 596, maxX: 675, minY: 640, maxY: 805)
let radiusUlnaLRep = cropRegion(minX: 596, maxX: 690, minY: 800, maxY: 970)
let handsLRep = cropRegion(minX: 655, maxX: 720, minY: 965, maxY: 1075)

let humerusRRep = cropRegion(minX: 845, maxX: 885, minY: 730, maxY: 840)
let radiusUlnaRRep = cropRegion(minX: 845, maxX: 915, minY: 830, maxY: 965)
let handsRRep = cropRegion(minX: 885, maxX: 935, minY: 965, maxY: 1065)

let femurLRep = cropRegion(minX: 655, maxX: 750, minY: 1040, maxY: 1310)
let fibulaTibiaLRep = cropRegion(minX: 650, maxX: 735, minY: 1300, maxY: 1565)
let feetLRep = cropRegion(minX: 645, maxX: 780, minY: 1545, maxY: 1633)

let femurRRep = cropRegion(minX: 785, maxX: 885, minY: 1040, maxY: 1310)
let fibulaTibiaRRep = cropRegion(minX: 820, maxX: 885, minY: 1300, maxY: 1565)
let feetRRep = cropRegion(minX: 820, maxX: 967, minY: 1540, maxY: 1610)

print("Cropped all high-res pieces cleanly!")

// Save test pieces
try! skullRep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/hires_skull.png"))
try! ribcageRep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/hires_ribcage.png"))
try! spineRep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/hires_spine.png"))

