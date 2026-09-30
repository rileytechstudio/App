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

let candidateBones: [BonePieceDef] = [
    // Spine
    BonePieceDef(id: "spine", file: "Bone_spine.png", x: 50.0, y: 36.5, w: 7.5, h: 39.0, rot: 0, z: 1),
    // Pelvis
    BonePieceDef(id: "pelvis", file: "Bone_pelvis.png", x: 50.0, y: 57.0, w: 55.0, h: 17.0, rot: 0, z: 2),
    // Ribcage
    BonePieceDef(id: "ribcage", file: "Bone_ribcage.png", x: 50.0, y: 35.5, w: 68.0, h: 24.0, rot: 0, z: 3),
    // Skull
    BonePieceDef(id: "skull", file: "Bone_skull.png", x: 50.0, y: 13.5, w: 41.5, h: 21.0, rot: 0, z: 10),

    // Left Arm (viewer's left side: character's right)
    BonePieceDef(id: "humerus", file: "Bone_humerus_left.png", x: 17.5, y: 37.5, w: 17.5, h: 20.0, rot: 10.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_left.png", x: 13.0, y: 50.0, w: 14.5, h: 15.5, rot: 7.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_left.png", x: 10.5, y: 59.0, w: 13.5, h: 11.5, rot: 4.0, z: 6),

    // Right Arm (viewer's right side: character's left)
    BonePieceDef(id: "humerus", file: "Bone_humerus_right.png", x: 82.5, y: 37.5, w: 17.5, h: 20.0, rot: -10.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_right.png", x: 87.0, y: 50.0, w: 14.5, h: 15.5, rot: -7.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_right.png", x: 89.5, y: 59.0, w: 13.5, h: 11.5, rot: -4.0, z: 6),

    // Left Leg (viewer's left side: character's right)
    BonePieceDef(id: "femur", file: "Bone_femur_left.png", x: 34.0, y: 69.0, w: 20.0, h: 21.5, rot: 1.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_left.png", x: 32.5, y: 85.0, w: 16.5, h: 18.0, rot: 0.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_left.png", x: 25.5, y: 96.2, w: 23.5, h: 8.8, rot: 0.0, z: 8),

    // Right Leg (viewer's right side: character's left)
    BonePieceDef(id: "femur", file: "Bone_femur_right.png", x: 66.0, y: 69.0, w: 20.0, h: 21.5, rot: -1.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_right.png", x: 67.5, y: 85.0, w: 16.5, h: 18.0, rot: 0.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_right.png", x: 74.5, y: 96.2, w: 23.5, h: 8.8, rot: 0.0, z: 8)
]

func renderCandidate() {
    let charPath = "assets/Character_YoungerBoy_Solo.png"
    guard let charImg = NSImage(contentsOfFile: charPath),
          let charCg = charImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
    let W = charCg.width // 186
    let H = charCg.height // 538

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    guard let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: bitmapInfo) else { return }

    ctx.setAlpha(0.35)
    ctx.draw(charCg, in: CGRect(x: 0, y: 0, width: W, height: H))
    ctx.setAlpha(1.0)

    let sorted = candidateBones.sorted { $0.z < $1.z }
    for b in sorted {
        let bonePath = "assets/bones/\(b.file)"
        guard let bImg = NSImage(contentsOfFile: bonePath),
              let bCg = bImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else { continue }

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
        let png = rep.representation(using: .png, properties: [:])!
        try? png.write(to: URL(fileURLWithPath: "scratch/candidate_younger_boy.png"))
        
        guard let targetImg = NSImage(contentsOfFile: "scratch/user_younger_boy_target.png"),
              let targetCg = targetImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        let totalW = W * 2 + 20
        guard let sbsCtx = CGContext(data: nil, width: totalW, height: H, bitsPerComponent: 8, bytesPerRow: totalW * 4, space: colorSpace, bitmapInfo: bitmapInfo) else { return }
        sbsCtx.draw(targetCg, in: CGRect(x: 0, y: 0, width: W, height: H))
        sbsCtx.draw(compImg, in: CGRect(x: W + 20, y: 0, width: W, height: H))
        if let sbsImg = sbsCtx.makeImage() {
            let sbsRep = NSBitmapImageRep(cgImage: sbsImg)
            let sbsPng = sbsRep.representation(using: .png, properties: [:])!
            try? sbsPng.write(to: URL(fileURLWithPath: "scratch/comparison_side_by_side.png"))
            print("Saved round 4 comparison_side_by_side.png")
        }
    }
}

renderCandidate()
