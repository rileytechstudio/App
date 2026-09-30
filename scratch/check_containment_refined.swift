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

let bones: [BonePieceDef] = [
    BonePieceDef(id: "spine", file: "Bone_spine.png", x: 50.0, y: 35.5, w: 7.5, h: 36.0, rot: 0, z: 1),
    BonePieceDef(id: "pelvis", file: "Bone_pelvis.png", x: 50.0, y: 55.5, w: 58.0, h: 15.0, rot: 0, z: 2),
    BonePieceDef(id: "ribcage", file: "Bone_ribcage.png", x: 50.0, y: 36.8, w: 68.0, h: 22.5, rot: 0, z: 3),
    BonePieceDef(id: "skull", file: "Bone_skull.png", x: 50.0, y: 13.5, w: 42.0, h: 20.0, rot: 0, z: 10),
    BonePieceDef(id: "humerus", file: "Bone_humerus_left.png", x: 16.5, y: 38.2, w: 16.5, h: 19.0, rot: 15.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_left.png", x: 11.5, y: 49.0, w: 13.0, h: 14.5, rot: 9.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_left.png", x: 7.5, y: 57.0, w: 12.0, h: 10.5, rot: 4.0, z: 6),
    BonePieceDef(id: "humerus", file: "Bone_humerus_right.png", x: 83.5, y: 38.2, w: 16.5, h: 19.0, rot: -15.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_right.png", x: 88.5, y: 49.0, w: 13.0, h: 14.5, rot: -9.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_right.png", x: 92.5, y: 57.0, w: 12.0, h: 10.5, rot: -4.0, z: 6),
    BonePieceDef(id: "femur", file: "Bone_femur_left.png", x: 33.0, y: 68.5, w: 19.5, h: 21.0, rot: 4.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_left.png", x: 30.5, y: 84.5, w: 15.5, h: 17.5, rot: 1.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_left.png", x: 26.5, y: 95.0, w: 22.0, h: 8.5, rot: 0.0, z: 8),
    BonePieceDef(id: "femur", file: "Bone_femur_right.png", x: 67.0, y: 68.5, w: 19.5, h: 21.0, rot: -4.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_right.png", x: 69.5, y: 84.5, w: 15.5, h: 17.5, rot: -1.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_right.png", x: 73.5, y: 95.0, w: 22.0, h: 8.5, rot: 0.0, z: 8)
]

let charImg = NSImage(contentsOfFile: "assets/Character_YoungerBoy_Solo.png")!
let charCg = charImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!
let W = charCg.width
let H = charCg.height

let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let boneCtx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { exit(1) }

for b in bones {
    guard let bImg = NSImage(contentsOfFile: "assets/bones/\(b.file)"),
          let bCg = bImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else { continue }
    boneCtx.saveGState()
    let cx = CGFloat(b.x / 100.0 * Double(W))
    let cy = CGFloat((100.0 - b.y) / 100.0 * Double(H))
    let bw = CGFloat(b.w / 100.0 * Double(W))
    let bh = CGFloat(b.h / 100.0 * Double(H))
    boneCtx.translateBy(x: cx, y: cy)
    boneCtx.rotate(by: CGFloat(-b.rot * Double.pi / 180.0))
    boneCtx.draw(bCg, in: CGRect(x: -bw / 2.0, y: -bh / 2.0, width: bw, height: bh))
    boneCtx.restoreGState()
}

guard let boneCg = boneCtx.makeImage() else { exit(1) }

let charRep = NSBitmapImageRep(cgImage: charCg)
let boneRep = NSBitmapImageRep(cgImage: boneCg)

var totalBonePixels = 0
var outsidePixels = 0

for y in 0..<H {
    for x in 0..<W {
        let bColor = boneRep.colorAt(x: x, y: y)!
        if bColor.alphaComponent > 0.05 {
            totalBonePixels += 1
            let cColor = charRep.colorAt(x: x, y: y)!
            if cColor.alphaComponent <= 0.05 {
                outsidePixels += 1
            }
        }
    }
}

print("Total bone pixels: \(totalBonePixels)")
print("Outside pixels: \(outsidePixels) (\(Double(outsidePixels)/Double(totalBonePixels)*100.0)%)")
