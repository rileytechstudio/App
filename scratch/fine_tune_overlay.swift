import AppKit

let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let imgSolo = NSImage(contentsOf: urlSolo)!
let repSolo = NSBitmapImageRep(data: imgSolo.tiffRepresentation!)!
let charW = Double(repSolo.pixelsWide) // 220
let charH = Double(repSolo.pixelsHigh) // 681

let pinkSilhouetteRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(charW), pixelsHigh: Int(charH), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
for y in 0..<Int(charH) {
    for x in 0..<Int(charW) {
        let c = repSolo.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            pinkSilhouetteRep.setColor(NSColor(calibratedRed: 1.0, green: 0.655, blue: 0.929, alpha: c.alphaComponent), atX: x, y: y)
        } else {
            pinkSilhouetteRep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
        }
    }
}
let imgPink = NSImage(data: pinkSilhouetteRep.representation(using: .png, properties: [:])!)!

let srcSkelMinX = 596.0
let srcSkelMinY = 371.0
let srcSkelW = 414.0
let srcSkelH = 1262.0

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
    let scale: Double
}

for skullDy in [6.0, 9.0, 12.0] {
    let items: [BoneItemConfig] = [
        BoneItemConfig(id: "spine", filename: "scratch/unmatted_Bone_older_boy_spine.png", zIndex: 1,
                       srcX: 720, srcY: 535, srcW: 66, srcH: 411, dx: 0, dy: 0, scale: 1.0),
        BoneItemConfig(id: "pelvis", filename: "scratch/unmatted_Bone_older_boy_pelvis.png", zIndex: 2,
                       srcX: 671, srcY: 920, srcW: 210, srcH: 201, dx: 0, dy: 0, scale: 1.0),
        BoneItemConfig(id: "humerus_r", filename: "scratch/unmatted_Bone_older_boy_humerus_right.png", zIndex: 2,
                       srcX: 845, srcY: 725, srcW: 41, srcH: 116, dx: 0, dy: 0, scale: 1.0),
        BoneItemConfig(id: "radius_ulna_r", filename: "scratch/unmatted_Bone_older_boy_radius_ulna_right.png", zIndex: 2,
                       srcX: 845, srcY: 830, srcW: 70, srcH: 151, dx: 0, dy: 0, scale: 1.0),
        BoneItemConfig(id: "femur_r", filename: "scratch/unmatted_Bone_older_boy_femur_right.png", zIndex: 2,
                       srcX: 785, srcY: 1040, srcW: 101, srcH: 276, dx: 0, dy: 0, scale: 1.0),
        BoneItemConfig(id: "ribcage", filename: "scratch/unmatted_Bone_older_boy_ribcage.png", zIndex: 3,
                       srcX: 635, srcY: 625, srcW: 241, srcH: 241, dx: 0, dy: 0, scale: 1.0),
        BoneItemConfig(id: "humerus_l", filename: "scratch/unmatted_Bone_older_boy_humerus_left.png", zIndex: 4,
                       srcX: 610, srcY: 645, srcW: 66, srcH: 166, dx: 2.0, dy: 0, scale: 1.0),
        BoneItemConfig(id: "femur_l", filename: "scratch/unmatted_Bone_older_boy_femur_left.png", zIndex: 4,
                       srcX: 655, srcY: 1040, srcW: 106, srcH: 276, dx: 0, dy: 0, scale: 1.0),
        BoneItemConfig(id: "radius_ulna_l", filename: "scratch/unmatted_Bone_older_boy_radius_ulna_left.png", zIndex: 5,
                       srcX: 596, srcY: 800, srcW: 95, srcH: 171, dx: 2.0, dy: 0, scale: 1.0),
        BoneItemConfig(id: "hands_l", filename: "scratch/unmatted_Bone_older_boy_hands_left.png", zIndex: 6,
                       srcX: 655, srcY: 965, srcW: 66, srcH: 111, dx: 2.0, dy: 0, scale: 1.0),
        BoneItemConfig(id: "hands_r", filename: "scratch/unmatted_Bone_older_boy_hands_right.png", zIndex: 6,
                       srcX: 885, srcY: 980, srcW: 52, srcH: 96, dx: 0, dy: 0, scale: 1.0),
        BoneItemConfig(id: "fibula_tibia_r", filename: "scratch/unmatted_Bone_older_boy_fibula_tibia_right.png", zIndex: 6,
                       srcX: 820, srcY: 1300, srcW: 66, srcH: 266, dx: 0, dy: 0, scale: 1.0),
        BoneItemConfig(id: "fibula_tibia_l", filename: "scratch/unmatted_Bone_older_boy_fibula_tibia_left.png", zIndex: 7,
                       srcX: 651, srcY: 1303, srcW: 85, srcH: 263, dx: 0, dy: 0, scale: 1.0),
        BoneItemConfig(id: "feet_r", filename: "scratch/unmatted_Bone_older_boy_feet_right.png", zIndex: 7,
                       srcX: 820, srcY: 1540, srcW: 148, srcH: 71, dx: 0, dy: 0, scale: 1.0),
        BoneItemConfig(id: "feet_l", filename: "scratch/unmatted_Bone_older_boy_feet_left.png", zIndex: 8,
                       srcX: 646, srcY: 1545, srcW: 135, srcH: 89, dx: 0, dy: 0, scale: 1.0),
        BoneItemConfig(id: "skull", filename: "scratch/unmatted_Bone_older_boy_skull.png", zIndex: 10,
                       srcX: 700, srcY: 372, srcW: 164, srcH: 165, dx: 11.0, dy: skullDy, scale: 1.04)
    ]
    
    let sorted = items.sorted { $0.zIndex < $1.zIndex }
    
    let canvas = NSImage(size: NSSize(width: charW, height: charH))
    canvas.lockFocus()
    imgPink.draw(in: NSRect(x: 0, y: 0, width: charW, height: charH))
    for it in sorted {
        guard let img = NSImage(contentsOf: URL(fileURLWithPath: it.filename)) else { continue }
        var charWidth = it.srcW / srcSkelW * skelW * it.scale
        var charHeight = it.srcH / srcSkelH * skelH * it.scale
        var charLeft = skelMinX + (it.srcX - srcSkelMinX) / srcSkelW * skelW + it.dx
        var charTop = skelMinY + (it.srcY - srcSkelMinY) / srcSkelH * skelH + it.dy
        if it.scale != 1.0 {
            let origW = it.srcW / srcSkelW * skelW
            let origH = it.srcH / srcSkelH * skelH
            charLeft -= (charWidth - origW) / 2.0
            charTop -= (charHeight - origH) / 2.0
        }
        let cocoaY = charH - charTop - charHeight
        img.draw(in: NSRect(x: charLeft, y: cocoaY, width: charWidth, height: charHeight),
                 from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
    }
    canvas.unlockFocus()
    
    let rep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
    let png = rep.representation(using: .png, properties: [:])!
    try! png.write(to: URL(fileURLWithPath: "scratch/test_tune_dy\(Int(skullDy)).png"))
}

// Side by side of screenshot, dy6, dy9, dy12
let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let imgShot = NSImage(contentsOf: urlShot)!
let repShot = NSBitmapImageRep(data: imgShot.tiffRepresentation!)!

let sideCanvas = NSImage(size: NSSize(width: 220 * 4 + 30, height: 681))
sideCanvas.lockFocus()
NSColor(calibratedWhite: 0.15, alpha: 1.0).setFill()
NSRect(x: 0, y: 0, width: 220 * 4 + 30, height: 681).fill()

let scale = 681.0 / 426.0
let shotDrawX = 0.0 - 43.0 * scale
let shotDrawY = 0.0 - (Double(repShot.pixelsHigh) * scale - 450.0 * scale)
imgShot.draw(in: NSRect(x: shotDrawX, y: shotDrawY, width: Double(repShot.pixelsWide) * scale, height: Double(repShot.pixelsHigh) * scale),
             from: NSRect.zero, operation: .sourceOver, fraction: 1.0)

for (i, dy) in [6, 9, 12].enumerated() {
    let img = NSImage(contentsOf: URL(fileURLWithPath: "scratch/test_tune_dy\(dy).png"))!
    img.draw(in: NSRect(x: 220.0 * Double(i + 1) + Double(i + 1) * 10.0, y: 0, width: 220, height: 681),
             from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
}
sideCanvas.unlockFocus()

let sideRep = NSBitmapImageRep(data: sideCanvas.tiffRepresentation!)!
let sidePng = sideRep.representation(using: .png, properties: [:])!
try! sidePng.write(to: URL(fileURLWithPath: "scratch/tuning_comparison.png"))
print("Saved scratch/tuning_comparison.png")
