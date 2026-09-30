import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!
let charW = 220.0
let charH = 681.0

print("truth_assembled_scaled size: \(repSkel.pixelsWide) x \(repSkel.pixelsHigh)")

// Helper to crop non-empty region
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

struct SliceDef {
    let id: String
    let pieceId: String
    let name: String
    let filename: String
    let iosImageName: String
    let zIndex: Int
    let minX: Int
    let maxX: Int
    let minY: Int
    let maxY: Int
    let predicate: ((Int, Int) -> Bool)?
}

// In 220 x 681 coordinates (scale from 166x511 is ~1.33x):
let defs: [SliceDef] = [
    // 1. Skull: dome, face, teeth, jaw (up to y=115 px). Cervical spine starts around y=112..115.
    SliceDef(id: "skull", pieceId: "skull", name: "Skull",
             filename: "Bone_older_boy_skull.png", iosImageName: "AnatomyBoneOlderBoySkull", zIndex: 10,
             minX: 45, maxX: 155, minY: 10, maxY: 114,
             predicate: { x, y in !(x < 95 && y > 105) }),
    
    // 2. Spine: cervical from under skull (y=112) through thorax and lumbar to pelvis (y=400)
    SliceDef(id: "spine", pieceId: "spine", name: "Spine",
             filename: "Bone_older_boy_spine.png", iosImageName: "AnatomyBoneOlderBoySpine", zIndex: 1,
             minX: 70, maxX: 115, minY: 112, maxY: 400,
             predicate: { x, y in y <= 160 ? (x >= 70 && x <= 105) : (x >= 75 && x <= 112) }),
    
    // 3. Ribcage: Complete clavicles (left & right) and all ribs!
    SliceDef(id: "ribcage", pieceId: "ribcage", name: "Ribcage",
             filename: "Bone_older_boy_ribcage.png", iosImageName: "AnatomyBoneOlderBoyRibcage", zIndex: 3,
             minX: 20, maxX: 155, minY: 145, maxY: 300,
             predicate: { x, y in !(x < 35 && y >= 170) }),
    
    // 4. Pelvis: Complete pelvic girdle
    SliceDef(id: "pelvis", pieceId: "pelvis", name: "Pelvis",
             filename: "Bone_older_boy_pelvis.png", iosImageName: "AnatomyBoneOlderBoyPelvis", zIndex: 2,
             minX: 40, maxX: 180, minY: 300, maxY: 415,
             predicate: { x, y in
                 if x < 65 && y > 330 { return false } // front hand
                 if x < 50 && y < 330 { return false } // front forearm
                 if x > 160 { return false } // back arm/hand
                 return true
             }),
    
    // 5. Front Arm (Left):
    SliceDef(id: "humerus", pieceId: "humerus_l", name: "Humerus",
             filename: "Bone_older_boy_humerus_left.png", iosImageName: "AnatomyBoneOlderBoyHumerusLeft", zIndex: 4,
             minX: 5, maxX: 50, minY: 155, maxY: 260,
             predicate: { x, y in !(y < 165 && x > 35) }),
    SliceDef(id: "radius_ulna", pieceId: "radius_ulna_l", name: "Radius and Ulna",
             filename: "Bone_older_boy_radius_ulna_left.png", iosImageName: "AnatomyBoneOlderBoyRadiusUlnaLeft", zIndex: 5,
             minX: 5, maxX: 60, minY: 250, maxY: 355,
             predicate: nil),
    SliceDef(id: "hands", pieceId: "hands_l", name: "Hands",
             filename: "Bone_older_boy_hands_left.png", iosImageName: "AnatomyBoneOlderBoyHandsLeft", zIndex: 6,
             minX: 30, maxX: 75, minY: 335, maxY: 405,
             predicate: nil),
    
    // 6. Back Arm (Right):
    SliceDef(id: "humerus", pieceId: "humerus_r", name: "Humerus",
             filename: "Bone_older_boy_humerus_right.png", iosImageName: "AnatomyBoneOlderBoyHumerusRight", zIndex: 2,
             minX: 140, maxX: 168, minY: 200, maxY: 285,
             predicate: nil),
    SliceDef(id: "radius_ulna", pieceId: "radius_ulna_r", name: "Radius and Ulna",
             filename: "Bone_older_boy_radius_ulna_right.png", iosImageName: "AnatomyBoneOlderBoyRadiusUlnaRight", zIndex: 2,
             minX: 145, maxX: 180, minY: 280, maxY: 360,
             predicate: nil),
    SliceDef(id: "hands", pieceId: "hands_r", name: "Hands",
             filename: "Bone_older_boy_hands_right.png", iosImageName: "AnatomyBoneOlderBoyHandsRight", zIndex: 6,
             minX: 165, maxX: 192, minY: 345, maxY: 405,
             predicate: nil),
    
    // 7. Front Leg (Left):
    SliceDef(id: "femur", pieceId: "femur_l", name: "Femur",
             filename: "Bone_older_boy_femur_left.png", iosImageName: "AnatomyBoneOlderBoyFemurLeft", zIndex: 4,
             minX: 30, maxX: 85, minY: 395, maxY: 515,
             predicate: nil),
    SliceDef(id: "fibula_tibia", pieceId: "fibula_tibia_l", name: "Tibia and Fibula",
             filename: "Bone_older_boy_fibula_tibia_left.png", iosImageName: "AnatomyBoneOlderBoyFibulaTibiaLeft", zIndex: 7,
             minX: 30, maxX: 70, minY: 510, maxY: 625,
             predicate: nil),
    SliceDef(id: "feet", pieceId: "feet_l", name: "Feet",
             filename: "Bone_older_boy_feet_left.png", iosImageName: "AnatomyBoneOlderBoyFeetLeft", zIndex: 8,
             minX: 25, maxX: 95, minY: 615, maxY: 678,
             predicate: nil),
    
    // 8. Back Leg (Right):
    SliceDef(id: "femur", pieceId: "femur_r", name: "Femur",
             filename: "Bone_older_boy_femur_right.png", iosImageName: "AnatomyBoneOlderBoyFemurRight", zIndex: 2,
             minX: 100, maxX: 155, minY: 395, maxY: 515,
             predicate: nil),
    SliceDef(id: "fibula_tibia", pieceId: "fibula_tibia_r", name: "Tibia and Fibula",
             filename: "Bone_older_boy_fibula_tibia_right.png", iosImageName: "AnatomyBoneOlderBoyFibulaTibiaRight", zIndex: 6,
             minX: 105, maxX: 145, minY: 510, maxY: 625,
             predicate: nil),
    SliceDef(id: "feet", pieceId: "feet_r", name: "Feet",
             filename: "Bone_older_boy_feet_right.png", iosImageName: "AnatomyBoneOlderBoyFeetRight", zIndex: 7,
             minX: 105, maxX: 202, minY: 615, maxY: 675,
             predicate: nil)
]

