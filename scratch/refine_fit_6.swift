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
    BonePieceDef(id: "spine", file: "Bone_spine.png", x: 50.0, y: 35.5, w: 7.5, h: 36.0, rot: 0, z: 1),
    // Pelvis
    BonePieceDef(id: "pelvis", file: "Bone_pelvis.png", x: 50.0, y: 55.5, w: 58.0, h: 15.0, rot: 0, z: 2),
    // Ribcage
    BonePieceDef(id: "ribcage", file: "Bone_ribcage.png", x: 50.0, y: 36.8, w: 68.0, h: 22.5, rot: 0, z: 3),
    // Skull
    BonePieceDef(id: "skull", file: "Bone_skull.png", x: 50.0, y: 13.5, w: 42.0, h: 20.0, rot: 0, z: 10),

    // Left Arm (viewer left):
    // Let's bring elbow together: Humerus slightly longer (h: 19.5%), lower (y: 38.5%). Forearm higher (y: 49.0%).
    // Angle humerus 15 deg, forearm 9 deg.
    BonePieceDef(id: "humerus", file: "Bone_humerus_left.png", x: 16.5, y: 38.2, w: 16.5, h: 19.0, rot: 15.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_left.png", x: 11.5, y: 49.0, w: 13.0, h: 14.5, rot: 9.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_left.png", x: 7.5, y: 57.0, w: 12.0, h: 10.5, rot: 4.0, z: 6),

    // Right Arm (viewer right):
    BonePieceDef(id: "humerus", file: "Bone_humerus_right.png", x: 83.5, y: 38.2, w: 16.5, h: 19.0, rot: -15.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_right.png", x: 88.5, y: 49.0, w: 13.0, h: 14.5, rot: -9.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_right.png", x: 92.5, y: 57.0, w: 12.0, h: 10.5, rot: -4.0, z: 6),

    // Left Leg:
    // Femur angled inwards: rot: +4.0 deg. Hip at x: 34%, Knee at x: 30.5%.
    BonePieceDef(id: "femur", file: "Bone_femur_left.png", x: 33.0, y: 68.5, w: 19.5, h: 21.0, rot: 4.0, z: 2),
    // Tibia: top connects to knee at x: 30.5%, y: 78.5%.
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_left.png", x: 30.5, y: 84.5, w: 15.5, h: 17.5, rot: 1.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_left.png", x: 26.5, y: 95.0, w: 22.0, h: 8.5, rot: 0.0, z: 8),

    // Right Leg:
    BonePieceDef(id: "femur", file: "Bone_femur_right.png", x: 67.0, y: 68.5, w: 19.5, h: 21.0, rot: -4.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_right.png", x: 69.5, y: 84.5, w: 15.5, h: 17.5, rot: -1.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_right.png", x: 73.5, y: 95.0, w: 22.0, h: 8.5, rot: 0.0, z: 8)
]

let charImg = NSImage(contentsOfFile: "assets/Character_YoungerBoy_Solo.png")!
let charCg = charImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!
let W = charCg.width
let H = charCg.height

let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { exit(1) }

ctx.setAlpha(0.5)
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

guard let compImg = ctx.makeImage(),
      let targetImg = NSImage(contentsOfFile: "scratch/user_younger_boy_target.png"),
      let targetCg = targetImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else { exit(1) }

let totalW = W * 2 + 20
guard let sbsCtx = CGContext(data: nil, width: totalW, height: H, bitsPerComponent: 8, bytesPerRow: totalW * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { exit(1) }
sbsCtx.draw(targetCg, in: CGRect(x: 0, y: 0, width: W, height: H))
sbsCtx.draw(compImg, in: CGRect(x: W + 20, y: 0, width: W, height: H))

if let sbsImg = sbsCtx.makeImage() {
    let sbsRep = NSBitmapImageRep(cgImage: sbsImg)
    let sbsPng = sbsRep.representation(using: .png, properties: [:])!
    try! sbsPng.write(to: URL(fileURLWithPath: "scratch/refined_comparison_6.png"))
    print("Saved scratch/refined_comparison_6.png")
}
