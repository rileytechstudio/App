import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let imgSolo = NSImage(contentsOf: urlSolo)!
let repSolo = NSBitmapImageRep(data: imgSolo.tiffRepresentation!)!
let charW = Double(repSolo.pixelsWide) // 220
let charH = Double(repSolo.pixelsHigh) // 681

func getCleanPixel(x: Int, y: Int) -> NSColor? {
    guard x >= 0 && x < repSkel.pixelsWide && y >= 0 && y < repSkel.pixelsHigh else { return nil }
    let c = repSkel.colorAt(x: x, y: y)!
    let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
    if r > 0.78 && g > 0.78 && b > 0.78 { return c }
    if b > 0.38 && g > 0.32 && g > r + 0.03 { return c }
    if x >= 810 && x <= 865 && y >= 440 && y <= 515 && r < 0.25 && g < 0.25 && b < 0.35 { return c }
    return nil
}

struct SliceDef {
    let id: String
    let file: String
    let zIndex: Int
    let minX: Int
    let maxX: Int
    let minY: Int
    let maxY: Int
    let predicate: ((Int, Int) -> Bool)?
}

let sliceDefs: [SliceDef] = [
    // 1. Skull
    SliceDef(id: "skull", file: "whole_Bone_older_boy_skull.png", zIndex: 10,
             minX: 700, maxX: 863, minY: 372, maxY: 536,
             predicate: { x, y in !(x < 745 && y > 515) }),
    
    // 2. Spine
    SliceDef(id: "spine", file: "whole_Bone_older_boy_spine.png", zIndex: 1,
             minX: 720, maxX: 785, minY: 535, maxY: 945,
             predicate: { x, y in y <= 640 ? (x >= 720 && x <= 775) : (x >= 735 && x <= 785) }),
    
    // 3. Ribcage
    SliceDef(id: "ribcage", file: "whole_Bone_older_boy_ribcage.png", zIndex: 3,
             minX: 635, maxX: 870, minY: 625, maxY: 865,
             predicate: { x, y in !(x < 650 && y >= 670) }),
    
    // 4. Pelvis
    SliceDef(id: "pelvis", file: "whole_Bone_older_boy_pelvis.png", zIndex: 2,
             minX: 655, maxX: 875, minY: 935, maxY: 1080,
             predicate: nil),
    
    // 5. Left Arm (Front):
    SliceDef(id: "humerus_l", file: "whole_Bone_older_boy_humerus_left.png", zIndex: 4,
             minX: 596, maxX: 675, minY: 645, maxY: 810,
             predicate: { x, y in !(y < 655 && x > 645) }),
    SliceDef(id: "radius_ulna_l", file: "whole_Bone_older_boy_radius_ulna_left.png", zIndex: 5,
             minX: 596, maxX: 690, minY: 800, maxY: 970,
             predicate: nil),
    SliceDef(id: "hands_l", file: "whole_Bone_older_boy_hands_left.png", zIndex: 6,
             minX: 655, maxX: 720, minY: 965, maxY: 1075,
             predicate: nil),
    
    // 6. Right Arm (Back):
    SliceDef(id: "humerus_r", file: "whole_Bone_older_boy_humerus_right.png", zIndex: 2,
             minX: 845, maxX: 885, minY: 725, maxY: 840,
             predicate: nil),
    SliceDef(id: "radius_ulna_r", file: "whole_Bone_older_boy_radius_ulna_right.png", zIndex: 2,
             minX: 845, maxX: 915, minY: 830, maxY: 965,
             predicate: nil),
    SliceDef(id: "hands_r", file: "whole_Bone_older_boy_hands_right.png", zIndex: 6,
             minX: 885, maxX: 935, minY: 965, maxY: 1065,
             predicate: nil),
    
    // 7. Left Leg (Front):
    SliceDef(id: "femur_l", file: "whole_Bone_older_boy_femur_left.png", zIndex: 4,
             minX: 655, maxX: 755, minY: 1040, maxY: 1315,
             predicate: nil),
    SliceDef(id: "fibula_tibia_l", file: "whole_Bone_older_boy_fibula_tibia_left.png", zIndex: 7,
             minX: 650, maxX: 735, minY: 1300, maxY: 1565,
             predicate: nil),
    SliceDef(id: "feet_l", file: "whole_Bone_older_boy_feet_left.png", zIndex: 8,
             minX: 645, maxX: 780, minY: 1545, maxY: 1633,
             predicate: nil),
    
    // 8. Right Leg (Back):
    SliceDef(id: "femur_r", file: "whole_Bone_older_boy_femur_right.png", zIndex: 2,
             minX: 785, maxX: 885, minY: 1040, maxY: 1315,
             predicate: nil),
    SliceDef(id: "fibula_tibia_r", file: "whole_Bone_older_boy_fibula_tibia_right.png", zIndex: 6,
             minX: 820, maxX: 885, minY: 1300, maxY: 1565,
             predicate: nil),
    SliceDef(id: "feet_r", file: "whole_Bone_older_boy_feet_right.png", zIndex: 7,
             minX: 820, maxX: 967, minY: 1540, maxY: 1610,
             predicate: nil)
]

