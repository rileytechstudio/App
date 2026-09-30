import AppKit

struct BonePieceDef {
    let id: String
    let file: String
    let x: Double
    let y: Double
    let w: Double
    let h: Double
    let z: Int
}

let pieces: [BonePieceDef] = [
    BonePieceDef(id: "skull", file: "Bone_older_boy_skull.png", x: 47.8, y: 12.3, w: 37.6, h: 14.6, z: 10),
    BonePieceDef(id: "spine", file: "Bone_older_boy_spine.png", x: 42.0, y: 31.4, w: 16.4, h: 30.6, z: 1),
    BonePieceDef(id: "ribcage", file: "Bone_older_boy_ribcage.png", x: 42.0, y: 32.4, w: 53.2, h: 17.6, z: 3),
    BonePieceDef(id: "pelvis", file: "Bone_older_boy_pelvis.png", x: 44.9, y: 51.9, w: 52.1, h: 12.0, z: 2),
    BonePieceDef(id: "humerus_l", file: "Bone_older_boy_humerus_left.png", x: 14.4, y: 32.9, w: 18.7, h: 14.2, z: 4),
    BonePieceDef(id: "radius_ulna_l", file: "Bone_older_boy_radius_ulna_left.png", x: 16.1, y: 45.6, w: 22.1, h: 12.7, z: 5),
    BonePieceDef(id: "hands_l", file: "Bone_older_boy_hands_left.png", x: 26.6, y: 55.6, w: 15.0, h: 9.0, z: 6),
    BonePieceDef(id: "humerus_r", file: "Bone_older_boy_humerus_right.png", x: 67.5, y: 36.6, w: 9.7, h: 8.3, z: 2),
    BonePieceDef(id: "radius_ulna_r", file: "Bone_older_boy_radius_ulna_right.png", x: 70.6, y: 45.2, w: 15.9, h: 10.5, z: 2),
    BonePieceDef(id: "hands_r", file: "Bone_older_boy_hands_right.png", x: 77.6, y: 55.2, w: 11.5, h: 8.3, z: 6),
    BonePieceDef(id: "femur_l", file: "Bone_older_boy_femur_left.png", x: 29.8, y: 64.7, w: 22.3, h: 19.8, z: 4),
    BonePieceDef(id: "fibula_tibia_l", file: "Bone_older_boy_fibula_tibia_left.png", x: 27.8, y: 83.9, w: 20.3, h: 20.2, z: 7),
    BonePieceDef(id: "feet_l", file: "Bone_older_boy_feet_left.png", x: 32.2, y: 95.5, w: 31.3, h: 6.9, z: 8),
    BonePieceDef(id: "femur_r", file: "Bone_older_boy_femur_right.png", x: 60.4, y: 64.7, w: 23.3, h: 19.8, z: 2),
    BonePieceDef(id: "fibula_tibia_r", file: "Bone_older_boy_fibula_tibia_right.png", x: 64.5, y: 83.9, w: 15.2, h: 20.2, z: 6),
    BonePieceDef(id: "feet_r", file: "Bone_older_boy_feet_right.png", x: 73.7, y: 94.3, w: 34.1, h: 6.0, z: 7)
]

let soloUrl = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let soloImg = NSImage(contentsOf: soloUrl)!
let soloRep = NSBitmapImageRep(data: soloImg.tiffRepresentation!)!
let W = soloRep.pixelsWide // 220
let H = soloRep.pixelsHigh // 681

let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { exit(1) }

// Character silhouette at 50%
ctx.setAlpha(0.5)
ctx.draw(soloImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: CGRect(x: 0, y: 0, width: W, height: H))
ctx.setAlpha(1.0)

let sorted = pieces.sorted { $0.z < $1.z }
for p in sorted {
    guard let bImg = NSImage(contentsOfFile: "assets/bones/\(p.file)"),
          let bCg = bImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        print("Missing \(p.file)")
        continue
    }
    
    let cx = CGFloat(p.x / 100.0 * Double(W))
    let cy = CGFloat((100.0 - p.y) / 100.0 * Double(H))
    let bw = CGFloat(p.w / 100.0 * Double(W))
    let bh = CGFloat(p.h / 100.0 * Double(H))
    
    ctx.draw(bCg, in: CGRect(x: cx - bw / 2.0, y: cy - bh / 2.0, width: bw, height: bh))
}

guard let compCg = ctx.makeImage() else { exit(1) }
let rep = NSBitmapImageRep(cgImage: compCg)
let pngData = rep.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "scratch/older_boy_reassembled_slices_test.png"))
print("Saved scratch/older_boy_reassembled_slices_test.png")

