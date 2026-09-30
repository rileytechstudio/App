import AppKit

let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let imgSolo = NSImage(contentsOf: urlSolo)!
let repSolo = NSBitmapImageRep(data: imgSolo.tiffRepresentation!)!
let charW = Double(repSolo.pixelsWide) // 220
let charH = Double(repSolo.pixelsHigh) // 681

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
    let pieceId: String
    let name: String
    let filename: String
    let iosImageName: String
    let zIndex: Int
    let srcX: Double
    let srcY: Double
    let srcW: Double
    let srcH: Double
    let dx: Double
    let dy: Double
    let scale: Double
}

let items: [BoneItemConfig] = [
    // zIndex: 1
    BoneItemConfig(id: "spine", pieceId: "spine", name: "Spine",
                   filename: "Bone_older_boy_spine.png", iosImageName: "AnatomyBoneOlderBoySpine",
                   zIndex: 1, srcX: 720, srcY: 535, srcW: 66, srcH: 411, dx: 0, dy: 0, scale: 1.0),
    
    // zIndex: 2
    BoneItemConfig(id: "pelvis", pieceId: "pelvis", name: "Pelvis",
                   filename: "Bone_older_boy_pelvis.png", iosImageName: "AnatomyBoneOlderBoyPelvis",
                   zIndex: 2, srcX: 671, srcY: 920, srcW: 210, srcH: 201, dx: 0, dy: 0, scale: 1.0),
    BoneItemConfig(id: "humerus", pieceId: "humerus_r", name: "Humerus",
                   filename: "Bone_older_boy_humerus_right.png", iosImageName: "AnatomyBoneOlderBoyHumerusRight",
                   zIndex: 2, srcX: 845, srcY: 725, srcW: 41, srcH: 116, dx: 0, dy: 0, scale: 1.0),
    BoneItemConfig(id: "radius_ulna", pieceId: "radius_ulna_r", name: "Radius and Ulna",
                   filename: "Bone_older_boy_radius_ulna_right.png", iosImageName: "AnatomyBoneOlderBoyRadiusUlnaRight",
                   zIndex: 2, srcX: 845, srcY: 830, srcW: 70, srcH: 151, dx: 0, dy: 0, scale: 1.0),
    BoneItemConfig(id: "femur", pieceId: "femur_r", name: "Femur",
                   filename: "Bone_older_boy_femur_right.png", iosImageName: "AnatomyBoneOlderBoyFemurRight",
                   zIndex: 2, srcX: 785, srcY: 1040, srcW: 101, srcH: 276, dx: 0, dy: 0, scale: 1.0),
    
    // zIndex: 3
    BoneItemConfig(id: "ribcage", pieceId: "ribcage", name: "Ribcage",
                   filename: "Bone_older_boy_ribcage.png", iosImageName: "AnatomyBoneOlderBoyRibcage",
                   zIndex: 3, srcX: 635, srcY: 625, srcW: 241, srcH: 241, dx: 0, dy: 0, scale: 1.0),
    
    // zIndex: 4
    BoneItemConfig(id: "humerus", pieceId: "humerus_l", name: "Humerus",
                   filename: "Bone_older_boy_humerus_left.png", iosImageName: "AnatomyBoneOlderBoyHumerusLeft",
                   zIndex: 4, srcX: 610, srcY: 645, srcW: 66, srcH: 166, dx: 2.0, dy: 0, scale: 1.0),
    BoneItemConfig(id: "femur", pieceId: "femur_l", name: "Femur",
                   filename: "Bone_older_boy_femur_left.png", iosImageName: "AnatomyBoneOlderBoyFemurLeft",
                   zIndex: 4, srcX: 655, srcY: 1040, srcW: 106, srcH: 276, dx: 0, dy: 0, scale: 1.0),
    
    // zIndex: 5
    BoneItemConfig(id: "radius_ulna", pieceId: "radius_ulna_l", name: "Radius and Ulna",
                   filename: "Bone_older_boy_radius_ulna_left.png", iosImageName: "AnatomyBoneOlderBoyRadiusUlnaLeft",
                   zIndex: 5, srcX: 596, srcY: 800, srcW: 95, srcH: 171, dx: 2.0, dy: 0, scale: 1.0),
    
    // zIndex: 6
    BoneItemConfig(id: "hands", pieceId: "hands_l", name: "Hands",
                   filename: "Bone_older_boy_hands_left.png", iosImageName: "AnatomyBoneOlderBoyHandsLeft",
                   zIndex: 6, srcX: 655, srcY: 965, srcW: 66, srcH: 111, dx: 2.0, dy: 0, scale: 1.0),
    BoneItemConfig(id: "hands", pieceId: "hands_r", name: "Hands",
                   filename: "Bone_older_boy_hands_right.png", iosImageName: "AnatomyBoneOlderBoyHandsRight",
                   zIndex: 6, srcX: 885, srcY: 980, srcW: 52, srcH: 96, dx: 0, dy: 0, scale: 1.0),
    BoneItemConfig(id: "fibula_tibia", pieceId: "fibula_tibia_r", name: "Tibia and Fibula",
                   filename: "Bone_older_boy_fibula_tibia_right.png", iosImageName: "AnatomyBoneOlderBoyFibulaTibiaRight",
                   zIndex: 6, srcX: 820, srcY: 1300, srcW: 66, srcH: 266, dx: 0, dy: 0, scale: 1.0),
    
    // zIndex: 7
    BoneItemConfig(id: "fibula_tibia", pieceId: "fibula_tibia_l", name: "Tibia and Fibula",
                   filename: "Bone_older_boy_fibula_tibia_left.png", iosImageName: "AnatomyBoneOlderBoyFibulaTibiaLeft",
                   zIndex: 7, srcX: 651, srcY: 1303, srcW: 85, srcH: 263, dx: 0, dy: 0, scale: 1.0),
    BoneItemConfig(id: "feet", pieceId: "feet_r", name: "Feet",
                   filename: "Bone_older_boy_feet_right.png", iosImageName: "AnatomyBoneOlderBoyFeetRight",
                   zIndex: 7, srcX: 820, srcY: 1540, srcW: 148, srcH: 71, dx: 0, dy: 0, scale: 1.0),
    
    // zIndex: 8
    BoneItemConfig(id: "feet", pieceId: "feet_l", name: "Feet",
                   filename: "Bone_older_boy_feet_left.png", iosImageName: "AnatomyBoneOlderBoyFeetLeft",
                   zIndex: 8, srcX: 646, srcY: 1545, srcW: 135, srcH: 89, dx: 0, dy: 0, scale: 1.0),
    
    // zIndex: 10
    // Skull: shifted right by 11.0px, down by 9.0px, scale 1.04
    BoneItemConfig(id: "skull", pieceId: "skull", name: "Skull",
                   filename: "Bone_older_boy_skull.png", iosImageName: "AnatomyBoneOlderBoySkull",
                   zIndex: 10, srcX: 700, srcY: 372, srcW: 164, srcH: 165, dx: 11.0, dy: 9.0, scale: 1.04)
]

