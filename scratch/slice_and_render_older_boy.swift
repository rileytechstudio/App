import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

// Clean pixel filter function
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
    // Dark bone contour / shadow in ribcage/pelvis/joints:
    if r < 0.25 && g < 0.25 && b < 0.35 {
        // Only if adjacent to bone
        return nil
    }
    return nil
}

struct BoneSliceDef {
    let id: String
    let file: String
    let minX: Int
    let maxX: Int
    let minY: Int
    let maxY: Int
    let zIndex: Int
    // Exclude condition for overlapping parts
    let exclude: ((Int, Int) -> Bool)?
}

let sliceDefs: [BoneSliceDef] = [
    // Skull: x: 700..863, y: 372..536, exclude bottom-left cervical spine fragment
    BoneSliceDef(id: "skull", file: "Bone_older_boy_skull.png", minX: 700, maxX: 863, minY: 372, maxY: 536, zIndex: 10,
                 exclude: { x, y in x < 745 && y > 515 }),
                 
    // Spine: cervical spine starts at y=515 under skull, down through ribcage to lumbar y=940
    BoneSliceDef(id: "spine", file: "Bone_older_boy_spine.png", minX: 720, maxX: 790, minY: 515, maxY: 945, zIndex: 1,
                 exclude: nil),
                 
    // Ribcage: clavicles at top y=625 down to ribs y=865, x: 640..855
    BoneSliceDef(id: "ribcage", file: "Bone_older_boy_ribcage.png", minX: 640, maxX: 855, minY: 625, maxY: 865, zIndex: 3,
                 exclude: nil),
                 
    // Pelvis: x: 655..875, y: 935..1080
    BoneSliceDef(id: "pelvis", file: "Bone_older_boy_pelvis.png", minX: 655, maxX: 875, minY: 935, maxY: 1080, zIndex: 2,
                 exclude: nil),
                 
    // Front Arm (Left):
    // Humerus left: x: 596..675, y: 640..805
    BoneSliceDef(id: "humerus_l", file: "Bone_older_boy_humerus_left.png", minX: 596, maxX: 675, minY: 640, maxY: 805, zIndex: 4,
                 exclude: nil),
    // Radius & Ulna left: x: 596..690, y: 800..970
    BoneSliceDef(id: "radius_ulna_l", file: "Bone_older_boy_radius_ulna_left.png", minX: 596, maxX: 690, minY: 800, maxY: 970, zIndex: 5,
                 exclude: nil),
    // Hand left: x: 655..720, y: 965..1075
    BoneSliceDef(id: "hands_l", file: "Bone_older_boy_hands_left.png", minX: 655, maxX: 720, minY: 965, maxY: 1075, zIndex: 6,
                 exclude: nil),
                 
    // Back Arm (Right):
    // Humerus right: x: 845..885, y: 730..840
    BoneSliceDef(id: "humerus_r", file: "Bone_older_boy_humerus_right.png", minX: 845, maxX: 885, minY: 730, maxY: 840, zIndex: 2,
                 exclude: nil),
    // Radius & Ulna right: x: 845..915, y: 830..965
    BoneSliceDef(id: "radius_ulna_r", file: "Bone_older_boy_radius_ulna_right.png", minX: 845, maxX: 915, minY: 830, maxY: 965, zIndex: 2,
                 exclude: nil),
    // Hand right: x: 885..935, y: 965..1065
    BoneSliceDef(id: "hands_r", file: "Bone_older_boy_hands_right.png", minX: 885, maxX: 935, minY: 965, maxY: 1065, zIndex: 6,
                 exclude: nil),
                 
    // Front Leg (Left):
    // Femur left: x: 655..750, y: 1040..1310
    BoneSliceDef(id: "femur_l", file: "Bone_older_boy_femur_left.png", minX: 655, maxX: 750, minY: 1040, maxY: 1310, zIndex: 4,
                 exclude: nil),
    // Fibula & Tibia left: x: 650..735, y: 1300..1565
    BoneSliceDef(id: "fibula_tibia_l", file: "Bone_older_boy_fibula_tibia_left.png", minX: 650, maxX: 735, minY: 1300, maxY: 1565, zIndex: 7,
                 exclude: nil),
    // Foot left: x: 645..780, y: 1545..1633
    BoneSliceDef(id: "feet_l", file: "Bone_older_boy_feet_left.png", minX: 645, maxX: 780, minY: 1545, maxY: 1633, zIndex: 8,
                 exclude: nil),
                 
    // Back Leg (Right):
    // Femur right: x: 785..885, y: 1040..1310
    BoneSliceDef(id: "femur_r", file: "Bone_older_boy_femur_right.png", minX: 785, maxX: 885, minY: 1040, maxY: 1310, zIndex: 2,
                 exclude: nil),
    // Fibula & Tibia right: x: 820..885, y: 1300..1565
    BoneSliceDef(id: "fibula_tibia_r", file: "Bone_older_boy_fibula_tibia_right.png", minX: 820, maxX: 885, minY: 1300, maxY: 1565, zIndex: 6,
                 exclude: nil),
    // Foot right: x: 820..967, y: 1540..1610
    BoneSliceDef(id: "feet_r", file: "Bone_older_boy_feet_right.png", minX: 820, maxX: 967, minY: 1540, maxY: 1610, zIndex: 7,
                 exclude: nil)
]

// Extract each slice, tight bounding box
var tightSlices: [(id: String, file: String, rep: NSBitmapImageRep, zIndex: Int)] = []

for s in sliceDefs {
    // First find non-nil bounds in this slice box
    var minBx = s.maxX, maxBx = s.minX, minBy = s.maxY, maxBy = s.minY
    var foundAny = false
    
    for y in s.minY...s.maxY {
        for x in s.minX...s.maxX {
            if let ex = s.exclude, ex(x, y) { continue }
            if getCleanPixel(x: x, y: y) != nil {
                minBx = min(minBx, x)
                maxBx = max(maxBx, x)
                minBy = min(minBy, y)
                maxBy = max(maxBy, y)
                foundAny = true
            }
        }
    }
    
    guard foundAny else {
        print("ERROR: No pixels for \(s.id)")
        continue
    }
    
    let pw = maxBx - minBx + 1
    let ph = maxBy - minBy + 1
    
    let pieceRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pw, pixelsHigh: ph, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    
    for y in 0..<ph {
        for x in 0..<pw {
            let sx = minBx + x
            let sy = minBy + y
            if let ex = s.exclude, ex(sx, sy) {
                pieceRep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
                continue
            }
            if let color = getCleanPixel(x: sx, y: sy) {
                pieceRep.setColor(color, atX: x, y: y)
            } else {
                pieceRep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
            }
        }
    }
    
    let pPng = pieceRep.representation(using: .png, properties: [:])!
    try! pPng.write(to: URL(fileURLWithPath: "scratch/test_\(s.file)"))
    tightSlices.append((id: s.id, file: s.file, rep: pieceRep, zIndex: s.zIndex))
    print(String(format: "%-16@: size %3d x %3d (aspect: %.3f)", s.id, pw, ph, Double(pw)/Double(ph)))
}

print("All slices extracted!")

