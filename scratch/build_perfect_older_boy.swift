import AppKit

// 1. Load high-res Older Boy Skeleton.png (1545 x 1999)
let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

func getCleanPixel(x: Int, y: Int) -> NSColor? {
    guard x >= 0 && x < repSkel.pixelsWide && y >= 0 && y < repSkel.pixelsHigh else { return nil }
    let c = repSkel.colorAt(x: x, y: y)!
    let r = c.redComponent
    let g = c.greenComponent
    let b = c.blueComponent
    
    // White bone:
    if r > 0.78 && g > 0.78 && b > 0.78 { return c }
    // Cyan bone:
    if b > 0.38 && g > 0.32 && g > r + 0.03 { return c }
    // Eye socket / nasal cavity in head (x: 810..865, y: 440..515):
    if x >= 810 && x <= 865 && y >= 440 && y <= 515 && r < 0.25 && g < 0.25 && b < 0.35 { return c }
    return nil
}

// 2. Build high-res assembled skeleton canvas
// In Older Boy Skeleton.png:
// Whole skeleton: x: 596..967 (w:372), y: 372..1633 (h:1262)
// Skull is x: 700..863, y: 372..536
// We shift the skull dx = -20, dy = +26 so the jaw connects cleanly to the cervical spine
let skelW = 390
let skelH = 1270
let assembledRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: skelW, pixelsHigh: skelH, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<skelH {
    for x in 0..<skelW {
        assembledRep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
    }
}

// Draw body (neck, spine, ribs, pelvis, limbs)
for y in 520...1633 {
    for x in 596...967 {
        if let c = getCleanPixel(x: x, y: y) {
            let outX = (x - 596) + 15
            let outY = (y - 372)
            if outX >= 0 && outX < skelW && outY >= 0 && outY < skelH {
                assembledRep.setColor(c, atX: outX, y: outY)
            }
        }
    }
}

// Draw skull with shift dx=-20, dy=26
for y in 372...536 {
    for x in 700...863 {
        if x < 745 && y > 515 { continue } // avoid cervical spine fragment in skull crop
        if let c = getCleanPixel(x: x, y: y) {
            let outX = (x - 596) + 15 - 20
            let outY = (y - 372) + 26
            if outX >= 0 && outX < skelW && outY >= 0 && outY < skelH {
                assembledRep.setColor(c, atX: outX, y: outY)
            }
        }
    }
}

// Find tight bounding box of assembled skeleton
var aMinX = skelW, aMaxX = 0, aMinY = skelH, aMaxY = 0
for y in 0..<skelH {
    for x in 0..<skelW {
        if assembledRep.colorAt(x: x, y: y)!.alphaComponent > 0.3 {
            aMinX = min(aMinX, x)
            aMaxX = max(aMaxX, x)
            aMinY = min(aMinY, y)
            aMaxY = max(aMaxY, y)
        }
    }
}

let tightW = aMaxX - aMinX + 1
let tightH = aMaxY - aMinY + 1
print("Assembled skeleton tight bounds: x:\(aMinX)..\(aMaxX) (w:\(tightW)), y:\(aMinY)..\(aMaxY) (h:\(tightH))")

let croppedAssembledRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: tightW, pixelsHigh: tightH, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
for y in 0..<tightH {
    for x in 0..<tightW {
        croppedAssembledRep.setColor(assembledRep.colorAt(x: aMinX + x, y: aMinY + y)!, atX: x, y: y)
    }
}

// Save assembled skeleton
let assembledPng = croppedAssembledRep.representation(using: .png, properties: [:])!
try! assembledPng.write(to: URL(fileURLWithPath: "scratch/perfect_assembled_skel.png"))
print("Saved scratch/perfect_assembled_skel.png")

// 3. Define the 16 anatomical bone components within the assembled skeleton (tightW x tightH = 372 x 1236)
// Notice all coordinates are within croppedAssembledRep [0..<tightW, 0..<tightH]
struct PieceSlice {
    let id: String
    let file: String
    let zIndex: Int
    // Bounding box in cropped assembled skeleton
    let minX: Int
    let maxX: Int
    let minY: Int
    let maxY: Int
    // Optional pixel filter mask
    let mask: ((Int, Int) -> Bool)?
}

