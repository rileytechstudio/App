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

// Measured directly from target image centroids:
let measuredBones: [BonePieceDef] = [
    // Spine
    BonePieceDef(id: "spine", file: "Bone_spine.png", x: 50.0, y: 36.5, w: 7.5, h: 41.0, rot: 0, z: 1),
    // Pelvis
    BonePieceDef(id: "pelvis", file: "Bone_pelvis.png", x: 50.0, y: 55.5, w: 58.0, h: 15.5, rot: 0, z: 2),
    // Ribcage
    BonePieceDef(id: "ribcage", file: "Bone_ribcage.png", x: 50.0, y: 35.2, w: 76.0, h: 23.5, rot: 0, z: 3),
    // Skull
    BonePieceDef(id: "skull", file: "Bone_skull.png", x: 50.0, y: 14.4, w: 48.0, h: 20.2, rot: 0, z: 10),

    // Left Arm (viewer's left side: character's right)
    // Shoulder: (19.2, 30.8), Elbow: (9.5, 44.7), Wrist: (7.5, 56.6), Hand tip: (6.4, 60.2)
    // Humerus center: (14.3, 37.8), dx = -9.7, dy = 13.9, angle from vertical = -34.9°
    // In our assets, Bone_humerus_left has angle -13°. In CSS rot: 34.9 - 13 = ~22° (or let's check direction: clockwise is positive)
    BonePieceDef(id: "humerus", file: "Bone_humerus_left.png", x: 14.3, y: 37.8, w: 16.5, h: 18.0, rot: 15.0, z: 4),
    // Forearm center: (8.5, 50.6)
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_left.png", x: 8.5, y: 50.6, w: 12.0, h: 14.0, rot: 8.0, z: 5),
    // Hand center: (7.0, 58.4)
    BonePieceDef(id: "hands", file: "Bone_hands_left.png", x: 7.0, y: 58.4, w: 12.0, h: 10.0, rot: 4.0, z: 6),

    // Right Arm (viewer's right side: character's left)
    // Symmetrical around 50%:
    // Humerus center: 50 + (50 - 14.3) = 85.7%
    BonePieceDef(id: "humerus", file: "Bone_humerus_right.png", x: 85.7, y: 37.8, w: 16.5, h: 18.0, rot: -15.0, z: 4),
    // Forearm center: 50 + (50 - 8.5) = 91.5%
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_right.png", x: 91.5, y: 50.6, w: 12.0, h: 14.0, rot: -8.0, z: 5),
    // Hand center: 50 + (50 - 7.0) = 93.0%
    BonePieceDef(id: "hands", file: "Bone_hands_right.png", x: 93.0, y: 58.4, w: 12.0, h: 10.0, rot: -4.0, z: 6),

    // Left Leg (viewer's left side: character's right)
    // Hip: (32.2, 61.3), Knee: (29.9, 80.2), Ankle: (28.2, 94.1)
    // Femur center: (31.1, 70.8)
    BonePieceDef(id: "femur", file: "Bone_femur_left.png", x: 31.1, y: 70.8, w: 19.0, h: 20.5, rot: 2.0, z: 2),
    // Tibia center: (29.1, 87.2)
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_left.png", x: 29.1, y: 87.2, w: 15.0, h: 16.5, rot: 0.0, z: 7),
    // Foot center: (24.0, 95.8)
    BonePieceDef(id: "feet", file: "Bone_feet_left.png", x: 24.0, y: 95.8, w: 22.0, h: 8.5, rot: 0.0, z: 8),

    // Right Leg (viewer's right side: character's left)
    // Symmetrical around 50%:
    // Femur center: 50 + (50 - 31.1) = 68.9%
    BonePieceDef(id: "femur", file: "Bone_femur_right.png", x: 68.9, y: 70.8, w: 19.0, h: 20.5, rot: -2.0, z: 2),
    // Tibia center: 50 + (50 - 29.1) = 70.9%
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_right.png", x: 70.9, y: 87.2, w: 15.0, h: 16.5, rot: 0.0, z: 7),
    // Foot center: 50 + (50 - 24.0) = 76.0%
    BonePieceDef(id: "feet", file: "Bone_feet_right.png", x: 76.0, y: 95.8, w: 22.0, h: 8.5, rot: 0.0, z: 8)
]

let charPath = "assets/Character_YoungerBoy_Solo.png"
guard let charImg = NSImage(contentsOfFile: charPath),
      let charCg = charImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else { exit(1) }
let W = charCg.width // 186
let H = charCg.height // 538

let colorSpace = CGColorSpaceCreateDeviceRGB()
let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
guard let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: bitmapInfo) else { exit(1) }

// Use character with slight tint matching user reference
ctx.setAlpha(0.65)
ctx.draw(charCg, in: CGRect(x: 0, y: 0, width: W, height: H))
ctx.setAlpha(1.0)

let sorted = measuredBones.sorted { $0.z < $1.z }
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

guard let compImg = ctx.makeImage() else { exit(1) }
guard let targetImg = NSImage(contentsOfFile: "scratch/user_younger_boy_target.png"),
      let targetCg = targetImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else { exit(1) }

let totalW = W * 2 + 20
guard let sbsCtx = CGContext(data: nil, width: totalW, height: H, bitsPerComponent: 8, bytesPerRow: totalW * 4, space: colorSpace, bitmapInfo: bitmapInfo) else { exit(1) }
sbsCtx.draw(targetCg, in: CGRect(x: 0, y: 0, width: W, height: H))
sbsCtx.draw(compImg, in: CGRect(x: W + 20, y: 0, width: W, height: H))

if let sbsImg = sbsCtx.makeImage() {
    let sbsRep = NSBitmapImageRep(cgImage: sbsImg)
    let sbsPng = sbsRep.representation(using: .png, properties: [:])!
    try! sbsPng.write(to: URL(fileURLWithPath: "scratch/measured_joints_comparison.png"))
    print("Saved scratch/measured_joints_comparison.png")
}

