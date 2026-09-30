import AppKit

let url = URL(fileURLWithPath: "scratch/older_boy_skel_perfect.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
let W = rep.pixelsWide // 372
let H = rep.pixelsHigh // 1263

// Save assembled transparent skeleton to assets and preview
let pngData = rep.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "assets/Skeleton_OlderBoy_Assembled.png"))
try! pngData.write(to: URL(fileURLWithPath: "preview/assets/Skeleton_OlderBoy_Assembled.png"))
print("Saved assets/Skeleton_OlderBoy_Assembled.png")

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
    SliceInfo(id: "skull", file: "Bone_older_boy_skull.png", pMinX: 104, pMaxX: 266, pMinY: 0, pMaxY: 195, zIndex: 10),
    SliceInfo(id: "spine", file: "Bone_older_boy_spine.png", pMinX: 125, pMaxX: 195, pMinY: 150, pMaxY: 560, zIndex: 1),
    SliceInfo(id: "ribcage", file: "Bone_older_boy_ribcage.png", pMinX: 45, pMaxX: 275, pMinY: 250, pMaxY: 485, zIndex: 3),
    SliceInfo(id: "pelvis", file: "Bone_older_boy_pelvis.png", pMinX: 60, pMaxX: 285, pMinY: 550, pMaxY: 710, zIndex: 2),
    SliceInfo(id: "humerus_l", file: "Bone_older_boy_humerus_left.png", pMinX: 0, pMaxX: 80, pMinY: 280, pMaxY: 470, zIndex: 4),
    SliceInfo(id: "radius_ulna_l", file: "Bone_older_boy_radius_ulna_left.png", pMinX: 0, pMaxX: 95, pMinY: 460, pMaxY: 630, zIndex: 5),
    SliceInfo(id: "hands_l", file: "Bone_older_boy_hands_left.png", pMinX: 61, pMaxX: 125, pMinY: 620, pMaxY: 740, zIndex: 6),
    SliceInfo(id: "humerus_r", file: "Bone_older_boy_humerus_right.png", pMinX: 250, pMaxX: 291, pMinY: 370, pMaxY: 480, zIndex: 2),
    SliceInfo(id: "radius_ulna_r", file: "Bone_older_boy_radius_ulna_right.png", pMinX: 250, pMaxX: 318, pMinY: 470, pMaxY: 610, zIndex: 2),
    SliceInfo(id: "hands_r", file: "Bone_older_boy_hands_right.png", pMinX: 290, pMaxX: 339, pMinY: 620, pMaxY: 730, zIndex: 6),
    SliceInfo(id: "femur_l", file: "Bone_older_boy_femur_left.png", pMinX: 59, pMaxX: 155, pMinY: 670, pMaxY: 935, zIndex: 4),
    SliceInfo(id: "fibula_tibia_l", file: "Bone_older_boy_fibula_tibia_left.png", pMinX: 55, pMaxX: 142, pMinY: 925, pMaxY: 1195, zIndex: 7),
    SliceInfo(id: "feet_l", file: "Bone_older_boy_feet_left.png", pMinX: 50, pMaxX: 185, pMinY: 1170, pMaxY: 1262, zIndex: 8),
    SliceInfo(id: "femur_r", file: "Bone_older_boy_femur_right.png", pMinX: 190, pMaxX: 290, pMinY: 670, pMaxY: 935, zIndex: 2),
    SliceInfo(id: "fibula_tibia_r", file: "Bone_older_boy_fibula_tibia_right.png", pMinX: 225, pMaxX: 290, pMinY: 925, pMaxY: 1195, zIndex: 6),
    SliceInfo(id: "feet_r", file: "Bone_older_boy_feet_right.png", pMinX: 224, pMaxX: 371, pMinY: 1160, pMaxY: 1240, zIndex: 7)
]

for p in pieceDefs {
    let pw = p.pMaxX - p.pMinX + 1
    let ph = p.pMaxY - p.pMinY + 1
    let pieceRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pw, pixelsHigh: ph, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    
    for y in 0..<ph {
        for x in 0..<pw {
            let color = rep.colorAt(x: p.pMinX + x, y: p.pMinY + y)!
            pieceRep.setColor(color, atX: x, y: y)
        }
    }
    
    let pPng = pieceRep.representation(using: .png, properties: [:])!
    try! pPng.write(to: URL(fileURLWithPath: "assets/bones/\(p.file)"))
    try! pPng.write(to: URL(fileURLWithPath: "preview/assets/bones/\(p.file)"))
}
print("Successfully extracted all 16 bone PNGs for Older Boy!")

// Calculate percentage coordinates relative to Character_OlderBoy_Solo:
// charW = 220, charH = 681
// skelW_pct = 85.70, skelH_pct = 94.0
// skelX_origin_pct = 5.15, skelY_origin_pct = 5.0

print("\n--- JavaScript Layout Table for Older Boy ---")
for p in pieceDefs {
    let pw = Double(p.pMaxX - p.pMinX + 1)
    let ph = Double(p.pMaxY - p.pMinY + 1)
    let cx = Double(p.pMinX + p.pMaxX) / 2.0
    let cy = Double(p.pMinY + p.pMaxY) / 2.0
    
    let charW_pct = (pw / Double(W)) * 85.70
    let charH_pct = (ph / Double(H)) * 94.00
    let charX_pct = 5.15 + (cx / Double(W)) * 85.70
    let charY_pct = 5.00 + (cy / Double(H)) * 94.00
    
    let baseId = p.id.replacingOccurrences(of: "_l", with: "").replacingOccurrences(of: "_r", with: "")
    print(String(format: "{ id: '%@', file: 'assets/bones/%@', x: %.1f, y: %.1f, w: %.1f, h: %.1f, rot: 0, zIndex: %d },",
        baseId, p.file, charX_pct, charY_pct, charW_pct, charH_pct, p.zIndex))
}

print("\n--- Swift Layout Table for Older Boy ---")
for p in pieceDefs {
    let pw = Double(p.pMaxX - p.pMinX + 1)
    let ph = Double(p.pMaxY - p.pMinY + 1)
    let cx = Double(p.pMinX + p.pMaxX) / 2.0
    let cy = Double(p.pMinY + p.pMaxY) / 2.0
    
    let charW_pct = (pw / Double(W)) * 85.70
    let charH_pct = (ph / Double(H)) * 94.00
    let charX_pct = 5.15 + (cx / Double(W)) * 85.70
    let charY_pct = 5.00 + (cy / Double(H)) * 94.00
    
    let baseId = p.id.replacingOccurrences(of: "_l", with: "").replacingOccurrences(of: "_r", with: "")
    let swiftImg = p.file.replacingOccurrences(of: ".png", with: "")
    print(String(format: "AnatomicalBonePiece(id: \"%@\", parentBoneId: \"%@\", name: \"%@\", x: %.1f, y: %.1f, width: %.1f, height: %.1f, rotationAngle: 0.0, zIndex: %d, imageName: \"%@\"),",
        p.id, baseId, baseId.capitalized, charX_pct, charY_pct, charW_pct, charH_pct, p.zIndex, swiftImg))
}

