import AppKit

let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let imgSolo = NSImage(contentsOf: urlSolo)!
let repSolo = NSBitmapImageRep(data: imgSolo.tiffRepresentation!)!
let charW = Double(repSolo.pixelsWide) // 220
let charH = Double(repSolo.pixelsHigh) // 681

// Source skeleton bounds in Older Boy Skeleton.png:
let srcSkelMinX = 596.0
let srcSkelMinY = 371.0
let srcSkelW = 414.0
let srcSkelH = 1262.0

// Placement on Character_OlderBoy_Solo.png:
let skelMinX = 4.85
let skelMinY = 12.79
let skelW = 192.5
let skelH = 661.8

struct BoneItemConfig {
    let id: String
    let filename: String
    let zIndex: Int
    let srcX: Double
    let srcY: Double
    let srcW: Double
    let srcH: Double
    let dx: Double
    let dy: Double
}

// Data from extract_all_unmatted:
let items: [BoneItemConfig] = [
    // zIndex: 1
    BoneItemConfig(id: "spine", filename: "scratch/unmatted_Bone_older_boy_spine.png", zIndex: 1,
                   srcX: 720, srcY: 535, srcW: 66, srcH: 411, dx: 0, dy: 0),
    
    // zIndex: 2
    BoneItemConfig(id: "pelvis", filename: "scratch/unmatted_Bone_older_boy_pelvis.png", zIndex: 2,
                   srcX: 671, srcY: 920, srcW: 210, srcH: 201, dx: 0, dy: 0),
    BoneItemConfig(id: "humerus", filename: "scratch/unmatted_Bone_older_boy_humerus_right.png", zIndex: 2,
                   srcX: 845, srcY: 725, srcW: 41, srcH: 116, dx: 0, dy: 0),
    BoneItemConfig(id: "radius_ulna", filename: "scratch/unmatted_Bone_older_boy_radius_ulna_right.png", zIndex: 2,
                   srcX: 845, srcY: 830, srcW: 70, srcH: 151, dx: 0, dy: 0),
    BoneItemConfig(id: "femur", filename: "scratch/unmatted_Bone_older_boy_femur_right.png", zIndex: 2,
                   srcX: 785, srcY: 1040, srcW: 101, srcH: 276, dx: 0, dy: 0),
    
    // zIndex: 3
    BoneItemConfig(id: "ribcage", filename: "scratch/unmatted_Bone_older_boy_ribcage.png", zIndex: 3,
                   srcX: 635, srcY: 625, srcW: 241, srcH: 241, dx: 0, dy: 0),
    
    // zIndex: 4
    BoneItemConfig(id: "humerus", filename: "scratch/unmatted_Bone_older_boy_humerus_left.png", zIndex: 4,
                   srcX: 610, srcY: 645, srcW: 66, srcH: 166, dx: 0, dy: 0),
    BoneItemConfig(id: "femur", filename: "scratch/unmatted_Bone_older_boy_femur_left.png", zIndex: 4,
                   srcX: 655, srcY: 1040, srcW: 106, srcH: 276, dx: 0, dy: 0),
    
    // zIndex: 5
    BoneItemConfig(id: "radius_ulna", filename: "scratch/unmatted_Bone_older_boy_radius_ulna_left.png", zIndex: 5,
                   srcX: 596, srcY: 800, srcW: 95, srcH: 171, dx: 0, dy: 0),
    
    // zIndex: 6
    BoneItemConfig(id: "hands", filename: "scratch/unmatted_Bone_older_boy_hands_left.png", zIndex: 6,
                   srcX: 655, srcY: 965, srcW: 66, srcH: 111, dx: 0, dy: 0),
    BoneItemConfig(id: "hands", filename: "scratch/unmatted_Bone_older_boy_hands_right.png", zIndex: 6,
                   srcX: 885, srcY: 980, srcW: 52, srcH: 96, dx: 0, dy: 0),
    BoneItemConfig(id: "fibula_tibia", filename: "scratch/unmatted_Bone_older_boy_fibula_tibia_right.png", zIndex: 6,
                   srcX: 820, srcY: 1300, srcW: 66, srcH: 266, dx: 0, dy: 0),
    
    // zIndex: 7
    BoneItemConfig(id: "fibula_tibia", filename: "scratch/unmatted_Bone_older_boy_fibula_tibia_left.png", zIndex: 7,
                   srcX: 651, srcY: 1303, srcW: 85, srcH: 263, dx: 0, dy: 0),
    BoneItemConfig(id: "feet", filename: "scratch/unmatted_Bone_older_boy_feet_right.png", zIndex: 7,
                   srcX: 820, srcY: 1540, srcW: 148, srcH: 71, dx: 0, dy: 0),
    
    // zIndex: 8
    BoneItemConfig(id: "feet", filename: "scratch/unmatted_Bone_older_boy_feet_left.png", zIndex: 8,
                   srcX: 646, srcY: 1545, srcW: 135, srcH: 89, dx: 0, dy: 0),
    
    // zIndex: 10
    // Skull shifted by +10.5 px in X to center inside the head profile!
    BoneItemConfig(id: "skull", filename: "scratch/unmatted_Bone_older_boy_skull.png", zIndex: 10,
                   srcX: 700, srcY: 372, srcW: 164, srcH: 165, dx: 10.5, dy: 0)
]

