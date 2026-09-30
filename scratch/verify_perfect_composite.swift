import AppKit

let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let imgSolo = NSImage(contentsOf: urlSolo)!
let repSolo = NSBitmapImageRep(data: imgSolo.tiffRepresentation!)!
let charW = Double(repSolo.pixelsWide) // 220
let charH = Double(repSolo.pixelsHigh) // 681

struct LayoutItem {
    let id: String
    let file: String
    let cx: Double
    let cy: Double
    let w: Double
    let h: Double
    let zIndex: Int
}

// Exact calibrated coordinates matching Screenshot 2026-09-29 at 9.22.14 AM.png:
let items: [LayoutItem] = [
    // 1. Spine: runs from base of skull through ribcage to pelvis
    LayoutItem(id: "spine", file: "scratch/perfect_Bone_older_boy_spine.png", cx: 43.1, cy: 28.4, w: 16.0, h: 31.0, zIndex: 1),
    
    // 2. Pelvis: hips and lower abdomen
    LayoutItem(id: "pelvis", file: "scratch/perfect_Bone_older_boy_pelvis.png", cx: 49.3, cy: 47.4, w: 52.9, h: 12.0, zIndex: 2),
    
    // 3. Back Arm (Right):
    LayoutItem(id: "humerus_r", file: "scratch/perfect_Bone_older_boy_humerus_right.png", cx: 72.1, cy: 30.9, w: 10.1, h: 10.3, zIndex: 2),
    LayoutItem(id: "radius_ulna_r", file: "scratch/perfect_Bone_older_boy_radius_ulna_right.png", cx: 75.4, cy: 41.2, w: 12.3, h: 12.2, zIndex: 2),
    LayoutItem(id: "hands_r", file: "scratch/perfect_Bone_older_boy_hands_right.png", cx: 85.5, cy: 51.1, w: 12.3, h: 8.5, zIndex: 6),
    
    // 4. Back Leg (Right):
    LayoutItem(id: "femur_r", file: "scratch/perfect_Bone_older_boy_femur_right.png", cx: 65.9, cy: 63.4, w: 22.5, h: 23.7, zIndex: 2),
    LayoutItem(id: "fibula_tibia_r", file: "scratch/perfect_Bone_older_boy_fibula_tibia_right.png", cx: 68.1, cy: 83.9, w: 16.7, h: 18.8, zIndex: 6),
    LayoutItem(id: "feet_r", file: "scratch/perfect_Bone_older_boy_feet_right.png", cx: 75.4, cy: 94.6, w: 32.6, h: 6.3, zIndex: 7),
    
    // 5. Ribcage: fills chest, collarbones at shoulders
    LayoutItem(id: "ribcage", file: "scratch/perfect_Bone_older_boy_ribcage.png", cx: 44.2, cy: 27.5, w: 51.4, h: 17.1, zIndex: 3),
    
    // 6. Skull: centered in head, jaw above chin, solid eye & nose
    LayoutItem(id: "skull", file: "scratch/perfect_Bone_older_boy_skull.png", cx: 47.1, cy: 7.6, w: 38.4, h: 11.7, zIndex: 10),
    
    // 7. Front Arm (Left):
    LayoutItem(id: "humerus_l", file: "scratch/perfect_Bone_older_boy_humerus_left.png", cx: 15.6, cy: 28.3, w: 17.4, h: 14.1, zIndex: 4),
    LayoutItem(id: "radius_ulna_l", file: "scratch/perfect_Bone_older_boy_radius_ulna_left.png", cx: 15.2, cy: 41.2, w: 25.4, h: 13.1, zIndex: 5),
    LayoutItem(id: "hands_l", file: "scratch/perfect_Bone_older_boy_hands_left.png", cx: 31.2, cy: 51.2, w: 16.7, h: 9.2, zIndex: 6),
    
    // 8. Front Leg (Left):
    LayoutItem(id: "femur_l", file: "scratch/perfect_Bone_older_boy_femur_left.png", cx: 34.1, cy: 63.4, w: 23.9, h: 23.7, zIndex: 4),
    LayoutItem(id: "fibula_tibia_l", file: "scratch/perfect_Bone_older_boy_fibula_tibia_left.png", cx: 30.1, cy: 83.8, w: 17.4, h: 18.5, zIndex: 7),
    LayoutItem(id: "feet_l", file: "scratch/perfect_Bone_older_boy_feet_left.png", cx: 36.2, cy: 95.9, w: 29.7, h: 7.0, zIndex: 8)
]

let sortedItems = items.sorted { $0.zIndex < $1.zIndex }

let canvas = NSImage(size: NSSize(width: charW, height: charH))
canvas.lockFocus()

imgSolo.draw(in: NSRect(x: 0, y: 0, width: charW, height: charH))

for it in sortedItems {
    guard let pImg = NSImage(contentsOf: URL(fileURLWithPath: it.file)) else {
        print("Missing file: \(it.file)")
        continue
    }
    let destW = it.w / 100.0 * charW
    let destH = it.h / 100.0 * charH
    let destX = (it.cx / 100.0 * charW) - (destW / 2.0)
    let screenY = (it.cy / 100.0 * charH) - (destH / 2.0)
    let cocoaY = charH - screenY - destH
    
    pImg.draw(in: NSRect(x: destX, y: cocoaY, width: destW, height: destH),
              from: NSRect.zero,
              operation: .sourceOver,
              fraction: 1.0)
}

canvas.unlockFocus()

let outRep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
let outPng = outRep.representation(using: .png, properties: [:])!
try! outPng.write(to: URL(fileURLWithPath: "scratch/perfect_composite_result.png"))
print("Saved scratch/perfect_composite_result.png")