// 1. Copy bone PNGs to destinations:
let fm = FileManager.default
for it in items {
    let srcPath = "scratch/unmatted_\(it.filename)"
    let data = try! Data(contentsOf: URL(fileURLWithPath: srcPath))
    
    // Destination 1: assets/bones/
    try! data.write(to: URL(fileURLWithPath: "assets/bones/\(it.filename)"))
    
    // Destination 2: preview/assets/bones/
    try! data.write(to: URL(fileURLWithPath: "preview/assets/bones/\(it.filename)"))
    
    // Destination 3: iOS/RileyApp/Assets.xcassets/<iosImageName>.imageset/<iosImageName>.png
    let iosPath = "iOS/RileyApp/Assets.xcassets/\(it.iosImageName).imageset/\(it.iosImageName).png"
    if fm.fileExists(atPath: iosPath) {
        try! data.write(to: URL(fileURLWithPath: iosPath))
    }
}
print("Copied all 16 bone PNGs to assets, preview, and iOS Assets")

// 2. Render and save Skeleton_OlderBoy_Assembled.png:
let canvasTrans = NSImage(size: NSSize(width: charW, height: charH))
canvasTrans.lockFocus()
let sortedItems = items.sorted { $0.zIndex < $1.zIndex }
for it in sortedItems {
    let img = NSImage(contentsOf: URL(fileURLWithPath: "scratch/unmatted_\(it.filename)"))!
    let origW = it.srcW / srcSkelW * skelW
    let origH = it.srcH / srcSkelH * skelH
    let charWidth = origW * it.scale
    let charHeight = origH * it.scale
    var charLeft = skelMinX + (it.srcX - srcSkelMinX) / srcSkelW * skelW + it.dx
    var charTop = skelMinY + (it.srcY - srcSkelMinY) / srcSkelH * skelH + it.dy
    if it.scale != 1.0 {
        charLeft -= (charWidth - origW) / 2.0
        charTop -= (charHeight - origH) / 2.0
    }
    let cocoaY = charH - charTop - charHeight
    img.draw(in: NSRect(x: charLeft, y: cocoaY, width: charWidth, height: charHeight),
             from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
}
canvasTrans.unlockFocus()

let transRep = NSBitmapImageRep(data: canvasTrans.tiffRepresentation!)!
let transPng = transRep.representation(using: .png, properties: [:])!
try! transPng.write(to: URL(fileURLWithPath: "assets/Skeleton_OlderBoy_Assembled.png"))
try! transPng.write(to: URL(fileURLWithPath: "preview/assets/Skeleton_OlderBoy_Assembled.png"))
print("Saved Skeleton_OlderBoy_Assembled.png to assets and preview")

// 3. Print Web (JavaScript) config:
print("\n--- JAVASCRIPT CONFIG (for preview/index.html) ---")
print("      'older-boy': [")
for it in items {
    let origW = it.srcW / srcSkelW * skelW
    let origH = it.srcH / srcSkelH * skelH
    let charWidth = origW * it.scale
    let charHeight = origH * it.scale
    var charLeft = skelMinX + (it.srcX - srcSkelMinX) / srcSkelW * skelW + it.dx
    var charTop = skelMinY + (it.srcY - srcSkelMinY) / srcSkelH * skelH + it.dy
    if it.scale != 1.0 {
        charLeft -= (charWidth - origW) / 2.0
        charTop -= (charHeight - origH) / 2.0
    }
    let cx = (charLeft + charWidth / 2.0) / charW * 100.0
    let cy = (charTop + charHeight / 2.0) / charH * 100.0
    let w = charWidth / charW * 100.0
    let h = charHeight / charH * 100.0
    
    print(String(format: "        { id: '%@', file: 'assets/bones/%@', x: %4.1f, y: %4.1f, w: %4.1f, h: %4.1f, rot: 0, zIndex: %d },",
                 it.id, it.filename, cx, cy, w, h, it.zIndex))
}
print("      ],")

// 4. Print Swift config:
print("\n--- SWIFT CONFIG (for AnatomyExplorerView.swift) ---")
print("        case \"older-boy\":")
print("            return [")
for it in items {
    let origW = it.srcW / srcSkelW * skelW
    let origH = it.srcH / srcSkelH * skelH
    let charWidth = origW * it.scale
    let charHeight = origH * it.scale
    var charLeft = skelMinX + (it.srcX - srcSkelMinX) / srcSkelW * skelW + it.dx
    var charTop = skelMinY + (it.srcY - srcSkelMinY) / srcSkelH * skelH + it.dy
    if it.scale != 1.0 {
        charLeft -= (charWidth - origW) / 2.0
        charTop -= (charHeight - origH) / 2.0
    }
    let cx = (charLeft + charWidth / 2.0) / charW * 100.0
    let cy = (charTop + charHeight / 2.0) / charH * 100.0
    let w = charWidth / charW * 100.0
    let h = charHeight / charH * 100.0
    
    print(String(format: "                AnatomicalBonePiece(id: \"%@\", parentBoneId: \"%@\", name: \"%@\", x: %4.1f, y: %4.1f, width: %4.1f, height: %4.1f, rotationAngle: 0.0, zIndex: %d, imageName: \"%@\"),",
                 it.pieceId, it.id, it.name, cx, cy, w, h, it.zIndex, it.iosImageName))
}
print("            ]")
