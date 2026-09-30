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

func verifyCharacter(name: String, bones: [BonePieceDef]) {
    let charPath = "assets/Character_\(name)_Solo.png"
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

    guard let skelCtx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: bitmapInfo),
          let visCtx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: bitmapInfo) else {
        return
    }

    skelCtx.translateBy(x: 0, y: CGFloat(H))
    skelCtx.scaleBy(x: 1.0, y: -1.0)
    visCtx.translateBy(x: 0, y: CGFloat(H))
    visCtx.scaleBy(x: 1.0, y: -1.0)

    // Draw character silhouette semi-transparent in visCtx
    visCtx.setAlpha(0.4)
    visCtx.draw(charCg, in: CGRect(x: 0, y: 0, width: W, height: H))
    visCtx.setAlpha(1.0)

    let sorted = bones.sorted { $0.z < $1.z }
    var totalBonePx = 0
    var totalOutsidePx = 0

    print("=== Checking \(name) (\(W)x\(H)) ===")

    for bone in sorted {
        let bonePath = "assets/bones/\(bone.file)"
        guard let boneImg = NSImage(contentsOfFile: bonePath),
              let boneCg = boneImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("Missing \(bonePath)")
            continue
        }

        // Individual piece check
        guard let pieceCtx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: bitmapInfo) else { continue }
        pieceCtx.translateBy(x: 0, y: CGFloat(H))
        pieceCtx.scaleBy(x: 1.0, y: -1.0)

        let cx = CGFloat(bone.x / 100.0 * Double(W))
        let cy = CGFloat(bone.y / 100.0 * Double(H))
        let bw = CGFloat(bone.w / 100.0 * Double(W))
        let bh = CGFloat(bone.h / 100.0 * Double(H))

        pieceCtx.translateBy(x: cx, y: cy)
        pieceCtx.rotate(by: CGFloat(bone.rot * .pi / 180.0))
        pieceCtx.draw(boneCg, in: CGRect(x: -bw / 2.0, y: -bh / 2.0, width: bw, height: bh))

        skelCtx.saveGState()
        skelCtx.translateBy(x: cx, y: cy)
        skelCtx.rotate(by: CGFloat(bone.rot * .pi / 180.0))
        skelCtx.draw(boneCg, in: CGRect(x: -bw / 2.0, y: -bh / 2.0, width: bw, height: bh))
        skelCtx.restoreGState()

        guard let pieceCg = pieceCtx.makeImage(),
              let pData = pieceCg.dataProvider?.data,
              let pPtr = CFDataGetBytePtr(pData) else { continue }
        let pBpr = pieceCg.bytesPerRow
        let pBpp = pieceCg.bitsPerPixel / 8

        var pTotal = 0
        var pOutside = 0
        for y in 0..<H {
            for x in 0..<W {
                let off = y * pBpr + x * pBpp
                if pPtr[off + 3] > 25 {
                    pTotal += 1
                    let cOff = y * charBpr + x * charBpp
                    if charPtr[cOff + 3] < 20 {
                        pOutside += 1
                    }
                }
            }
        }
        totalBonePx += pTotal
        totalOutsidePx += pOutside
        if pOutside > 0 {
            print(String(format: "  ⚠️ %@: total=%d, outside=%d (%.1f%%)", bone.file, pTotal, pOutside, Double(pOutside)/Double(pTotal)*100.0))
        } else {
            print("  ✅ \(bone.file): PERFECT (0 outside)")
        }
    }

    if let skelImg = skelCtx.makeImage() {
        visCtx.draw(skelImg, in: CGRect(x: 0, y: 0, width: W, height: H))
        if let visImg = visCtx.makeImage() {
            let rep = NSBitmapImageRep(cgImage: visImg)
            let png = rep.representation(using: .png, properties: [:])
            let outPath = "scratch/fit_character_\(name).png"
            try? png?.write(to: URL(fileURLWithPath: outPath))
            print("Saved verification image to \(outPath)")
        }
    }
    let pct = totalBonePx > 0 ? (Double(totalOutsidePx)/Double(totalBonePx)*100.0) : 0
    print(String(format: "Result for %@: %d/%d outside (%.2f%% outside)", name, totalOutsidePx, totalBonePx, pct))
}

let youngerBoyBones: [BonePieceDef] = [
    BonePieceDef(id: "spine", file: "Bone_spine.png", x: 50.0, y: 31.0, w: 9.0, h: 26.0, rot: 0, z: 1),
    BonePieceDef(id: "pelvis", file: "Bone_pelvis.png", x: 50.0, y: 49.0, w: 38.0, h: 11.5, rot: 0, z: 2),
    BonePieceDef(id: "ribcage", file: "Bone_ribcage.png", x: 50.0, y: 31.0, w: 42.0, h: 15.0, rot: 0, z: 3),
    BonePieceDef(id: "skull", file: "Bone_skull.png", x: 50.0, y: 12.0, w: 32.0, h: 16.0, rot: 0, z: 10),

    // Left arm
    BonePieceDef(id: "humerus", file: "Bone_humerus_left.png", x: 23.0, y: 33.0, w: 13.0, h: 14.0, rot: 15.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_left.png", x: 13.5, y: 43.5, w: 11.0, h: 12.0, rot: 12.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_left.png", x: 6.5, y: 54.5, w: 9.5, h: 8.5, rot: 12.0, z: 6),

    // Right arm
    BonePieceDef(id: "humerus", file: "Bone_humerus_right.png", x: 77.0, y: 33.0, w: 13.0, h: 14.0, rot: -15.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_right.png", x: 86.5, y: 43.5, w: 11.0, h: 12.0, rot: -12.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_right.png", x: 93.5, y: 54.5, w: 9.5, h: 8.5, rot: -14.0, z: 6),

    // Left leg
    BonePieceDef(id: "femur", file: "Bone_femur_left.png", x: 38.0, y: 62.0, w: 14.0, h: 18.0, rot: 6.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_left.png", x: 30.5, y: 79.5, w: 11.0, h: 16.0, rot: 4.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_left.png", x: 27.0, y: 95.5, w: 15.0, h: 4.5, rot: -8.0, z: 8),

    // Right leg
    BonePieceDef(id: "femur", file: "Bone_femur_right.png", x: 62.0, y: 62.0, w: 14.0, h: 18.0, rot: -6.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_right.png", x: 69.5, y: 79.5, w: 11.0, h: 16.0, rot: -4.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_right.png", x: 74.0, y: 95.5, w: 15.0, h: 4.5, rot: 4.0, z: 8)
]

verifyCharacter(name: "YoungerBoy", bones: youngerBoyBones)
