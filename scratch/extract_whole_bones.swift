import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

func getCleanPixel(x: Int, y: Int) -> NSColor? {
    guard x >= 0 && x < repSkel.pixelsWide && y >= 0 && y < repSkel.pixelsHigh else { return nil }
    let c = repSkel.colorAt(x: x, y: y)!
    let r = c.redComponent
    let g = c.greenComponent
    let b = c.blueComponent
    if r > 0.78 && g > 0.78 && b > 0.78 { return c }
    if b > 0.38 && g > 0.32 && g > r + 0.03 { return c }
    if x >= 810 && x <= 865 && y >= 440 && y <= 515 && r < 0.25 && g < 0.25 && b < 0.35 { return c }
    return nil
}

func cropRegion(minX: Int, maxX: Int, minY: Int, maxY: Int, predicate: ((Int, Int) -> Bool)? = nil) -> NSBitmapImageRep {
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
    return rep
}

// 1. Skull: Full cranium, jaw, teeth, solid eye socket & nose.
// Jaw ends at y=536.
let skullRep = cropRegion(minX: 700, maxX: 863, minY: 372, maxY: 536) { x, y in
    if x < 745 && y > 515 { return false } // strip spine fragment
    return true
}

// 2. Spine: Continuous column from under skull (y=535) through neck (x:720..775) and chest/lumbar (x:735..785) to pelvis (y=945)
let spineRep = cropRegion(minX: 720, maxX: 785, minY: 535, maxY: 945) { x, y in
    if y <= 640 { return x >= 720 && x <= 775 }
    return x >= 735 && x <= 785
}

// 3. Ribcage: Complete clavicles and rib cage! (y: 625..865, x: 635..870)
// To keep rib cage intact, include all ribs and clavicles!
let ribcageRep = cropRegion(minX: 635, maxX: 870, minY: 625, maxY: 865) { x, y in
    // Keep all ribs! Only exclude left arm where it's outside the ribs (x < 650, y > 670)
    if x < 650 && y >= 670 { return false }
    return true
}

// 4. Pelvis: Complete pelvis
let pelvisRep = cropRegion(minX: 655, maxX: 875, minY: 935, maxY: 1080)

// 5. Left Arm (front):
let humerusLRep = cropRegion(minX: 596, maxX: 675, minY: 645, maxY: 810) { x, y in
    if y < 655 && x > 645 { return false } // clavicle
    return true
}
let radiusUlnaLRep = cropRegion(minX: 596, maxX: 690, minY: 800, maxY: 970)
let handsLRep = cropRegion(minX: 655, maxX: 720, minY: 965, maxY: 1075)

// 6. Right Arm (back):
let humerusRRep = cropRegion(minX: 845, maxX: 885, minY: 725, maxY: 840)
let radiusUlnaRRep = cropRegion(minX: 845, maxX: 915, minY: 830, maxY: 965)
let handsRRep = cropRegion(minX: 885, maxX: 935, minY: 965, maxY: 1065)

// 7. Left Leg (front):
let femurLRep = cropRegion(minX: 655, maxX: 755, minY: 1040, maxY: 1315)
let fibulaTibiaLRep = cropRegion(minX: 650, maxX: 735, minY: 1300, maxY: 1565)
let feetLRep = cropRegion(minX: 645, maxX: 780, minY: 1545, maxY: 1633)

// 8. Right Leg (back):
let femurRRep = cropRegion(minX: 785, maxX: 885, minY: 1040, maxY: 1315)
let fibulaTibiaRRep = cropRegion(minX: 820, maxX: 885, minY: 1300, maxY: 1565)
let feetRRep = cropRegion(minX: 820, maxX: 967, minY: 1540, maxY: 1610)

let allSlices = [
    ("Bone_older_boy_skull.png", skullRep),
    ("Bone_older_boy_spine.png", spineRep),
    ("Bone_older_boy_ribcage.png", ribcageRep),
    ("Bone_older_boy_pelvis.png", pelvisRep),
    ("Bone_older_boy_humerus_left.png", humerusLRep),
    ("Bone_older_boy_radius_ulna_left.png", radiusUlnaLRep),
    ("Bone_older_boy_hands_left.png", handsLRep),
    ("Bone_older_boy_humerus_right.png", humerusRRep),
    ("Bone_older_boy_radius_ulna_right.png", radiusUlnaRRep),
    ("Bone_older_boy_hands_right.png", handsRRep),
    ("Bone_older_boy_femur_left.png", femurLRep),
    ("Bone_older_boy_fibula_tibia_left.png", fibulaTibiaLRep),
    ("Bone_older_boy_feet_left.png", feetLRep),
    ("Bone_older_boy_femur_right.png", femurRRep),
    ("Bone_older_boy_fibula_tibia_right.png", fibulaTibiaRRep),
    ("Bone_older_boy_feet_right.png", feetRRep)
]

for (file, rep) in allSlices {
    let data = rep.representation(using: .png, properties: [:])!
    try! data.write(to: URL(fileURLWithPath: "scratch/whole_\(file)"))
}
print("Saved all whole bones")