let pieceSlices: [PieceSlice] = [
    // Skull: top to jaw (y: 0..190, x: 80..270)
    PieceSlice(id: "skull", file: "Bone_older_boy_skull.png", zIndex: 10,
               minX: 80, maxX: 270, minY: 0, maxY: 190,
               mask: { x, y in y <= 165 || (y <= 190 && x >= 145) }),
               
    // Spine: cervical spine from under skull (y=165) down through chest to lumbar (y=570)
    PieceSlice(id: "spine", file: "Bone_older_boy_spine.png", zIndex: 1,
               minX: 120, maxX: 210, minY: 160, maxY: 575,
               mask: { x, y in
                   // In neck (y <= 275): x: 120..190
                   if y <= 275 { return x >= 120 && x <= 190 }
                   // In chest/lumbar: x: 140..205
                   return x >= 140 && x <= 205
               }),
               
    // Ribcage: clavicles (y=250) down through ribs (y=490), x: 45..275
    PieceSlice(id: "ribcage", file: "Bone_older_boy_ribcage.png", zIndex: 3,
               minX: 45, maxX: 275, minY: 250, maxY: 495,
               mask: { x, y in
                   // Exclude left arm (x < 80, y > 280)
                   if x < 80 && y >= 280 { return false }
                   // Exclude right arm (x > 250, y >= 350)
                   if x > 250 && y >= 350 { return false }
                   return true
               }),
               
    // Pelvis: x: 60..285, y: 560..710
    PieceSlice(id: "pelvis", file: "Bone_older_boy_pelvis.png", zIndex: 2,
               minX: 60, maxX: 285, minY: 560, maxY: 710,
               mask: nil),
               
    // Left Arm (front):
    // Humerus left: x: 0..85, y: 265..435
    PieceSlice(id: "humerus_l", file: "Bone_older_boy_humerus_left.png", zIndex: 4,
               minX: 0, maxX: 85, minY: 265, maxY: 435,
               mask: { x, y in
                   // Exclude clavicle top if any (y < 280, x > 60)
                   if y < 280 && x > 60 { return false }
                   return true
               }),
    // Radius & Ulna left: x: 0..95, y: 430..600
    PieceSlice(id: "radius_ulna_l", file: "Bone_older_boy_radius_ulna_left.png", zIndex: 5,
               minX: 0, maxX: 95, minY: 430, maxY: 600,
               mask: nil),
    // Hand left: x: 60..125, y: 590..705
    PieceSlice(id: "hands_l", file: "Bone_older_boy_hands_left.png", zIndex: 6,
               minX: 60, maxX: 125, minY: 590, maxY: 705,
               mask: nil),
               
    // Right Arm (back):
    // Humerus right: x: 250..295, y: 355..470
    PieceSlice(id: "humerus_r", file: "Bone_older_boy_humerus_right.png", zIndex: 2,
               minX: 250, maxX: 295, minY: 355, maxY: 470,
               mask: nil),
    // Radius & Ulna right: x: 250..325, y: 455..595
    PieceSlice(id: "radius_ulna_r", file: "Bone_older_boy_radius_ulna_right.png", zIndex: 2,
               minX: 250, maxX: 325, minY: 455, maxY: 595,
               mask: nil),
    // Hand right: x: 290..345, y: 590..695
    PieceSlice(id: "hands_r", file: "Bone_older_boy_hands_right.png", zIndex: 6,
               minX: 290, maxX: 345, minY: 590, maxY: 695,
               mask: nil),
               
    // Left Leg:
    // Femur left: x: 60..160, y: 665..940
    PieceSlice(id: "femur_l", file: "Bone_older_boy_femur_left.png", zIndex: 4,
               minX: 60, maxX: 160, minY: 665, maxY: 940,
               mask: nil),
    // Fibula & Tibia left: x: 55..145, y: 930..1195
    PieceSlice(id: "fibula_tibia_l", file: "Bone_older_boy_fibula_tibia_left.png", zIndex: 7,
               minX: 55, maxX: 145, minY: 930, maxY: 1195,
               mask: nil),
    // Foot left: x: 50..185, y: 1170..1236
    PieceSlice(id: "feet_l", file: "Bone_older_boy_feet_left.png", zIndex: 8,
               minX: 50, maxX: 185, minY: 1170, maxY: 1236,
               mask: nil),
               
    // Right Leg:
    // Femur right: x: 190..290, y: 665..940
    PieceSlice(id: "femur_r", file: "Bone_older_boy_femur_right.png", zIndex: 2,
               minX: 190, maxX: 290, minY: 665, maxY: 940,
               mask: nil),
    // Fibula & Tibia right: x: 225..290, y: 930..1195
    PieceSlice(id: "fibula_tibia_r", file: "Bone_older_boy_fibula_tibia_right.png", zIndex: 6,
               minX: 225, maxX: 290, minY: 930, maxY: 1195,
               mask: nil),
    // Foot right: x: 225..372, y: 1165..1236
    PieceSlice(id: "feet_r", file: "Bone_older_boy_feet_right.png", zIndex: 7,
               minX: 225, maxX: 372, minY: 1165, maxY: 1236,
               mask: nil)
]

