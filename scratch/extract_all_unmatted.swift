import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

let bgR = 0.3412
let bgG = 0.2510
let bgB = 0.6588

func unmattePixel(x: Int, y: Int) -> NSColor? {
    guard x >= 0 && x < repSkel.pixelsWide && y >= 0 && y < repSkel.pixelsHigh else { return nil }
    let c = repSkel.colorAt(x: x, y: y)!
    let r = Double(c.redComponent)
    let g = Double(c.greenComponent)
    let b = Double(c.blueComponent)
    
    let dr = r - bgR
    let dg = g - bgG
    let db = b - bgB
    let dist = sqrt(dr * dr + dg * dg + db * db)
    
    if dist < 0.10 {
        return nil
    }
    
    if dist < 0.25 {
        let alpha = min(1.0, max(0.0, (dist - 0.08) / (0.25 - 0.08)))
        let fgR = min(1.0, max(0.0, (r - (1.0 - alpha) * bgR) / alpha))
        let fgG = min(1.0, max(0.0, (g - (1.0 - alpha) * bgG) / alpha))
        let fgB = min(1.0, max(0.0, (b - (1.0 - alpha) * bgB) / alpha))
        return NSColor(calibratedRed: fgR, green: fgG, blue: fgB, alpha: alpha)
    }
    
    return c
}

func cropRegion(minX: Int, maxX: Int, minY: Int, maxY: Int, predicate: ((Int, Int) -> Bool)? = nil) -> (NSBitmapImageRep, Int, Int, Int, Int) {
    var bMinX = maxX, bMaxX = minX, bMinY = maxY, bMaxY = minY
    for y in minY...maxY {
        for x in minX...maxX {
            if let p = predicate, !p(x, y) { continue }
            if unmattePixel(x: x, y: y) != nil {
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
            if let color = unmattePixel(x: sx, y: sy) {
                rep.setColor(color, atX: x, y: y)
            } else {
                rep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
            }
        }
    }
    return (rep, bMinX, bMinY, pw, ph)
}

struct BonePartDef {
    let id: String
    let filename: String
    let zIndex: Int
    let minX: Int
    let maxX: Int
    let minY: Int
    let maxY: Int
    let predicate: ((Int, Int) -> Bool)?
}

// Precise bounding definitions:
let defs: [BonePartDef] = [
    // 1. Skull
    BonePartDef(id: "skull", filename: "Bone_older_boy_skull.png", zIndex: 10,
                minX: 700, maxX: 863, minY: 372, maxY: 536,
                predicate: { x, y in !(x < 745 && y > 515) }),
    
    // 2. Spine: cervical from under skull (y=535) through thoracic/lumbar to pelvis sacrum (y=945)
    BonePartDef(id: "spine", filename: "Bone_older_boy_spine.png", zIndex: 1,
                minX: 720, maxX: 785, minY: 535, maxY: 945,
                predicate: { x, y in y <= 640 ? (x >= 720 && x <= 775) : (x >= 735 && x <= 785) }),
    
    // 3. Ribcage: Complete clavicles and all ribs!
    BonePartDef(id: "ribcage", filename: "Bone_older_boy_ribcage.png", zIndex: 3,
                minX: 625, maxX: 875, minY: 625, maxY: 865,
                predicate: { x, y in !(x < 650 && y >= 670) }),
    
    // 4. Pelvis: Complete pelvic girdle (iliac wings, sacrum, pubic arch, ischia)
    BonePartDef(id: "pelvis", filename: "Bone_older_boy_pelvis.png", zIndex: 2,
                minX: 660, maxX: 900, minY: 920, maxY: 1120,
                predicate: { x, y in
                    if x < 720 && y > 970 { return false } // left hand
                    if x < 690 && y < 970 { return false } // left forearm
                    if x > 880 { return false } // right arm/hand
                    return true
                }),
    
    // 5. Left Arm (front):
    BonePartDef(id: "humerus_left", filename: "Bone_older_boy_humerus_left.png", zIndex: 4,
                minX: 596, maxX: 675, minY: 645, maxY: 810,
                predicate: { x, y in !(y < 655 && x > 645) }),
    BonePartDef(id: "radius_ulna_left", filename: "Bone_older_boy_radius_ulna_left.png", zIndex: 5,
                minX: 596, maxX: 690, minY: 800, maxY: 970,
                predicate: nil),
    BonePartDef(id: "hands_left", filename: "Bone_older_boy_hands_left.png", zIndex: 6,
                minX: 655, maxX: 720, minY: 965, maxY: 1075,
                predicate: nil),
    
    // 6. Right Arm (back):
    BonePartDef(id: "humerus_right", filename: "Bone_older_boy_humerus_right.png", zIndex: 2,
                minX: 845, maxX: 885, minY: 725, maxY: 840,
                predicate: nil),
    BonePartDef(id: "radius_ulna_right", filename: "Bone_older_boy_radius_ulna_right.png", zIndex: 2,
                minX: 845, maxX: 920, minY: 830, maxY: 980,
                predicate: nil),
    BonePartDef(id: "hands_right", filename: "Bone_older_boy_hands_right.png", zIndex: 6,
                minX: 885, maxX: 940, minY: 980, maxY: 1075,
                predicate: nil),
    
    // 7. Left Leg (front):
    BonePartDef(id: "femur_left", filename: "Bone_older_boy_femur_left.png", zIndex: 4,
                minX: 655, maxX: 760, minY: 1040, maxY: 1315,
                predicate: nil),
    BonePartDef(id: "fibula_tibia_left", filename: "Bone_older_boy_fibula_tibia_left.png", zIndex: 7,
                minX: 650, maxX: 735, minY: 1300, maxY: 1565,
                predicate: nil),
    BonePartDef(id: "feet_left", filename: "Bone_older_boy_feet_left.png", zIndex: 8,
                minX: 645, maxX: 780, minY: 1545, maxY: 1633,
                predicate: nil),
    
    // 8. Right Leg (back):
    BonePartDef(id: "femur_right", filename: "Bone_older_boy_femur_right.png", zIndex: 2,
                minX: 785, maxX: 885, minY: 1040, maxY: 1315,
                predicate: nil),
    BonePartDef(id: "fibula_tibia_right", filename: "Bone_older_boy_fibula_tibia_right.png", zIndex: 6,
                minX: 820, maxX: 885, minY: 1300, maxY: 1565,
                predicate: nil),
    BonePartDef(id: "feet_right", filename: "Bone_older_boy_feet_right.png", zIndex: 7,
                minX: 820, maxX: 967, minY: 1540, maxY: 1610,
                predicate: nil)
]

print("Extracting and saving all 16 bones...")
for d in defs {
    let (rep, bx, by, bw, bh) = cropRegion(minX: d.minX, maxX: d.maxX, minY: d.minY, maxY: d.maxY, predicate: d.predicate)
    let png = rep.representation(using: .png, properties: [:])!
    try! png.write(to: URL(fileURLWithPath: "scratch/unmatted_\(d.filename)"))
    print("  Saved scratch/unmatted_\(d.filename) (\(bw)x\(bh) at src: \(bx),\(by))")
}
