import AppKit

// Load screenshot bone mask (274 x 469)
let maskUrl = URL(fileURLWithPath: "scratch/screenshot_bone_mask.png")
let maskRep = NSBitmapImageRep(data: NSImage(contentsOf: maskUrl)!.tiffRepresentation!)!

// Silhouette in screenshot: x: 42..179 (w: 138), y: 25..450 (h: 426)
let silX = 42.0
let silY = 25.0
let silW = 138.0
let silH = 426.0

// Target solo character: 220 x 681
let targetW = 220.0
let targetH = 681.0

struct PieceRange {
    let id: String
    let file: String
    let minX: Int
    let maxX: Int
    let minY: Int
    let maxY: Int
    let zIndex: Int
    let exclude: ((Int, Int) -> Bool)?
}

let pieces: [PieceRange] = [
    // 1. Skull: y: 33..82, x: 80..135
    PieceRange(id: "skull", file: "Bone_older_boy_skull.png", minX: 80, maxX: 135, minY: 33, maxY: 82, zIndex: 10, exclude: nil),
    
    // 2. Spine: y: 80..212, x: 88..115
    PieceRange(id: "spine", file: "Bone_older_boy_spine.png", minX: 88, maxX: 115, minY: 80, maxY: 212, zIndex: 1, exclude: nil),
    
    // 3. Ribcage: y: 106..178, x: 68..140
    PieceRange(id: "ribcage", file: "Bone_older_boy_ribcage.png", minX: 68, maxX: 140, minY: 106, maxY: 178, zIndex: 3, exclude: nil),
    
    // 4. Pelvis: y: 202..252, x: 74..146
    PieceRange(id: "pelvis", file: "Bone_older_boy_pelvis.png", minX: 74, maxX: 146, minY: 202, maxY: 252, zIndex: 2, exclude: nil),
    
    // 5. Left Arm (front):
    PieceRange(id: "humerus_l", file: "Bone_older_boy_humerus_left.png", minX: 46, maxX: 75, minY: 114, maxY: 175, zIndex: 4, exclude: nil),
    PieceRange(id: "radius_ulna_l", file: "Bone_older_boy_radius_ulna_left.png", minX: 46, maxX: 80, minY: 173, maxY: 228, zIndex: 5, exclude: nil),
    PieceRange(id: "hands_l", file: "Bone_older_boy_hands_left.png", minX: 74, maxX: 96, minY: 224, maxY: 262, zIndex: 6, exclude: nil),
    
    // 6. Right Arm (back):
    PieceRange(id: "humerus_r", file: "Bone_older_boy_humerus_right.png", minX: 135, maxX: 152, minY: 135, maxY: 178, zIndex: 2, exclude: nil),
    PieceRange(id: "radius_ulna_r", file: "Bone_older_boy_radius_ulna_right.png", minX: 138, maxX: 158, minY: 175, maxY: 226, zIndex: 2, exclude: nil),
    PieceRange(id: "hands_r", file: "Bone_older_boy_hands_right.png", minX: 152, maxX: 168, minY: 225, maxY: 260, zIndex: 6, exclude: nil),
    
    // 7. Left Leg (front):
    PieceRange(id: "femur_l", file: "Bone_older_boy_femur_left.png", minX: 73, maxX: 105, minY: 245, maxY: 345, zIndex: 4, exclude: nil),
    PieceRange(id: "fibula_tibia_l", file: "Bone_older_boy_fibula_tibia_left.png", minX: 72, maxX: 95, minY: 343, maxY: 421, zIndex: 7, exclude: nil),
    PieceRange(id: "feet_l", file: "Bone_older_boy_feet_left.png", minX: 72, maxX: 112, minY: 419, maxY: 448, zIndex: 8, exclude: nil),
    
    // 8. Right Leg (back):
    PieceRange(id: "femur_r", file: "Bone_older_boy_femur_right.png", minX: 118, maxX: 148, minY: 245, maxY: 345, zIndex: 2, exclude: nil),
    PieceRange(id: "fibula_tibia_r", file: "Bone_older_boy_fibula_tibia_right.png", minX: 125, maxX: 147, minY: 343, maxY: 422, zIndex: 6, exclude: nil),
    PieceRange(id: "feet_r", file: "Bone_older_boy_feet_right.png", minX: 124, maxX: 168, minY: 415, maxY: 441, zIndex: 7, exclude: nil)
]

print("Calculating exact bounds from screenshot mask...")
for p in pieces {
    var bMinX = p.maxX, bMaxX = p.minX, bMinY = p.maxY, bMaxY = p.minY
    for y in p.minY...p.maxY {
        for x in p.minX...p.maxX {
            if let ex = p.exclude, ex(x, y) { continue }
            if maskRep.colorAt(x: x, y: y)!.alphaComponent > 0.3 {
                bMinX = min(bMinX, x)
                bMaxX = max(bMaxX, x)
                bMinY = min(bMinY, y)
                bMaxY = max(bMaxY, y)
            }
        }
    }
    
    let pw = Double(bMaxX - bMinX + 1)
    let ph = Double(bMaxY - bMinY + 1)
    let pcx = Double(bMinX) + pw / 2.0
    let pcy = Double(bMinY) + ph / 2.0
    
    // Percentages of character container (0..100)
    let relCx = (pcx - silX) / silW * 100.0
    let relCy = (pcy - silY) / silH * 100.0
    let relW = pw / silW * 100.0
    let relH = ph / silH * 100.0
    
    let baseId = p.id.replacingOccurrences(of: "_l", with: "").replacingOccurrences(of: "_r", with: "")
    print(String(format: "{ id: '%@', file: 'assets/bones/%@', x: %.1f, y: %.1f, w: %.1f, h: %.1f, rot: 0, zIndex: %d }, // box: %d..%d, %d..%d",
        baseId, p.file, relCx, relCy, relW, relH, p.zIndex, bMinX, bMaxX, bMinY, bMaxY))
}

