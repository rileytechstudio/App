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

let youngerBoyBones: [BonePieceDef] = [
    BonePieceDef(id: "spine", file: "Bone_spine.png", x: 50.0, y: 31.0, w: 9.0, h: 26.0, rot: 0, z: 1),
    BonePieceDef(id: "pelvis", file: "Bone_pelvis.png", x: 50.0, y: 49.0, w: 38.0, h: 11.5, rot: 0, z: 2),
    BonePieceDef(id: "ribcage", file: "Bone_ribcage.png", x: 50.0, y: 31.0, w: 42.0, h: 15.0, rot: 0, z: 3),
    BonePieceDef(id: "skull", file: "Bone_skull.png", x: 50.0, y: 12.0, w: 32.0, h: 16.0, rot: 0, z: 10),

    // Left arm
    BonePieceDef(id: "humerus", file: "Bone_humerus_left.png", x: 23.0, y: 33.0, w: 13.0, h: 14.0, rot: 15.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_left.png", x: 14.5, y: 43.5, w: 8.5, h: 11.0, rot: 14.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_left.png", x: 6.5, y: 54.5, w: 9.5, h: 8.5, rot: 12.0, z: 6),

    // Right arm
    BonePieceDef(id: "humerus", file: "Bone_humerus_right.png", x: 77.0, y: 33.0, w: 13.0, h: 14.0, rot: -15.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_right.png", x: 85.5, y: 43.5, w: 8.5, h: 11.0, rot: -14.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_right.png", x: 93.5, y: 54.5, w: 9.5, h: 8.5, rot: -14.0, z: 6),

    // Left leg
    BonePieceDef(id: "femur", file: "Bone_femur_left.png", x: 38.0, y: 62.0, w: 14.0, h: 18.0, rot: 6.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_left.png", x: 30.5, y: 79.5, w: 11.0, h: 16.0, rot: 4.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_left.png", x: 27.5, y: 95.5, w: 14.5, h: 4.5, rot: -8.0, z: 8),

    // Right leg
    BonePieceDef(id: "femur", file: "Bone_femur_right.png", x: 62.0, y: 62.0, w: 14.0, h: 18.0, rot: -6.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_right.png", x: 69.5, y: 79.5, w: 11.0, h: 16.0, rot: -4.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_right.png", x: 74.0, y: 95.5, w: 14.5, h: 4.5, rot: 4.0, z: 8)
]

let youngerGirlBones: [BonePieceDef] = [
    BonePieceDef(id: "spine", file: "Bone_spine.png", x: 50.0, y: 31.0, w: 9.0, h: 26.0, rot: 0, z: 1),
    BonePieceDef(id: "pelvis", file: "Bone_pelvis.png", x: 50.0, y: 49.0, w: 37.0, h: 11.5, rot: 0, z: 2),
    BonePieceDef(id: "ribcage", file: "Bone_ribcage.png", x: 50.0, y: 31.0, w: 41.0, h: 15.0, rot: 0, z: 3),
    BonePieceDef(id: "skull", file: "Bone_skull.png", x: 50.0, y: 12.0, w: 32.0, h: 16.0, rot: 0, z: 10),

    // Left arm
    BonePieceDef(id: "humerus", file: "Bone_humerus_left.png", x: 23.0, y: 33.0, w: 13.0, h: 14.0, rot: 15.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_left.png", x: 13.5, y: 43.5, w: 9.5, h: 11.5, rot: 12.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_left.png", x: 8.0, y: 55.0, w: 8.5, h: 8.0, rot: 12.0, z: 6),

    // Right arm
    BonePieceDef(id: "humerus", file: "Bone_humerus_right.png", x: 76.0, y: 33.0, w: 12.5, h: 14.0, rot: -15.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_right.png", x: 87.0, y: 43.0, w: 8.5, h: 11.0, rot: -17.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_right.png", x: 92.0, y: 55.0, w: 9.0, h: 8.0, rot: -12.0, z: 6),

    // Left leg
    BonePieceDef(id: "femur", file: "Bone_femur_left.png", x: 42.0, y: 62.0, w: 13.0, h: 18.0, rot: 3.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_left.png", x: 40.0, y: 81.0, w: 10.0, h: 16.0, rot: 2.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_left.png", x: 34.0, y: 95.5, w: 14.0, h: 4.5, rot: -4.0, z: 8),

    // Right leg
    BonePieceDef(id: "femur", file: "Bone_femur_right.png", x: 58.0, y: 62.0, w: 13.0, h: 18.0, rot: -3.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_right.png", x: 63.5, y: 81.0, w: 10.0, h: 16.0, rot: -2.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_right.png", x: 64.0, y: 95.5, w: 14.0, h: 4.5, rot: 4.0, z: 8)
]

