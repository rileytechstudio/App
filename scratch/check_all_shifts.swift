import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let repShot = NSBitmapImageRep(data: NSImage(contentsOf: urlShot)!.tiffRepresentation!)!

// Ribcage top-left:
// Skel: (640, 625)
// Shot: (68, 106)
// Scale: sx = 71/216 = 0.3287, sy = 73/241 = 0.3029

func testShift(name: String, skelX: Double, skelY: Double, shotX: Double, shotY: Double) {
    let expX = 68.0 + (skelX - 640.0) * 0.3287
    let expY = 106.0 + (skelY - 625.0) * 0.3029
    let dx = shotX - expX
    let dy = shotY - expY
    print(String(format: "%-16@: expected (%.1f, %.1f), actual (%.1f, %.1f) -> shift: dx=%+.1f, dy=%+.1f",
        name, expX, expY, shotX, shotY, dx, dy))
}

print("Comparing shifts relative to Ribcage:")
// Skull: (700, 372) in skel, (81, 33) in shot
testShift(name: "Skull", skelX: 700, skelY: 372, shotX: 81, shotY: 33)

// Spine top: (720, 520) in skel, (88, 83) in shot
testShift(name: "Spine Top", skelX: 720, skelY: 520, shotX: 88, shotY: 83)

// Pelvis top: (655, 935) in skel, (74, 202) in shot
testShift(name: "Pelvis Top", skelX: 655, skelY: 935, shotX: 74, shotY: 202)

// Left Arm (humerus_l top): (596, 640) in skel, (52, 116) in shot
testShift(name: "Humerus L Top", skelX: 596, skelY: 640, shotX: 52, shotY: 116)

// Right Arm (humerus_r top): (845, 730) in skel, (135, 135) in shot
testShift(name: "Humerus R Top", skelX: 845, skelY: 730, shotX: 135, shotY: 135)

// Left Leg (femur_l top): (655, 1040) in skel, (73, 245) in shot
testShift(name: "Femur L Top", skelX: 655, skelY: 1040, shotX: 73, shotY: 245)

// Left Foot: (645, 1545) in skel, (72, 419) in shot
testShift(name: "Foot L", skelX: 645, skelY: 1545, shotX: 72, shotY: 419)

