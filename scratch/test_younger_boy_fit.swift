import AppKit

struct BonePieceDef {
    let id: String
    let file: String
    let x: Double
    let y: Double
    let w: Double
    let h: Double
    let rot: Double
    let z: Int
}

// Candidate definition based on exact target measurements:
// In target (161x466):
// Skull: x: 49.5%, y: 13.7%, w: 55.0%, h: 20.0%, rot: 0
// Spine: x: 50.0%, y: 41.0%, w: 7.0%, h: 42.0%, rot: 0
// Ribcage: x: 50.0%, y: 35.0%, w: 87.5%, h: 25.0%, rot: 0
// Pelvis: x: 50.0%, y: 58.0%, w: 68.0%, h: 19.5%, rot: 0

// Left Arm (viewer left = character's right in anatomical, but our asset name is left/right):
// Notice: In assets/bones/:
// Let's check which is which: Bone_humerus_left.png vs Bone_humerus_right.png!
let candidateBones: [BonePieceDef] = [
    // Spine
    BonePieceDef(id: "spine", file: "Bone_spine.png", x: 50.0, y: 41.0, w: 7.0, h: 42.0, rot: 0, z: 1),
    // Pelvis
    BonePieceDef(id: "pelvis", file: "Bone_pelvis.png", x: 50.0, y: 58.0, w: 68.0, h: 19.5, rot: 0, z: 2),
    // Ribcage
    BonePieceDef(id: "ribcage", file: "Bone_ribcage.png", x: 50.0, y: 35.0, w: 87.5, h: 25.0, rot: 0, z: 3),
    // Skull
    BonePieceDef(id: "skull", file: "Bone_skull.png", x: 49.5, y: 13.7, w: 55.0, h: 20.0, rot: 0, z: 10),

    // Left Arm (viewer's left side: x ~ 10-15%)
    BonePieceDef(id: "humerus", file: "Bone_humerus_left.png", x: 12.5, y: 36.3, w: 20.0, h: 20.0, rot: 2.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_left.png", x: 9.0, y: 49.4, w: 17.5, h: 13.0, rot: 10.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_left.png", x: 7.8, y: 57.3, w: 16.0, h: 10.0, rot: 24.0, z: 6),

    // Right Arm (viewer's right side: x ~ 85-90%)
    BonePieceDef(id: "humerus", file: "Bone_humerus_right.png", x: 87.5, y: 36.3, w: 20.0, h: 20.0, rot: -2.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_right.png", x: 91.0, y: 49.4, w: 17.5, h: 13.0, rot: -10.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_right.png", x: 92.2, y: 57.3, w: 16.0, h: 10.0, rot: -24.0, z: 6),

    // Left Leg (viewer's left side: x ~ 30%)
    BonePieceDef(id: "femur", file: "Bone_femur_left.png", x: 31.4, y: 69.7, w: 25.0, h: 21.7, rot: -10.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_left.png", x: 30.4, y: 85.3, w: 20.5, h: 16.3, rot: -2.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_left.png", x: 23.9, y: 94.8, w: 25.0, h: 9.8, rot: 43.0, z: 8),

    // Right Leg (viewer's right side: x ~ 70%)
    BonePieceDef(id: "femur", file: "Bone_femur_right.png", x: 68.6, y: 69.7, w: 25.0, h: 21.7, rot: 10.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_right.png", x: 69.6, y: 85.3, w: 20.5, h: 16.3, rot: 2.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_right.png", x: 76.1, y: 94.8, w: 25.0, h: 9.8, rot: -43.0, z: 8)
]

func renderCandidate() {
    let charPath = "assets/Character_YoungerBoy_Solo.png"
    guard let charImg = NSImage(contentsOfFile: charPath),
          let charCg = charImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        print("Failed to load character")
        return
    }
    let W = charCg.width // 186
    let H = charCg.height // 538

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

    guard let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: bitmapInfo) else { return }

    // Draw character silhouette at 35% opacity
    ctx.setAlpha(0.35)
    ctx.draw(charCg, in: CGRect(x: 0, y: 0, width: W, height: H))
    ctx.setAlpha(1.0)

    let sorted = candidateBones.sorted { $0.z < $1.z }

    for b in sorted {
        let bonePath = "assets/bones/\(b.file)"
        guard let bImg = NSImage(contentsOfFile: bonePath),
              let bCg = bImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("Missing \(bonePath)")
            continue
        }

        ctx.saveGState()
        let cx = CGFloat(b.x / 100.0 * Double(W))
        let cy = CGFloat((100.0 - b.y) / 100.0 * Double(H))
        let bw = CGFloat(b.w / 100.0 * Double(W))
        let bh = CGFloat(b.h / 100.0 * Double(H))

        ctx.translateBy(x: cx, y: cy)
        ctx.rotate(by: CGFloat(-b.rot * Double.pi / 180.0))
        ctx.draw(bCg, in: CGRect(x: -bw / 2.0, y: -bh / 2.0, width: bw, height: bh))
        ctx.restoreGState()
    }

    if let compImg = ctx.makeImage() {
        let rep = NSBitmapImageRep(cgImage: compImg)
        let png = rep.representation(using: .png, properties: [:])
        let outPath = "scratch/candidate_younger_boy.png"
        try? png?.write(to: URL(fileURLWithPath: outPath))
        print("Rendered: \(outPath)")
    }
}

renderCandidate()