let olderBoyBones: [BonePieceDef] = [
    // Spine
    BonePieceDef(id: "spine", file: "Bone_spine.png", x: 40.0, y: 29.0, w: 7.5, h: 24.0, rot: -2.0, z: 1),
    // Pelvis
    BonePieceDef(id: "pelvis", file: "Bone_pelvis.png", x: 44.0, y: 47.0, w: 32.0, h: 10.5, rot: 3.0, z: 2),
    // Ribcage
    BonePieceDef(id: "ribcage", file: "Bone_ribcage.png", x: 39.0, y: 29.0, w: 35.0, h: 14.0, rot: 0.0, z: 3),
    // Skull
    BonePieceDef(id: "skull", file: "Bone_skull.png", x: 47.0, y: 11.0, w: 25.0, h: 14.0, rot: 0.0, z: 10),

    // Left arm (front arm, resting on hip)
    BonePieceDef(id: "humerus", file: "Bone_humerus_left.png", x: 17.0, y: 29.5, w: 10.5, h: 13.0, rot: 12.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_left.png", x: 12.5, y: 39.5, w: 9.0, h: 11.5, rot: -15.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_left.png", x: 22.0, y: 46.5, w: 7.5, h: 7.0, rot: -45.0, z: 6),

    // Right arm (back arm)
    BonePieceDef(id: "humerus", file: "Bone_humerus_right.png", x: 62.0, y: 31.0, w: 10.5, h: 13.0, rot: -10.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_right.png", x: 69.0, y: 41.5, w: 9.5, h: 11.5, rot: -12.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_right.png", x: 74.0, y: 52.0, w: 7.5, h: 7.0, rot: -16.0, z: 6),

    // Left leg
    BonePieceDef(id: "femur", file: "Bone_femur_left.png", x: 36.0, y: 60.0, w: 12.0, h: 18.0, rot: 5.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_left.png", x: 29.5, y: 78.5, w: 9.5, h: 16.5, rot: 4.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_left.png", x: 25.0, y: 95.0, w: 15.0, h: 4.5, rot: -6.0, z: 8),

    // Right leg
    BonePieceDef(id: "femur", file: "Bone_femur_right.png", x: 57.0, y: 60.0, w: 12.0, h: 18.0, rot: -4.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_right.png", x: 61.5, y: 78.5, w: 9.5, h: 16.5, rot: -2.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_right.png", x: 68.0, y: 95.0, w: 16.0, h: 4.5, rot: 6.0, z: 8)
]

let olderGirlBones: [BonePieceDef] = [
    // Spine
    BonePieceDef(id: "spine", file: "Bone_spine.png", x: 42.0, y: 29.0, w: 7.5, h: 24.0, rot: -2.0, z: 1),
    // Pelvis
    BonePieceDef(id: "pelvis", file: "Bone_pelvis.png", x: 46.0, y: 47.0, w: 32.0, h: 10.5, rot: 3.0, z: 2),
    // Ribcage
    BonePieceDef(id: "ribcage", file: "Bone_ribcage.png", x: 41.0, y: 29.0, w: 35.0, h: 14.0, rot: 0.0, z: 3),
    // Skull
    BonePieceDef(id: "skull", file: "Bone_skull.png", x: 48.0, y: 11.0, w: 26.0, h: 14.5, rot: 0.0, z: 10),

    // Left arm
    BonePieceDef(id: "humerus", file: "Bone_humerus_left.png", x: 19.0, y: 29.5, w: 10.5, h: 13.0, rot: 12.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_left.png", x: 15.0, y: 40.0, w: 9.5, h: 11.5, rot: -10.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_left.png", x: 20.0, y: 48.0, w: 8.0, h: 7.5, rot: -35.0, z: 6),

    // Right arm
    BonePieceDef(id: "humerus", file: "Bone_humerus_right.png", x: 67.0, y: 31.0, w: 10.5, h: 13.0, rot: -10.0, z: 4),
    BonePieceDef(id: "radius_ulna", file: "Bone_radius_ulna_right.png", x: 74.0, y: 41.5, w: 9.0, h: 11.5, rot: -12.0, z: 5),
    BonePieceDef(id: "hands", file: "Bone_hands_right.png", x: 78.5, y: 52.0, w: 7.5, h: 7.0, rot: -16.0, z: 6),

    // Left leg
    BonePieceDef(id: "femur", file: "Bone_femur_left.png", x: 38.0, y: 60.0, w: 11.5, h: 18.0, rot: 4.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_left.png", x: 32.0, y: 78.5, w: 9.0, h: 16.5, rot: 3.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_left.png", x: 28.0, y: 95.0, w: 14.0, h: 4.5, rot: -4.0, z: 8),

    // Right leg
    BonePieceDef(id: "femur", file: "Bone_femur_right.png", x: 57.0, y: 60.0, w: 11.5, h: 18.0, rot: -3.0, z: 2),
    BonePieceDef(id: "fibula_tibia", file: "Bone_fibula_tibia_right.png", x: 65.0, y: 79.0, w: 9.0, h: 16.5, rot: -1.0, z: 7),
    BonePieceDef(id: "feet", file: "Bone_feet_right.png", x: 65.0, y: 95.0, w: 14.0, h: 4.5, rot: 6.0, z: 8)
]

