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

func evaluateFit(character: String, bones: [BonePieceDef]) {
    let charPath = "assets/Character_\(character)_Solo.png"
    guard let charImg = NSImage(contentsOfFile: charPath),
          let charCg = charImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        print("Failed to load \(charPath)")
        return
    }
    let W = charCg.width
    let H = charCg.height

    guard let charData = charCg.dataProvider?.data,
          let charPtr = CFDataGetBytePtr(charData) else { return }
    let charBpr = charCg.bytesPerRow
    let charBpp = charCg.bitsPerPixel / 8

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

    print("=== Character: \(character) (\(W) x \(H)) ===")

    for bone in bones {
        guard let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: bitmapInfo) else { continue }
        ctx.translateBy(x: 0, y: CGFloat(H))
        ctx.scaleBy(x: 1.0, y: -1.0)

        let bonePath = "assets/bones/\(bone.file)"
        guard let boneImg = NSImage(contentsOfFile: bonePath),
              let boneCg = boneImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else { continue }

        let cx = CGFloat(bone.x / 100.0 * Double(W))
        let cy = CGFloat(bone.y / 100.0 * Double(H))
        let bw = CGFloat(bone.w / 100.0 * Double(W))
        let bh = CGFloat(bone.h / 100.0 * Double(H))

        ctx.translateBy(x: cx, y: cy)
        ctx.rotate(by: CGFloat(bone.rot * .pi / 180.0))
        ctx.draw(boneCg, in: CGRect(x: -bw / 2.0, y: -bh / 2.0, width: bw, height: bh))

        guard let pieceCg = ctx.makeImage(),
              let pieceData = pieceCg.dataProvider?.data,
              let piecePtr = CFDataGetBytePtr(pieceData) else { continue }
        let pBpr = pieceCg.bytesPerRow
        let pBpp = pieceCg.bitsPerPixel / 8

        var total = 0
        var outside = 0
        for y in 0..<H {
            for x in 0..<W {
                let off = y * pBpr + x * pBpp
                if piecePtr[off + 3] > 25 {
                    total += 1
                    let cOff = y * charBpr + x * charBpp
                    if charPtr[cOff + 3] < 20 {
                        outside += 1
                    }
                }
            }
        }
        let pct = total > 0 ? (Double(outside) / Double(total) * 100.0) : 0.0
        if outside > 0 {
            print("  ⚠️ \(bone.file): total=\(total), outside=\(outside) (\(String(format: "%.1f", pct))%)")
        } else {
            print("  ✅ \(bone.file): perfectly inside (0 outside px)")
        }
    }
}

let youngerBoyBones: [BonePieceDef] = [
    BonePieceDef(id: "spine", file: "Bone_spine.png", x: 50.0, y: 31.0, w: 9.0, h: 26.0, rot: 0, z: 1),
    BonePieceDef(id: "pelvis", file: "Bone_pelvis.png", x: 50.0, y: 49.0, w: 38.0, h: 11.5, rot: 0, z: 2),
    BonePieceDef(id: "ribcage", file: "Bone_ribcage.png", x: 50.0, y: 31.0, w: 42.0, h: 15.0, rot: 0, z: 3),
    BonePieceDef(id: "skull", file: "Bone_skull.png", x: 50.0, y: 12.0, w: 32.0, h: 16.0, rot: 0, z: 10),
    BonePieceDef(id: "humerus", file: "Bone_humerus_left.png", x: 23.0, y: 33.0, w: 14.0, h: 14.0, rot: 15.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_left.png", x: 15.0, y: 44.0, w: 14.0, h: 13.0, rot: 16.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_left.png", x: 9.0, y: 56.0, w: 14.0, h: 10.0, rot: 18.0, z: 6),
    BonePieceDef(id: "humerus", file: "Bone_humerus_right.png", x: 77.0, y: 33.0, w: 14.0, h: 14.0, rot: -15.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_right.png", x: 85.0, y: 44.0, w: 14.0, h: 13.0, rot: -16.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_right.png", x: 91.0, y: 56.0, w: 14.0, h: 10.0, rot: -18.0, z: 6),
    BonePieceDef(id: "femur", file: "Bone_femur_left.png", x: 40.0, y: 62.0, w: 15.0, h: 18.0, rot: 4.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_left.png", x: 38.0, y: 80.0, w: 13.0, h: 17.0, rot: 2.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_left.png", x: 34.0, y: 94.0, w: 24.0, h: 7.0, rot: 0.0, z: 8),
    BonePieceDef(id: "femur", file: "Bone_femur_right.png", x: 60.0, y: 62.0, w: 15.0, h: 18.0, rot: -4.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_right.png", x: 62.0, y: 80.0, w: 13.0, h: 17.0, rot: -2.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_right.png", x: 66.0, y: 94.0, w: 24.0, h: 7.0, rot: 0.0, z: 8)
]

evaluateFit(character: "YoungerBoy", bones: youngerBoyBones)
