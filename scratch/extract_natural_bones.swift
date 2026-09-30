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

func cropWithFilter(minX: Int, maxX: Int, minY: Int, maxY: Int, filter: (Int, Int) -> Bool) -> NSBitmapImageRep {
    var bMinX = maxX, bMaxX = minX, bMinY = maxY, bMaxY = minY
    for y in minY...maxY {
        for x in minX...maxX {
            if filter(x, y) && getCleanPixel(x: x, y: y) != nil {
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
            if filter(sx, sy), let color = getCleanPixel(x: sx, y: sy) {
                rep.setColor(color, atX: x, y: y)
            } else {
                rep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
            }
        }
    }
    return rep
}

// 1. Skull:
// Cranium + face + jaw (y: 372..536, x: 700..863)
// Jaw ends at y=536. Exclude spine fragment below jaw (x < 745, y > 515)
let skullRep = cropWithFilter(minX: 700, maxX: 863, minY: 372, maxY: 536) { x, y in
    if x < 745 && y > 515 { return false }
    return true
}

// 2. Spine:
// Cervical spine under skull (y=535), through thoracic spine to lumbar spine (y=945)
// In neck: x: 720..775, y: 535..640
// In chest/lumbar: x: 735..785, y: 640..945
let spineRep = cropWithFilter(minX: 720, maxX: 790, minY: 535, maxY: 945) { x, y in
    if y <= 640 { return x >= 720 && x <= 775 }
    return x >= 735 && x <= 785
}

// 3. Ribcage:
// Clavicles at top (y=625), all ribs and sternum down to y=865
let ribcageRep = cropWithFilter(minX: 635, maxX: 870, minY: 625, maxY: 865) { x, y in
    // Exclude left arm (x < 670, y >= 655)
    if x < 670 && y >= 655 { return false }
    // Exclude right arm (x > 845, y >= 730)
    if x > 845 && y >= 730 { return false }
    return true
}

// 4. Pelvis:
let pelvisRep = cropWithFilter(minX: 655, maxX: 875, minY: 935, maxY: 1080) { x, y in true }

// 5. Left Arm (front):
let humerusLRep = cropWithFilter(minX: 596, maxX: 675, minY: 645, maxY: 810) { x, y in
    // Exclude clavicle top
    if y < 655 && x > 640 { return false }
    return true
}
let radiusUlnaLRep = cropWithFilter(minX: 596, maxX: 690, minY: 800, maxY: 970) { x, y in true }
let handsLRep = cropWithFilter(minX: 655, maxX: 720, minY: 965, maxY: 1075) { x, y in true }

// 6. Right Arm (back):
let humerusRRep = cropWithFilter(minX: 845, maxX: 885, minY: 725, maxY: 840) { x, y in true }
let radiusUlnaRRep = cropWithFilter(minX: 845, maxX: 915, minY: 830, maxY: 965) { x, y in true }
let handsRRep = cropWithFilter(minX: 885, maxX: 935, minY: 965, maxY: 1065) { x, y in true }

// 7. Left Leg (front):
let femurLRep = cropWithFilter(minX: 655, maxX: 755, minY: 1040, maxY: 1315) { x, y in true }
let fibulaTibiaLRep = cropWithFilter(minX: 650, maxX: 735, minY: 1300, maxY: 1565) { x, y in true }
let feetLRep = cropWithFilter(minX: 645, maxX: 780, minY: 1545, maxY: 1633) { x, y in true }

// 8. Right Leg (back):
let femurRRep = cropWithFilter(minX: 785, maxX: 885, minY: 1040, maxY: 1315) { x, y in true }
let fibulaTibiaRRep = cropWithFilter(minX: 820, maxX: 885, minY: 1300, maxY: 1565) { x, y in true }
let feetRRep = cropWithFilter(minX: 820, maxX: 967, minY: 1540, maxY: 1610) { x, y in true }

// Save all to scratch
let slices = [
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

for (filename, rep) in slices {
    let data = rep.representation(using: .png, properties: [:])!
    try! data.write(to: URL(fileURLWithPath: "scratch/clean_\(filename)"))
    print(String(format: "Extracted clean %-32@: %3d x %3d (aspect: %.3f)", filename, rep.pixelsWide, rep.pixelsHigh, Double(rep.pixelsWide)/Double(rep.pixelsHigh)))
}

