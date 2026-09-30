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
    BonePieceDef(id: "skull", file: "Bone_younger_boy_skull.png", x: 50.0, y: 14.4, w: 41.2, h: 17.9, z: 10),
    BonePieceDef(id: "spine", file: "Bone_younger_boy_spine.png", x: 49.8, y: 39.2, w: 10.7, h: 33.2, z: 1),
    BonePieceDef(id: "ribcage", file: "Bone_younger_boy_ribcage.png", x: 49.8, y: 37.3, w: 71.0, h: 21.7, z: 3),
    BonePieceDef(id: "pelvis", file: "Bone_younger_boy_pelvis.png", x: 49.8, y: 57.6, w: 57.8, h: 15.4, z: 2),
    BonePieceDef(id: "humerus", file: "Bone_younger_boy_humerus_left.png", x: 13.6, y: 38.3, w: 19.9, h: 16.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_younger_boy_radius_ulna_left.png", x: 8.0, y: 52.1, w: 15.5, h: 13.2, z: 5),
    BonePieceDef(id: "hands", file: "Bone_younger_boy_hands_left.png", x: 7.5, y: 60.8, w: 14.4, h: 5.2, z: 6),
    BonePieceDef(id: "humerus", file: "Bone_younger_boy_humerus_right.png", x: 85.9, y: 38.3, w: 19.5, h: 16.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_younger_boy_radius_ulna_right.png", x: 91.2, y: 52.1, w: 15.5, h: 13.2, z: 5),
    BonePieceDef(id: "hands", file: "Bone_younger_boy_hands_right.png", x: 92.1, y: 61.0, w: 14.4, h: 5.5, z: 6),
    BonePieceDef(id: "femur", file: "Bone_younger_boy_femur_left.png", x: 33.8, y: 71.3, w: 25.8, h: 19.8, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_younger_boy_fibula_tibia_left.png", x: 29.0, y: 89.4, w: 14.7, h: 17.9, z: 7),
    BonePieceDef(id: "feet", file: "Bone_younger_boy_feet_left.png", x: 24.1, y: 98.5, w: 21.7, h: 2.9, z: 8),
    BonePieceDef(id: "femur", file: "Bone_younger_boy_femur_right.png", x: 65.6, y: 71.3, w: 24.7, h: 19.8, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_younger_boy_fibula_tibia_right.png", x: 71.5, y: 89.4, w: 12.9, h: 17.9, z: 7),
    BonePieceDef(id: "feet", file: "Bone_younger_boy_feet_right.png", x: 77.2, y: 98.3, w: 22.1, h: 2.7, z: 8)
]

let soloUrl = URL(fileURLWithPath: "assets/Character_YoungerBoy_Solo.png")
let soloImg = NSImage(contentsOf: soloUrl)!
let soloRep = NSBitmapImageRep(data: soloImg.tiffRepresentation!)!
let W = soloRep.pixelsWide
let H = soloRep.pixelsHigh

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
try! pngData.write(to: URL(fileURLWithPath: "scratch/reassembled_slices_test.png"))
print("Saved scratch/reassembled_slices_test.png")