// 4. Crop and export each piece, and calculate precise coordinates relative to Character_OlderBoy_Solo:
// Placement of assembled skeleton on character (220 x 681):
// skelOriginX = 2.90%, skelOriginY = 1.88%, skelW_pct = 89.13%, skelH_pct = 97.65%
let skelOriginX = 2.90
let skelOriginY = 1.88
let skelW_pct = 89.13
let skelH_pct = 97.65

print("\n--- Generating Clean Slices ---")
struct ExportedSlice {
    let id: String
    let file: String
    let x: Double
    let y: Double
    let w: Double
    let h: Double
    let zIndex: Int
    let rep: NSBitmapImageRep
}

var exportedSlices: [ExportedSlice] = []

for s in pieceSlices {
    var pMinX = s.maxX, pMaxX = s.minX, pMinY = s.maxY, pMaxY = s.minY
    for y in s.minY...min(s.maxY, tightH - 1) {
        for x in s.minX...min(s.maxX, tightW - 1) {
            if let m = s.mask, !m(x, y) { continue }
            if croppedAssembledRep.colorAt(x: x, y: y)!.alphaComponent > 0.1 {
                pMinX = min(pMinX, x)
                pMaxX = max(pMaxX, x)
                pMinY = min(pMinY, y)
                pMaxY = max(pMaxY, y)
            }
        }
    }
    
    let pw = max(1, pMaxX - pMinX + 1)
    let ph = max(1, pMaxY - pMinY + 1)
    let pRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pw, pixelsHigh: ph, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    
    for y in 0..<ph {
        for x in 0..<pw {
            let sx = pMinX + x
            let sy = pMinY + y
            if let m = s.mask, !m(sx, sy) {
                pRep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
                continue
            }
            pRep.setColor(croppedAssembledRep.colorAt(x: sx, y: sy)!, atX: x, y: y)
        }
    }
    
    let cx = Double(pMinX + pMaxX) / 2.0
    let cy = Double(pMinY + pMaxY) / 2.0
    
    let charW = (Double(pw) / Double(tightW)) * skelW_pct
    let charH = (Double(ph) / Double(tightH)) * skelH_pct
    let charX = skelOriginX + (cx / Double(tightW)) * skelW_pct
    let charY = skelOriginY + (cy / Double(tightH)) * skelH_pct
    
    let sliceData = pRep.representation(using: .png, properties: [:])!
    try! sliceData.write(to: URL(fileURLWithPath: "scratch/out_\(s.file)"))
    
    exportedSlices.append(ExportedSlice(id: s.id, file: s.file, x: charX, y: charY, w: charW, h: charH, zIndex: s.zIndex, rep: pRep))
    print(String(format: "%-16@: x:%5.1f%%, y:%5.1f%%, w:%5.1f%%, h:%5.1f%% (size: %3d x %3d)",
        s.id, charX, charY, charW, charH, pw, ph))
}

// 5. Test composite: render these exported slices on Character_OlderBoy_Solo.png
let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let imgSolo = NSImage(contentsOf: urlSolo)!
let repSolo = NSBitmapImageRep(data: imgSolo.tiffRepresentation!)!
let cW = Double(repSolo.pixelsWide) // 220
let cH = Double(repSolo.pixelsHigh) // 681

let testCanvas = NSImage(size: NSSize(width: cW, height: cH))
testCanvas.lockFocus()
imgSolo.draw(in: NSRect(x: 0, y: 0, width: cW, height: cH))

let sortedSlices = exportedSlices.sorted { $0.zIndex < $1.zIndex }
for es in sortedSlices {
    let pImg = NSImage(data: es.rep.representation(using: .png, properties: [:])!)!
    let destW = es.w / 100.0 * cW
    let destH = es.h / 100.0 * cH
    let destX = (es.x / 100.0 * cW) - (destW / 2.0)
    let screenY = (es.y / 100.0 * cH) - (destH / 2.0)
    let cocoaY = cH - screenY - destH
    
    pImg.draw(in: NSRect(x: destX, y: cocoaY, width: destW, height: destH), from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
}
testCanvas.unlockFocus()

let testRep = NSBitmapImageRep(data: testCanvas.tiffRepresentation!)!
try! testRep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "scratch/older_boy_reassembled_perfect.png"))
print("Saved scratch/older_boy_reassembled_perfect.png")

