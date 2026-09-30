import AppKit

let skelUrl = URL(fileURLWithPath: "scratch/new_skel_cropped.png")
guard let skelImg = NSImage(contentsOf: skelUrl),
      let skelRep = NSBitmapImageRep(data: skelImg.tiffRepresentation!) else {
    exit(1)
}

let W = skelRep.pixelsWide // 269
let H = skelRep.pixelsHigh // 743

struct SliceInfo {
    let id: String
    let file: String
    let pMinX: Int
    let pMaxX: Int
    let pMinY: Int
    let pMaxY: Int
    let zIndex: Int
}

let pieceDefs: [SliceInfo] = [
    SliceInfo(id: "skull", file: "Bone_younger_boy_skull.png", pMinX: 79, pMaxX: 190, pMinY: 0, pMaxY: 140, zIndex: 10),
    SliceInfo(id: "spine", file: "Bone_younger_boy_spine.png", pMinX: 120, pMaxX: 148, pMinY: 135, pMaxY: 395, zIndex: 1),
    SliceInfo(id: "ribcage", file: "Bone_younger_boy_ribcage.png", pMinX: 38, pMaxX: 230, pMinY: 165, pMaxY: 335, zIndex: 3),
    SliceInfo(id: "pelvis", file: "Bone_younger_boy_pelvis.png", pMinX: 56, pMaxX: 212, pMinY: 350, pMaxY: 470, zIndex: 2),
    SliceInfo(id: "humerus_l", file: "Bone_younger_boy_humerus_left.png", pMinX: 9, pMaxX: 62, pMinY: 195, pMaxY: 320, zIndex: 4),
    SliceInfo(id: "radius_ulna_l", file: "Bone_younger_boy_radius_ulna_left.png", pMinX: 0, pMaxX: 41, pMinY: 315, pMaxY: 418, zIndex: 5),
    SliceInfo(id: "hands_l", file: "Bone_younger_boy_hands_left.png", pMinX: 0, pMaxX: 38, pMinY: 415, pMaxY: 455, zIndex: 6),
    SliceInfo(id: "humerus_r", file: "Bone_younger_boy_humerus_right.png", pMinX: 206, pMaxX: 258, pMinY: 195, pMaxY: 320, zIndex: 4),
    SliceInfo(id: "radius_ulna_r", file: "Bone_younger_boy_radius_ulna_right.png", pMinX: 226, pMaxX: 267, pMinY: 315, pMaxY: 418, zIndex: 5),
    SliceInfo(id: "hands_r", file: "Bone_younger_boy_hands_right.png", pMinX: 230, pMaxX: 268, pMinY: 415, pMaxY: 457, zIndex: 6),
    SliceInfo(id: "femur_l", file: "Bone_younger_boy_femur_left.png", pMinX: 56, pMaxX: 125, pMinY: 440, pMaxY: 595, zIndex: 2),
    SliceInfo(id: "fibula_tibia_l", file: "Bone_younger_boy_fibula_tibia_left.png", pMinX: 58, pMaxX: 97, pMinY: 590, pMaxY: 730, zIndex: 7),
    SliceInfo(id: "feet_l", file: "Bone_younger_boy_feet_left.png", pMinX: 35, pMaxX: 93, pMinY: 720, pMaxY: 742, zIndex: 8),
    SliceInfo(id: "femur_r", file: "Bone_younger_boy_femur_right.png", pMinX: 144, pMaxX: 210, pMinY: 440, pMaxY: 595, zIndex: 2),
    SliceInfo(id: "fibula_tibia_r", file: "Bone_younger_boy_fibula_tibia_right.png", pMinX: 176, pMaxX: 210, pMinY: 590, pMaxY: 730, zIndex: 7),
    SliceInfo(id: "feet_r", file: "Bone_younger_boy_feet_right.png", pMinX: 179, pMaxX: 238, pMinY: 720, pMaxY: 740, zIndex: 8)
]

for p in pieceDefs {
    let pw = p.pMaxX - p.pMinX + 1
    let ph = p.pMaxY - p.pMinY + 1
    let pieceRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pw, pixelsHigh: ph, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    
    for y in 0..<ph {
        for x in 0..<pw {
            let color = skelRep.colorAt(x: p.pMinX + x, y: p.pMinY + y)!
            pieceRep.setColor(color, atX: x, y: y)
        }
    }
    
    let pngData = pieceRep.representation(using: .png, properties: [:])!
    try! pngData.write(to: URL(fileURLWithPath: "assets/bones/\(p.file)"))
    try! pngData.write(to: URL(fileURLWithPath: "preview/assets/bones/\(p.file)"))
}
print("Successfully extracted all 16 bone PNGs to assets/bones/ and preview/assets/bones/")

// Now let's calculate and print layout entries for preview/index.html and Swift:
print("\n--- JavaScript Layout Table ---")
for p in pieceDefs {
    let pw = Double(p.pMaxX - p.pMinX + 1)
    let ph = Double(p.pMaxY - p.pMinY + 1)
    let cx = Double(p.pMinX + p.pMaxX) / 2.0
    let cy = Double(p.pMinY + p.pMaxY) / 2.0
    
    // Scale relative to character container:
    // Skeleton: top: 5.5%, height: 94.5%, left: 50%, width: 99%
    let charW_pct = (pw / Double(W)) * 99.0
    let charH_pct = (ph / Double(H)) * 94.5
    let charX_pct = (50.0 - 99.0/2.0) + (cx / Double(W)) * 99.0
    let charY_pct = 5.5 + (cy / Double(H)) * 94.5
    
    let baseId = p.id.replacingOccurrences(of: "_l", with: "").replacingOccurrences(of: "_r", with: "")
    print(String(format: "{ id: '%@', file: 'assets/bones/%@', x: %.1f, y: %.1f, w: %.1f, h: %.1f, rot: 0, zIndex: %d },",
        baseId, p.file, charX_pct, charY_pct, charW_pct, charH_pct, p.zIndex))
}

print("\n--- Swift Layout Table ---")
for p in pieceDefs {
    let pw = Double(p.pMaxX - p.pMinX + 1)
    let ph = Double(p.pMaxY - p.pMinY + 1)
    let cx = Double(p.pMinX + p.pMaxX) / 2.0
    let cy = Double(p.pMinY + p.pMaxY) / 2.0
    
    let charW_pct = (pw / Double(W)) * 99.0
    let charH_pct = (ph / Double(H)) * 94.5
    let charX_pct = (50.0 - 99.0/2.0) + (cx / Double(W)) * 99.0
    let charY_pct = 5.5 + (cy / Double(H)) * 94.5
    
    let baseId = p.id.replacingOccurrences(of: "_l", with: "").replacingOccurrences(of: "_r", with: "")
    let swiftImg = p.file.replacingOccurrences(of: ".png", with: "")
    print(String(format: "AnatomicalBonePiece(id: \"%@\", parentBoneId: \"%@\", name: \"%@\", x: %.1f, y: %.1f, width: %.1f, height: %.1f, rotationAngle: 0.0, zIndex: %d, imageName: \"%@\"),",
        p.id, baseId, baseId.capitalized, charX_pct, charY_pct, charW_pct, charH_pct, p.zIndex, swiftImg))
}

