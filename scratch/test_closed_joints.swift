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
    BonePieceDef(id: "spine", file: "Bone_spine.png", x: 50.0, y: 37.0, w: 8.0, h: 42.0, rot: 0, z: 1),
    // Pelvis
    BonePieceDef(id: "pelvis", file: "Bone_pelvis.png", x: 50.0, y: 56.0, w: 60.0, h: 16.0, rot: 0, z: 2),
    // Ribcage
    BonePieceDef(id: "ribcage", file: "Bone_ribcage.png", x: 50.0, y: 35.5, w: 78.0, h: 24.5, rot: 0, z: 3),
    // Skull
    BonePieceDef(id: "skull", file: "Bone_skull.png", x: 50.0, y: 15.0, w: 46.0, h: 21.0, rot: 0, z: 10),

    // Left Arm (viewer left):
    // Clavicle tip reaches x: 19.0%, y: 31.0%. Humerus head touches clavicle tip!
    // Elbow is at x: 11.5%, y: 44.5%.
    // Center: (15.2%, 37.8%), Width: 18.0%, Height: 18.5%, Rot: 16.0°
    BonePieceDef(id: "humerus", file: "Bone_humerus_left.png", x: 15.0, y: 38.0, w: 18.0, h: 18.5, rot: 16.0, z: 4),
    // Forearm top touches elbow at (11.5%, 44.5%). Wrist at (8.5%, 56.5%).
    // Center: (10.0%, 50.5%), Width: 13.5%, Height: 15.0%, Rot: 8.0°
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_left.png", x: 10.0, y: 50.5, w: 13.5, h: 15.0, rot: 8.0, z: 5),
    // Hand top touches wrist at (8.5%, 56.5%).
    // Center: (8.0%, 58.5%), Width: 13.0%, Height: 11.0%, Rot: 4.0°
    BonePieceDef(id: "hands", file: "Bone_hands_left.png", x: 8.0, y: 58.5, w: 13.0, h: 11.0, rot: 4.0, z: 6),

    // Right Arm (viewer right):
    BonePieceDef(id: "humerus", file: "Bone_humerus_right.png", x: 85.0, y: 38.0, w: 18.0, h: 18.5, rot: -16.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_right.png", x: 90.0, y: 50.5, w: 13.5, h: 15.0, rot: -8.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_right.png", x: 92.0, y: 58.5, w: 13.0, h: 11.0, rot: -4.0, z: 6),

    // Left Leg:
    // Pelvis hip socket at (33.0%, 61.5%). Knee at (30.0%, 80.0%).
    // Center: (31.5%, 70.8%), Width: 20.0%, Height: 21.0%, Rot: 2.0°
    BonePieceDef(id: "femur", file: "Bone_femur_left.png", x: 31.5, y: 70.8, w: 20.0, h: 21.0, rot: 2.0, z: 2),
    // Tibia top touches knee at (30.0%, 80.0%). Ankle at (28.5%, 94.0%).
    // Center: (29.2%, 87.0%), Width: 16.0%, Height: 17.0%, Rot: 0.0°
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_left.png", x: 29.2, y: 87.0, w: 16.0, h: 17.0, rot: 0.0, z: 7),
    // Foot touches ankle at (28.5%, 94.0%).
    // Center: (24.5%, 95.8%), Width: 23.0%, Height: 8.8%, Rot: 0.0°
    BonePieceDef(id: "feet", file: "Bone_feet_left.png", x: 24.5, y: 95.8, w: 23.0, h: 8.8, rot: 0.0, z: 8),

    // Right Leg:
    BonePieceDef(id: "femur", file: "Bone_femur_right.png", x: 68.5, y: 70.8, w: 20.0, h: 21.0, rot: -2.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_right.png", x: 70.8, y: 87.0, w: 16.0, h: 17.0, rot: 0.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_right.png", x: 75.5, y: 95.8, w: 23.0, h: 8.8, rot: 0.0, z: 8)
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
    try! sbsPng.write(to: URL(fileURLWithPath: "scratch/closed_joints_comparison.png"))
    print("Saved scratch/closed_joints_comparison.png")
}

