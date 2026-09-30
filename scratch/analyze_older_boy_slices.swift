import AppKit

let url = URL(fileURLWithPath: "scratch/older_boy_skel_perfect.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
let W = rep.pixelsWide // 372
let H = rep.pixelsHigh // 1263

print("Older boy skeleton: \(W) x \(H)")

struct SliceBox {
    let id: String
    let file: String
    let minX: Int
    let maxX: Int
    let minY: Int
    let maxY: Int
    let zIndex: Int
}

// In scratch/older_boy_skel_perfect.png (top-left is (0,0)):
// 1. Skull: top of head y: 0 to chin/jaw y: 195, x: 100 to 270
// 2. Spine: cervical + thoracic + lumbar spine runs down center/back from y: 150 to 570
// 3. Ribcage: 3/4 profile ribcage from y: 250 to 480, x: 60 to 280
// 4. Pelvis: 3/4 profile pelvis from y: 550 to 710, x: 60 to 285
// 5. Left Arm (front, viewer left):
//    - Humerus: y: 280 to 470, x: 0 to 80
//    - Forearm (radius/ulna): y: 460 to 630, x: 0 to 90
//    - Hand: y: 620 to 740, x: 50 to 125
// 6. Right Arm (back, viewer right):
//    - Humerus: mostly hidden behind torso, top touches shoulder
//    - Forearm: y: 470 to 600, x: 250 to 320
//    - Hand: y: 620 to 730, x: 290 to 340
// 7. Left Leg (front, viewer left):
//    - Femur: y: 670 to 930, x: 50 to 145
//    - Tibia: y: 920 to 1190, x: 50 to 140
//    - Foot: y: 1170 to 1262, x: 20 to 180
// 8. Right Leg (back, viewer right):
//    - Femur: y: 670 to 930, x: 190 to 285
//    - Tibia: y: 920 to 1190, x: 200 to 285
//    - Foot: y: 1160 to 1255, x: 220 to 371

let boxes: [SliceBox] = [
    SliceBox(id: "skull", file: "Bone_older_boy_skull.png", minX: 100, maxX: 270, minY: 0, maxY: 195, zIndex: 10),
    SliceBox(id: "spine", file: "Bone_older_boy_spine.png", minX: 125, maxX: 195, minY: 150, maxY: 560, zIndex: 1),
    SliceBox(id: "ribcage", file: "Bone_older_boy_ribcage.png", minX: 45, maxX: 275, minY: 250, maxY: 485, zIndex: 3),
    SliceBox(id: "pelvis", file: "Bone_older_boy_pelvis.png", minX: 60, maxX: 285, minY: 550, maxY: 710, zIndex: 2),
    
    // Front Arm (viewer left):
    SliceBox(id: "humerus_l", file: "Bone_older_boy_humerus_left.png", minX: 0, maxX: 80, minY: 280, maxY: 470, zIndex: 4),
    SliceBox(id: "radius_ulna_l", file: "Bone_older_boy_radius_ulna_left.png", minX: 0, maxX: 95, minY: 460, maxY: 630, zIndex: 5),
    SliceBox(id: "hands_l", file: "Bone_older_boy_hands_left.png", minX: 60, maxX: 125, minY: 620, maxY: 740, zIndex: 6),
    
    // Back Arm (viewer right):
    SliceBox(id: "humerus_r", file: "Bone_older_boy_humerus_right.png", minX: 250, maxX: 310, minY: 370, maxY: 480, zIndex: 2),
    SliceBox(id: "radius_ulna_r", file: "Bone_older_boy_radius_ulna_right.png", minX: 250, maxX: 320, minY: 470, maxY: 610, zIndex: 2),
    SliceBox(id: "hands_r", file: "Bone_older_boy_hands_right.png", minX: 290, maxX: 340, minY: 620, maxY: 730, zIndex: 6),
    
    // Front Leg (viewer left):
    SliceBox(id: "femur_l", file: "Bone_older_boy_femur_left.png", minX: 50, maxX: 155, minY: 670, maxY: 935, zIndex: 4),
    SliceBox(id: "fibula_tibia_l", file: "Bone_older_boy_fibula_tibia_left.png", minX: 50, maxX: 145, minY: 925, maxY: 1195, zIndex: 7),
    SliceBox(id: "feet_l", file: "Bone_older_boy_feet_left.png", minX: 20, maxX: 185, minY: 1170, maxY: 1262, zIndex: 8),
    
    // Back Leg (viewer right):
    SliceBox(id: "femur_r", file: "Bone_older_boy_femur_right.png", minX: 190, maxX: 290, minY: 670, maxY: 935, zIndex: 2),
    SliceBox(id: "fibula_tibia_r", file: "Bone_older_boy_fibula_tibia_right.png", minX: 200, maxX: 290, minY: 925, maxY: 1195, zIndex: 6),
    SliceBox(id: "feet_r", file: "Bone_older_boy_feet_right.png", minX: 220, maxX: 371, minY: 1160, maxY: 1255, zIndex: 7)
]

for b in boxes {
    var pMinX = b.maxX, pMaxX = b.minX, pMinY = b.maxY, pMaxY = b.minY
    for y in b.minY...b.maxY {
        for x in b.minX...b.maxX {
            if rep.colorAt(x: x, y: y)!.alphaComponent > 0.05 {
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
            b.id, pMinX, pMaxX, pw, pMinY, pMaxY, ph, Double(pMinX + pMaxX)/2.0, Double(pMinY + pMaxY)/2.0))
    } else {
        print("WARNING: No pixels found for \(b.id)")
    }
}