struct ComputedItem {
    let id: String
    let zIndex: Int
    let img: NSImage
    let cx: Double
    let cy: Double
    let w: Double
    let h: Double
}

var computedItems: [ComputedItem] = []

// Skeleton bounds on Character_OlderBoy_Solo.png:
let skelMinX = 4.85
let skelMinY = 12.79
let skelW = 192.5
let skelH = 661.8

// Source skeleton bounds in Older Boy Skeleton.png:
let srcSkelMinX = 596.0
let srcSkelMinY = 371.0
let srcSkelW = 414.0
let srcSkelH = 1262.0

for def in sliceDefs {
    // 1. Crop to tight bbox of non-empty pixels:
    var bMinX = def.maxX, bMaxX = def.minX, bMinY = def.maxY, bMaxY = def.minY
    for y in def.minY...def.maxY {
        for x in def.minX...def.maxX {
            if let p = def.predicate, !p(x, y) { continue }
            if getCleanPixel(x: x, y: y) != nil {
                bMinX = min(bMinX, x)
                bMaxX = max(bMaxX, x)
                bMinY = min(bMinY, y)
                bMaxY = max(bMaxY, y)
            }
        }
    }
    
    let pw = max(1, bMaxX - bMinX + 1)
    let ph = max(1, bMaxY - bMinY + 1)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pw, pixelsHigh: ph, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    
    for y in 0..<ph {
        for x in 0..<pw {
            let sx = bMinX + x
            let sy = bMinY + y
            if let p = def.predicate, !p(sx, sy) {
                rep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
                continue
            }
            if let color = getCleanPixel(x: sx, y: sy) {
                rep.setColor(color, atX: x, y: y)
            } else {
                rep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
            }
        }
    }
    let data = rep.representation(using: .png, properties: [:])!
    let img = NSImage(data: data)!
    
    // 2. Compute exact character coordinates:
    let charLeft = skelMinX + Double(bMinX - Int(srcSkelMinX)) / srcSkelW * skelW
    let charTop = skelMinY + Double(bMinY - Int(srcSkelMinY)) / srcSkelH * skelH
    let charWidth = Double(pw) / srcSkelW * skelW
    let charHeight = Double(ph) / srcSkelH * skelH
    
    let cx = (charLeft + charWidth / 2.0) / charW * 100.0
    let cy = (charTop + charHeight / 2.0) / charH * 100.0
    let w = charWidth / charW * 100.0
    let h = charHeight / charH * 100.0
    
    print(String(format: "%-16@: x: %5.1f%%, y: %5.1f%%, w: %5.1f%%, h: %5.1f%%, zIndex: %d", def.id, cx, cy, w, h, def.zIndex))
    
    computedItems.append(ComputedItem(id: def.id, zIndex: def.zIndex, img: img, cx: cx, cy: cy, w: w, h: h))
}

let sortedItems = computedItems.sorted { $0.zIndex < $1.zIndex }

let canvas = NSImage(size: NSSize(width: charW, height: charH))
canvas.lockFocus()

imgSolo.draw(in: NSRect(x: 0, y: 0, width: charW, height: charH))

for it in sortedItems {
    let destW = it.w / 100.0 * charW
    let destH = it.h / 100.0 * charH
    let destX = (it.cx / 100.0 * charW) - (destW / 2.0)
    let screenY = (it.cy / 100.0 * charH) - (destH / 2.0)
    let cocoaY = charH - screenY - destH
    
    it.img.draw(in: NSRect(x: destX, y: cocoaY, width: destW, height: destH),
               from: NSRect.zero,
               operation: .sourceOver,
               fraction: 1.0)
}

canvas.unlockFocus()

let outRep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
let outPng = outRep.representation(using: .png, properties: [:])!
try! outPng.write(to: URL(fileURLWithPath: "scratch/mathematical_reassembly.png"))
print("Saved scratch/mathematical_reassembly.png")
