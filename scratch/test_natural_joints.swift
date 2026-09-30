import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!
let charW = 220.0
let charH = 681.0

// First, extract Component 0 for skull
var skullPixels = Set<Int>()
var visited = Array(repeating: Array(repeating: false, count: 681), count: 220)
var q = [(100, 50)]
visited[100][50] = true
skullPixels.insert(100 * 1000 + 50)
var head = 0
while head < q.count {
    let curr = q[head]
    head += 1
    for dx in -1...1 {
        for dy in -1...1 {
            if dx == 0 && dy == 0 { continue }
            let nx = curr.0 + dx
            let ny = curr.1 + dy
            if nx >= 0 && nx < 220 && ny >= 0 && ny < 681 && !visited[nx][ny] {
                let nc = repSkel.colorAt(x: nx, y: ny)!
                if nc.alphaComponent > 0.05 {
                    visited[nx][ny] = true
                    skullPixels.insert(nx * 1000 + ny)
                    q.append((nx, ny))
                }
            }
        }
    }
}

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

let defs: [SliceDef] = [
    // 1. Skull: EXACT Component 0
    SliceDef(id: "skull", pieceId: "skull", name: "Skull",
             filename: "Bone_older_boy_skull.png", iosImageName: "AnatomyBoneOlderBoySkull", zIndex: 10,
             minX: 0, maxX: 219, minY: 0, maxY: 150,
             predicate: { x, y in skullPixels.contains(x * 1000 + y) }),
    
    // 2. Spine: from under skull (y=91) down to sacrum (y=400)
    SliceDef(id: "spine", pieceId: "spine", name: "Spine",
             filename: "Bone_older_boy_spine.png", iosImageName: "AnatomyBoneOlderBoySpine", zIndex: 1,
             minX: 65, maxX: 115, minY: 91, maxY: 400,
             predicate: { x, y in
                 if skullPixels.contains(x * 1000 + y) { return false }
                 return y <= 160 ? (x >= 65 && x <= 95) : (x >= 75 && x <= 112)
             }),
    
    // 3. Ribcage:
    SliceDef(id: "ribcage", pieceId: "ribcage", name: "Ribcage",
             filename: "Bone_older_boy_ribcage.png", iosImageName: "AnatomyBoneOlderBoyRibcage", zIndex: 3,
             minX: 20, maxX: 155, minY: 145, maxY: 300,
             predicate: { x, y in !(x < 35 && y >= 170) }),
    
    // 4. Pelvis:
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
             minX: 5, maxX: 50, minY: 155, maxY: 248,
             predicate: { x, y in !(y < 165 && x > 35) }),
    SliceDef(id: "radius_ulna", pieceId: "radius_ulna_l", name: "Radius and Ulna",
             filename: "Bone_older_boy_radius_ulna_left.png", iosImageName: "AnatomyBoneOlderBoyRadiusUlnaLeft", zIndex: 5,
             minX: 5, maxX: 60, minY: 250, maxY: 345,
             predicate: nil),
    SliceDef(id: "hands", pieceId: "hands_l", name: "Hands",
             filename: "Bone_older_boy_hands_left.png", iosImageName: "AnatomyBoneOlderBoyHandsLeft", zIndex: 6,
             minX: 30, maxX: 75, minY: 345, maxY: 405,
             predicate: nil),
    
    // 6. Back Arm (Right):
    SliceDef(id: "humerus", pieceId: "humerus_r", name: "Humerus",
             filename: "Bone_older_boy_humerus_right.png", iosImageName: "AnatomyBoneOlderBoyHumerusRight", zIndex: 2,
             minX: 140, maxX: 168, minY: 200, maxY: 278,
             predicate: nil),
    SliceDef(id: "radius_ulna", pieceId: "radius_ulna_r", name: "Radius and Ulna",
             filename: "Bone_older_boy_radius_ulna_right.png", iosImageName: "AnatomyBoneOlderBoyRadiusUlnaRight", zIndex: 2,
             minX: 145, maxX: 180, minY: 280, maxY: 354,
             predicate: nil),
    SliceDef(id: "hands", pieceId: "hands_r", name: "Hands",
             filename: "Bone_older_boy_hands_right.png", iosImageName: "AnatomyBoneOlderBoyHandsRight", zIndex: 6,
             minX: 165, maxX: 192, minY: 355, maxY: 405,
             predicate: nil),
    
    // 7. Front Leg (Left):
    // Femur ends naturally at y=501 (knee gap is at y=501..502)
    SliceDef(id: "femur", pieceId: "femur_l", name: "Femur",
             filename: "Bone_older_boy_femur_left.png", iosImageName: "AnatomyBoneOlderBoyFemurLeft", zIndex: 4,
             minX: 30, maxX: 85, minY: 395, maxY: 501,
             predicate: nil),
    // Tibia starts naturally at y=502 and ends at y=636 (ankle gap is at y=636..645)
    SliceDef(id: "fibula_tibia", pieceId: "fibula_tibia_l", name: "Tibia and Fibula",
             filename: "Bone_older_boy_fibula_tibia_left.png", iosImageName: "AnatomyBoneOlderBoyFibulaTibiaLeft", zIndex: 7,
             minX: 30, maxX: 70, minY: 502, maxY: 636,
             predicate: nil),
    // Foot starts naturally at y=645
    SliceDef(id: "feet", pieceId: "feet_l", name: "Feet",
             filename: "Bone_older_boy_feet_left.png", iosImageName: "AnatomyBoneOlderBoyFeetLeft", zIndex: 8,
             minX: 25, maxX: 95, minY: 645, maxY: 678,
             predicate: nil),
    
    // 8. Back Leg (Right):
    // Right femur ends naturally at y=500
    SliceDef(id: "femur", pieceId: "femur_r", name: "Femur",
             filename: "Bone_older_boy_femur_right.png", iosImageName: "AnatomyBoneOlderBoyFemurRight", zIndex: 2,
             minX: 100, maxX: 155, minY: 395, maxY: 500,
             predicate: nil),
    // Right tibia starts at y=501 and ends at y=623
    SliceDef(id: "fibula_tibia", pieceId: "fibula_tibia_r", name: "Tibia and Fibula",
             filename: "Bone_older_boy_fibula_tibia_right.png", iosImageName: "AnatomyBoneOlderBoyFibulaTibiaRight", zIndex: 6,
             minX: 105, maxX: 145, minY: 501, maxY: 623,
             predicate: nil),
    // Right foot starts at y=624
    SliceDef(id: "feet", pieceId: "feet_r", name: "Feet",
             filename: "Bone_older_boy_feet_right.png", iosImageName: "AnatomyBoneOlderBoyFeetRight", zIndex: 7,
             minX: 105, maxX: 202, minY: 624, maxY: 675,
             predicate: nil)
]

