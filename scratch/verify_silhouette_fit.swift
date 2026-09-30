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
    BonePieceDef(id: "spine", file: "Bone_spine.png", x: 50.0, y: 36.5, w: 7.5, h: 39.0, rot: 0, z: 1),
    BonePieceDef(id: "pelvis", file: "Bone_pelvis.png", x: 50.0, y: 57.0, w: 55.0, h: 17.0, rot: 0, z: 2),
    BonePieceDef(id: "ribcage", file: "Bone_ribcage.png", x: 50.0, y: 35.5, w: 68.0, h: 24.0, rot: 0, z: 3),
    BonePieceDef(id: "skull", file: "Bone_skull.png", x: 50.0, y: 13.5, w: 41.5, h: 21.0, rot: 0, z: 10),

    BonePieceDef(id: "humerus", file: "Bone_humerus_left.png", x: 17.5, y: 37.5, w: 17.5, h: 20.0, rot: 10.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_left.png", x: 13.0, y: 50.0, w: 14.5, h: 15.5, rot: 7.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_left.png", x: 10.5, y: 59.0, w: 13.5, h: 11.5, rot: 4.0, z: 6),

    BonePieceDef(id: "humerus", file: "Bone_humerus_right.png", x: 82.5, y: 37.5, w: 17.5, h: 20.0, rot: -10.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_right.png", x: 87.0, y: 50.0, w: 14.5, h: 15.5, rot: -7.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_right.png", x: 89.5, y: 59.0, w: 13.5, h: 11.5, rot: -4.0, z: 6),

    BonePieceDef(id: "femur", file: "Bone_femur_left.png", x: 34.0, y: 69.0, w: 20.0, h: 21.5, rot: 1.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_left.png", x: 32.5, y: 85.0, w: 16.5, h: 18.0, rot: 0.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_left.png", x: 25.5, y: 96.2, w: 23.5, h: 8.8, rot: 0.0, z: 8),

    BonePieceDef(id: "femur", file: "Bone_femur_right.png", x: 66.0, y: 69.0, w: 20.0, h: 21.5, rot: -1.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_right.png", x: 67.5, y: 85.0, w: 16.5, h: 18.0, rot: 0.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_right.png", x: 74.5, y: 96.2, w: 23.5, h: 8.8, rot: 0.0, z: 8)
]

let charPath = "assets/Character_YoungerBoy_Solo.png"
guard let charImg = NSImage(contentsOfFile: charPath),
      let charCg = charImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    exit(1)
}
let W = charCg.width
let H = charCg.height
let charRep = NSBitmapImageRep(cgImage: charCg)

// Render skeleton only on transparent background
let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    exit(1)
}

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

guard let skelCg = ctx.makeImage() else { exit(1) }
let skelRep = NSBitmapImageRep(cgImage: skelCg)

var totalBonePixels = 0
var outsidePixels = 0

for y in 0..<H {
    for x in 0..<W {
        let skelA = skelRep.colorAt(x: x, y: y)!.alphaComponent
        if skelA > 0.15 {
            totalBonePixels += 1
            // Check character silhouette alpha (note: CGContext y is from bottom, so charRep y in AppKit is from top!)
            // In AppKit, y=0 is top. In CGContext, cy = H - y.
            // Let's sample charRep at (x, H - 1 - y)
            let charA = charRep.colorAt(x: x, y: H - 1 - y)!.alphaComponent
            if charA < 0.1 {
                outsidePixels += 1
            }
        }
    }
}

let insidePct = (Double(totalBonePixels - outsidePixels) / Double(totalBonePixels)) * 100.0
print("Silhouette Containment Test:")
print("Total Bone Pixels: \(totalBonePixels)")
print("Outside Pixels: \(outsidePixels)")
print("Containment: \(String(format: "%.2f", insidePct))%")