print("// Computed CSS Layout Configurations for preview/index.html & Swift:")
for it in items {
    let charLeft = skelMinX + (it.srcX - srcSkelMinX) / srcSkelW * skelW + it.dx
    let charTop = skelMinY + (it.srcY - srcSkelMinY) / srcSkelH * skelH + it.dy
    let charWidth = it.srcW / srcSkelW * skelW
    let charHeight = it.srcH / srcSkelH * skelH
    
    let cx = (charLeft + charWidth / 2.0) / charW * 100.0
    let cy = (charTop + charHeight / 2.0) / charH * 100.0
    let w = charWidth / charW * 100.0
    let h = charHeight / charH * 100.0
    
    let baseFilename = URL(fileURLWithPath: it.filename).lastPathComponent.replacingOccurrences(of: "unmatted_", with: "")
    print(String(format: "  { id: '%@', file: 'assets/bones/%@', x: %4.1f, y: %4.1f, w: %4.1f, h: %4.1f, rot: 0, zIndex: %d },",
                 it.id, baseFilename, cx, cy, w, h, it.zIndex))
}

// 1. Render assembled skeleton onto character:
let canvasOnChar = NSImage(size: NSSize(width: charW, height: charH))
canvasOnChar.lockFocus()
imgSolo.draw(in: NSRect(x: 0, y: 0, width: charW, height: charH))

// 2. Also render transparent assembled skeleton:
let canvasTransparent = NSImage(size: NSSize(width: charW, height: charH))
canvasTransparent.lockFocus()

let sortedItems = items.sorted { $0.zIndex < $1.zIndex }

for it in sortedItems {
    guard let img = NSImage(contentsOf: URL(fileURLWithPath: it.filename)) else {
        print("Missing: \(it.filename)")
        continue
    }
    let charLeft = skelMinX + (it.srcX - srcSkelMinX) / srcSkelW * skelW + it.dx
    let charTop = skelMinY + (it.srcY - srcSkelMinY) / srcSkelH * skelH + it.dy
    let charWidth = it.srcW / srcSkelW * skelW
    let charHeight = it.srcH / srcSkelH * skelH
    let cocoaY = charH - charTop - charHeight
    
    let r = NSRect(x: charLeft, y: cocoaY, width: charWidth, height: charHeight)
    img.draw(in: r, from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
}

canvasOnChar.unlockFocus()

// Draw same pieces onto canvasTransparent:
for it in sortedItems {
    guard let img = NSImage(contentsOf: URL(fileURLWithPath: it.filename)) else { continue }
    let charLeft = skelMinX + (it.srcX - srcSkelMinX) / srcSkelW * skelW + it.dx
    let charTop = skelMinY + (it.srcY - srcSkelMinY) / srcSkelH * skelH + it.dy
    let charWidth = it.srcW / srcSkelW * skelW
    let charHeight = it.srcH / srcSkelH * skelH
    let cocoaY = charH - charTop - charHeight
    
    let r = NSRect(x: charLeft, y: cocoaY, width: charWidth, height: charHeight)
    img.draw(in: r, from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
}
canvasTransparent.unlockFocus()

let onCharRep = NSBitmapImageRep(data: canvasOnChar.tiffRepresentation!)!
let onCharPng = onCharRep.representation(using: .png, properties: [:])!
try! onCharPng.write(to: URL(fileURLWithPath: "scratch/final_on_char.png"))

let transRep = NSBitmapImageRep(data: canvasTransparent.tiffRepresentation!)!
let transPng = transRep.representation(using: .png, properties: [:])!
try! transPng.write(to: URL(fileURLWithPath: "scratch/final_transparent_assembled.png"))

// 3. Side by side comparison with user's screenshot!
let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let imgShot = NSImage(contentsOf: urlShot)!
let repShot = NSBitmapImageRep(data: imgShot.tiffRepresentation!)!

let sideCanvas = NSImage(size: NSSize(width: 480, height: 681))
sideCanvas.lockFocus()

NSColor(calibratedWhite: 0.15, alpha: 1.0).setFill()
NSRect(x: 0, y: 0, width: 480, height: 681).fill()

let scale = 681.0 / 426.0
let shotDrawX = 20.0 - 43.0 * scale
let shotDrawY = 0.0 - (Double(repShot.pixelsHigh) * scale - 450.0 * scale)
imgShot.draw(in: NSRect(x: shotDrawX, y: shotDrawY, width: Double(repShot.pixelsWide) * scale, height: Double(repShot.pixelsHigh) * scale),
             from: NSRect.zero,
             operation: .sourceOver,
             fraction: 1.0)

canvasOnChar.draw(in: NSRect(x: 240, y: 0, width: charW, height: charH),
                  from: NSRect.zero,
                  operation: .sourceOver,
                  fraction: 1.0)

sideCanvas.unlockFocus()

let sideRep = NSBitmapImageRep(data: sideCanvas.tiffRepresentation!)!
let sidePng = sideRep.representation(using: .png, properties: [:])!
try! sidePng.write(to: URL(fileURLWithPath: "scratch/final_side_by_side_comparison.png"))
print("Saved scratch/final_side_by_side_comparison.png")