func runVerification(charName: String, bones: [BonePieceDef]) {
    let charPath = "assets/Character_\(charName)_Solo.png"
    guard let charImg = NSImage(contentsOfFile: charPath),
          let charCg = charImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        print("Failed to load \(charPath)")
        return
    }
    let W = charCg.width
    let H = charCg.height
    guard let data = charCg.dataProvider?.data,
          let charPtr = CFDataGetBytePtr(data) else { return }
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

    visCtx.setAlpha(0.35)
    visCtx.draw(charCg, in: CGRect(x: 0, y: 0, width: W, height: H))
    visCtx.setAlpha(1.0)

    let sorted = bones.sorted { $0.z < $1.z }
    var totalBone = 0
    var totalOutside = 0

    print("==========================================")
    print("=== \(charName) (\(W) x \(H)) ===")
    print("==========================================")

    for b in sorted {
        let bonePath = "assets/bones/\(b.file)"
        guard let bImg = NSImage(contentsOfFile: bonePath),
              let bCg = bImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else { continue }

        guard let pieceCtx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: bitmapInfo) else { continue }
        pieceCtx.translateBy(x: 0, y: CGFloat(H))
        pieceCtx.scaleBy(x: 1.0, y: -1.0)

        let cx = CGFloat(b.x / 100.0 * Double(W))
        let cy = CGFloat(b.y / 100.0 * Double(H))
        let bw = CGFloat(b.w / 100.0 * Double(W))
        let bh = CGFloat(b.h / 100.0 * Double(H))

        pieceCtx.translateBy(x: cx, y: cy)
        pieceCtx.rotate(by: CGFloat(b.rot * Double.pi / 180.0))
        pieceCtx.draw(bCg, in: CGRect(x: -bw / 2.0, y: -bh / 2.0, width: bw, height: bh))

        skelCtx.saveGState()
        skelCtx.translateBy(x: cx, y: cy)
        skelCtx.rotate(by: CGFloat(b.rot * Double.pi / 180.0))
        skelCtx.draw(bCg, in: CGRect(x: -bw / 2.0, y: -bh / 2.0, width: bw, height: bh))
        skelCtx.restoreGState()

        guard let pCg = pieceCtx.makeImage(),
              let pData = pCg.dataProvider?.data,
              let pPtr = CFDataGetBytePtr(pData) else { continue }
        let pBpr = pCg.bytesPerRow
        let pBpp = pCg.bitsPerPixel / 8

        var pTot = 0
        var pOut = 0
        for y in 0..<H {
            for x in 0..<W {
                let off = y * pBpr + x * pBpp
                if pPtr[off + 3] > 25 {
                    pTot += 1
                    let cOff = y * charBpr + x * charBpp
                    if charPtr[cOff + 3] < 20 {
                        pOut += 1
                    }
                }
            }
        }
        totalBone += pTot
        totalOutside += pOut
        if pOut > 0 {
            print(String(format: "  ⚠️ %@: total=%d, outside=%d (%.1f%%)", b.file, pTot, pOut, Double(pOut)/Double(pTot)*100.0))
        } else {
            print("  ✅ \(b.file): PERFECT (0 outside)")
        }
    }

    if let skelImg = skelCtx.makeImage() {
        visCtx.draw(skelImg, in: CGRect(x: 0, y: 0, width: W, height: H))
        if let visImg = visCtx.makeImage() {
            let rep = NSBitmapImageRep(cgImage: visImg)
            let png = rep.representation(using: .png, properties: [:])
            let outPath = "scratch/fit_character_\(charName).png"
            try? png?.write(to: URL(fileURLWithPath: outPath))
            print("Saved composite visualization to \(outPath)")
        }
    }
    let pct = totalBone > 0 ? (Double(totalOutside)/Double(totalBone)*100.0) : 0
    print(String(format: "SUMMARY %@: %d/%d outside (%.2f%% outside)", charName, totalOutside, totalBone, pct))
}

runVerification(charName: "YoungerBoy", bones: youngerBoyBones)
runVerification(charName: "YoungerGirl", bones: youngerGirlBones)
runVerification(charName: "OlderBoy", bones: olderBoyBones)
runVerification(charName: "OlderGirl", bones: olderGirlBones)

func renderUpright(charName: String, bones: [BonePieceDef]) {
    let charPath = "assets/Character_\(charName)_Solo.png"
    guard let charImg = NSImage(contentsOfFile: charPath),
          let charCg = charImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
    let W = charCg.width
    let H = charCg.height

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

    guard let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: bitmapInfo) else { return }

    ctx.setAlpha(0.35)
    ctx.draw(charCg, in: CGRect(x: 0, y: 0, width: W, height: H))
    ctx.setAlpha(1.0)

    let sorted = bones.sorted { $0.z < $1.z }

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
        let png = rep.representation(using: .png, properties: [:])
        let outPath = "scratch/upright_\(charName).png"
        try? png?.write(to: URL(fileURLWithPath: outPath))
        print("Rendered upright preview: \(outPath)")
    }
}

renderUpright(charName: "YoungerBoy", bones: youngerBoyBones)
renderUpright(charName: "YoungerGirl", bones: youngerGirlBones)
renderUpright(charName: "OlderBoy", bones: olderBoyBones)
renderUpright(charName: "OlderGirl", bones: olderGirlBones)