struct ExtractedPiece {
    let def: SliceDef
    let rep: NSBitmapImageRep
    let bx: Int
    let by: Int
    let bw: Int
    let bh: Int
}

var extracted: [ExtractedPiece] = []

print("Extracting 16 bones...")
for d in defs {
    let (rep, bx, by, bw, bh) = cropRegion(minX: d.minX, maxX: d.maxX, minY: d.minY, maxY: d.maxY, predicate: d.predicate)
    extracted.append(ExtractedPiece(def: d, rep: rep, bx: bx, by: by, bw: bw, bh: bh))
    let png = rep.representation(using: .png, properties: [:])!
    try! png.write(to: URL(fileURLWithPath: "scratch/slice_\(d.filename)"))
    print("  \(d.id) (\(d.pieceId)): \(bw)x\(bh) at (\(bx), \(by))")
}

// Print CSS & Swift configurations
print("\n--- JAVASCRIPT CONFIG ---")
print("      'older-boy': [")
for e in extracted {
    let cx = (Double(e.bx) + Double(e.bw) / 2.0) / charW * 100.0
    let cy = (Double(e.by) + Double(e.bh) / 2.0) / charH * 100.0
    let w = Double(e.bw) / charW * 100.0
    let h = Double(e.bh) / charH * 100.0
    print(String(format: "        { id: '%@', file: 'assets/bones/%@', x: %4.1f, y: %4.1f, w: %4.1f, h: %4.1f, rot: 0, zIndex: %d },",
                 e.def.id, e.def.filename, cx, cy, w, h, e.def.zIndex))
}
print("      ],")

print("\n--- SWIFT CONFIG ---")
print("        case \"older-boy\":")
print("            return [")
for e in extracted {
    let cx = (Double(e.bx) + Double(e.bw) / 2.0) / charW * 100.0
    let cy = (Double(e.by) + Double(e.bh) / 2.0) / charH * 100.0
    let w = Double(e.bw) / charW * 100.0
    let h = Double(e.bh) / charH * 100.0
    print(String(format: "                AnatomicalBonePiece(id: \"%@\", parentBoneId: \"%@\", name: \"%@\", x: %4.1f, y: %4.1f, width: %4.1f, height: %4.1f, rotationAngle: 0.0, zIndex: %d, imageName: \"%@\"),",
                 e.def.pieceId, e.def.id, e.def.name, cx, cy, w, h, e.def.zIndex, e.def.iosImageName))
}
print("            ]")

// Reassemble on character
let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let imgSolo = NSImage(contentsOf: urlSolo)!
let canvas = NSImage(size: NSSize(width: charW, height: charH))
canvas.lockFocus()
imgSolo.draw(in: NSRect(x: 0, y: 0, width: charW, height: charH))

let sorted = extracted.sorted { $0.def.zIndex < $1.def.zIndex }
for e in sorted {
    let img = NSImage(data: e.rep.representation(using: .png, properties: [:])!)!
    let cocoaY = charH - Double(e.by) - Double(e.bh)
    img.draw(in: NSRect(x: Double(e.bx), y: cocoaY, width: Double(e.bw), height: Double(e.bh)),
             from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
}
canvas.unlockFocus()

let outRep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
try! outRep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/reassembled_from_truth.png"))
print("Saved scratch/reassembled_from_truth.png")