struct ExtractedBone {
    let def: SliceDef
    let rep: NSBitmapImageRep
    let bx: Int
    let by: Int
    let bw: Int
    let bh: Int
}

var allExtracted: [ExtractedBone] = []

print("Extracting natural joint bones...")
for d in defs {
    let (rep, bx, by, bw, bh) = cropRegion(minX: d.minX, maxX: d.maxX, minY: d.minY, maxY: d.maxY, predicate: d.predicate)
    allExtracted.append(ExtractedBone(def: d, rep: rep, bx: bx, by: by, bw: bw, bh: bh))
    print("  \(d.id) (\(d.pieceId)): \(bw)x\(bh) at (\(bx), \(by))")
}

// Reassemble on character
let canvas = NSImage(size: NSSize(width: charW, height: charH))
canvas.lockFocus()
let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let imgSolo = NSImage(contentsOf: urlSolo)!
imgSolo.draw(in: NSRect(x: 0, y: 0, width: charW, height: charH))

let sorted = allExtracted.sorted { $0.def.zIndex < $1.def.zIndex }
for e in sorted {
    let img = NSImage(data: e.rep.representation(using: .png, properties: [:])!)!
    let cocoaY = charH - Double(e.by) - Double(e.bh)
    img.draw(in: NSRect(x: Double(e.bx), y: cocoaY, width: Double(e.bw), height: Double(e.bh)),
             from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
}
canvas.unlockFocus()

let outRep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
try! outRep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/test_natural_reassembly.png"))
print("Saved scratch/test_natural_reassembly.png")
