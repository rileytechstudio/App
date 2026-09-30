import AppKit

let skelUrl = URL(fileURLWithPath: "scratch/new_skel_cropped.png")
guard let skelImg = NSImage(contentsOf: skelUrl),
      let skelRep = NSBitmapImageRep(data: skelImg.tiffRepresentation!) else {
    exit(1)
}

let W = skelRep.pixelsWide // 269
let H = skelRep.pixelsHigh // 743

print("Source cropped skeleton: \(W) x \(H)")

struct SliceDef {
    let id: String
    let file: String
    let minX: Int
    let maxX: Int
    let minY: Int
    let maxY: Int
    let zIndex: Int
}

// In scratch/new_skel_cropped.png (top-left is (0,0)):
// Let's define the bounding box of each piece:
// Note: In CoreGraphics/NSBitmapImageRep top-left (0,0) is y=0.
// Let's inspect the boundaries precisely:

let slices: [SliceDef] = [
    // Skull
    SliceDef(id: "skull", file: "Bone_younger_boy_skull.png", minX: 70, maxX: 198, minY: 0, maxY: 140, zIndex: 10),
    // Cervical + Thoracic + Lumbar Spine (runs down center x: 120..148, y: 135..395)
    SliceDef(id: "spine", file: "Bone_younger_boy_spine.png", minX: 120, maxX: 148, minY: 135, maxY: 395, zIndex: 1),
    // Ribcage (chest ribs + clavicles, x: 38..230, y: 165..335)
    SliceDef(id: "ribcage", file: "Bone_younger_boy_ribcage.png", minX: 38, maxX: 230, minY: 165, maxY: 335, zIndex: 3),
    // Pelvis (x: 52..216, y: 350..470)
    SliceDef(id: "pelvis", file: "Bone_younger_boy_pelvis.png", minX: 52, maxX: 216, minY: 350, maxY: 470, zIndex: 2),

    // Left Arm (viewer left / character right):
    SliceDef(id: "humerus_left", file: "Bone_younger_boy_humerus_left.png", minX: 5, maxX: 62, minY: 195, maxY: 320, zIndex: 4),
    SliceDef(id: "radius_ulna_left", file: "Bone_younger_boy_radius_ulna_left.png", minX: 0, maxX: 42, minY: 315, maxY: 418, zIndex: 5),
    SliceDef(id: "hands_left", file: "Bone_younger_boy_hands_left.png", minX: 0, maxX: 38, minY: 415, maxY: 490, zIndex: 6),

    // Right Arm (viewer right / character left):
    SliceDef(id: "humerus_right", file: "Bone_younger_boy_humerus_right.png", minX: 206, maxX: 264, minY: 195, maxY: 320, zIndex: 4),
    SliceDef(id: "radius_ulna_right", file: "Bone_younger_boy_radius_ulna_right.png", minX: 226, maxX: 268, minY: 315, maxY: 418, zIndex: 5),
    SliceDef(id: "hands_right", file: "Bone_younger_boy_hands_right.png", minX: 230, maxX: 268, minY: 415, maxY: 490, zIndex: 6),

    // Left Leg:
    SliceDef(id: "femur_left", file: "Bone_younger_boy_femur_left.png", minX: 54, maxX: 125, minY: 440, maxY: 595, zIndex: 2),
    SliceDef(id: "fibula_tibia_left", file: "Bone_younger_boy_fibula_tibia_left.png", minX: 58, maxX: 112, minY: 590, maxY: 730, zIndex: 7),
    SliceDef(id: "feet_left", file: "Bone_younger_boy_feet_left.png", minX: 28, maxX: 95, minY: 720, maxY: 742, zIndex: 8),

    // Right Leg:
    SliceDef(id: "femur_right", file: "Bone_younger_boy_femur_right.png", minX: 144, maxX: 215, minY: 440, maxY: 595, zIndex: 2),
    SliceDef(id: "fibula_tibia_right", file: "Bone_younger_boy_fibula_tibia_right.png", minX: 156, maxX: 210, minY: 590, maxY: 730, zIndex: 7),
    SliceDef(id: "feet_right", file: "Bone_younger_boy_feet_right.png", minX: 174, maxX: 240, minY: 720, maxY: 742, zIndex: 8)
]

for s in slices {
    var pMinX = s.maxX, pMaxX = s.minX, pMinY = s.maxY, pMaxY = s.minY
    for y in s.minY...s.maxY {
        for x in s.minX...s.maxX {
            if skelRep.colorAt(x: x, y: y)!.alphaComponent > 0.05 {
                pMinX = min(pMinX, x)
                pMaxX = max(pMaxX, x)
                pMinY = min(pMinY, y)
                pMaxY = max(pMaxY, y)
            }
        }
    }
    if pMinX <= pMaxX && pMinY <= pMaxY {
        let pw = pMaxX - pMinX + 1
        let ph = pMaxY - pMinY + 1
        print(String(format: "%@: x: %d..%d (w:%d), y: %d..%d (h:%d), center: (%.1f, %.1f)",
            s.id, pMinX, pMaxX, pw, pMinY, pMaxY, ph, Double(pMinX + pMaxX)/2.0, Double(pMinY + pMaxY)/2.0))
    } else {
        print("WARNING: No pixels found for \(s.id)")
    }
}
