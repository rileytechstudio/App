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

let items: [LayoutItem] = [
    // 1. Spine (zIndex: 1)
    LayoutItem(id: "spine", file: "scratch/whole_Bone_older_boy_spine.png", cx: 43.0, cy: 30.5, w: 16.1, h: 32.3, zIndex: 1),
    // 2. Pelvis (zIndex: 2)
    LayoutItem(id: "pelvis", file: "scratch/whole_Bone_older_boy_pelvis.png", cx: 48.5, cy: 47.5, w: 52.0, h: 11.1, zIndex: 2),
    // 3. Back Arm (Right) (zIndex: 2)
    LayoutItem(id: "humerus_r", file: "scratch/whole_Bone_older_boy_humerus_right.png", cx: 71.0, cy: 30.8, w: 11.5, h: 10.5, zIndex: 2),
    LayoutItem(id: "radius_ulna_r", file: "scratch/whole_Bone_older_boy_radius_ulna_right.png", cx: 74.5, cy: 41.2, w: 17.3, h: 11.5, zIndex: 2),
    LayoutItem(id: "hands_r", file: "scratch/whole_Bone_older_boy_hands_right.png", cx: 82.0, cy: 51.2, w: 13.0, h: 8.5, zIndex: 6),
    // 4. Back Leg (Right) (zIndex: 2)
    LayoutItem(id: "femur_r", file: "scratch/whole_Bone_older_boy_femur_right.png", cx: 66.0, cy: 63.3, w: 26.6, h: 23.5, zIndex: 2),
    LayoutItem(id: "fibula_tibia_r", file: "scratch/whole_Bone_older_boy_fibula_tibia_right.png", cx: 68.0, cy: 83.8, w: 14.0, h: 18.5, zIndex: 6),
    LayoutItem(id: "feet_r", file: "scratch/whole_Bone_older_boy_feet_right.png", cx: 75.5, cy: 94.5, w: 38.8, h: 6.0, zIndex: 7),
    // 5. Ribcage (zIndex: 3)
    LayoutItem(id: "ribcage", file: "scratch/whole_Bone_older_boy_ribcage.png", cx: 44.0, cy: 28.0, w: 51.0, h: 17.2, zIndex: 3),
    // 6. Skull (zIndex: 10)
    LayoutItem(id: "skull", file: "scratch/whole_Bone_older_boy_skull.png", cx: 48.0, cy: 8.5, w: 38.0, h: 12.4, zIndex: 10),
    // 7. Front Arm (Left) (zIndex: 4)
    LayoutItem(id: "humerus_l", file: "scratch/whole_Bone_older_boy_humerus_left.png", cx: 16.0, cy: 28.5, w: 17.2, h: 14.0, zIndex: 4),
    LayoutItem(id: "radius_ulna_l", file: "scratch/whole_Bone_older_boy_radius_ulna_left.png", cx: 15.5, cy: 41.2, w: 21.5, h: 12.5, zIndex: 5),
    LayoutItem(id: "hands_l", file: "scratch/clean_Bone_older_boy_hands_left.png", cx: 30.0, cy: 51.2, w: 15.6, h: 8.5, zIndex: 6),
    // 8. Front Leg (Left) (zIndex: 4)
    LayoutItem(id: "femur_l", file: "scratch/whole_Bone_older_boy_femur_left.png", cx: 34.0, cy: 63.3, w: 26.6, h: 23.5, zIndex: 4),
    LayoutItem(id: "fibula_tibia_l", file: "scratch/whole_Bone_older_boy_fibula_tibia_left.png", cx: 30.0, cy: 83.8, w: 18.5, h: 18.5, zIndex: 7),
    LayoutItem(id: "feet_l", file: "scratch/whole_Bone_older_boy_feet_left.png", cx: 36.0, cy: 95.9, w: 31.9, h: 6.8, zIndex: 8)
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
try! outPng.write(to: URL(fileURLWithPath: "scratch/whole_test_result.png"))
print("Saved scratch/whole_test_result.png")

