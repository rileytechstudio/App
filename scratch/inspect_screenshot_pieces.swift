import AppKit

let url = URL(fileURLWithPath: "scratch/screenshot_bone_mask.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

let silX: Double = 42.0
let silY: Double = 25.0
let silW: Double = 138.0
let silH: Double = 426.0

// Helper to get connected components or measure bounding box in a given box
func measureBox(minX: Int, maxX: Int, minY: Int, maxY: Int, name: String) -> (cx: Double, cy: Double, w: Double, h: Double) {
    var bMinX = rep.pixelsWide, bMaxX = 0, bMinY = rep.pixelsHigh, bMaxY = 0
    var count = 0
    for y in minY...maxY {
        for x in minX...maxX {
            let c = rep.colorAt(x: x, y: y)!
            if c.alphaComponent > 0.3 {
                bMinX = min(bMinX, x)
                bMaxX = max(bMaxX, x)
                bMinY = min(bMinY, y)
                bMaxY = max(bMaxY, y)
                count += 1
            }
        }
    }
    guard count > 0 else {
        print("No pixels found for \(name)")
        return (0, 0, 0, 0)
    }
    let pw = Double(bMaxX - bMinX + 1)
    let ph = Double(bMaxY - bMinY + 1)
    let pcx = Double(bMinX) + pw / 2.0
    let pcy = Double(bMinY) + ph / 2.0
    
    let relCx = (pcx - silX) / silW * 100.0
    let relCy = (pcy - silY) / silH * 100.0
    let relW = pw / silW * 100.0
    let relH = ph / silH * 100.0
    
    print(String(format: "%-16@: x:%d..%d (w:%.0f), y:%d..%d (h:%.0f) -> cx: %5.1f%%, cy: %5.1f%%, w: %5.1f%%, h: %5.1f%%",
        name, bMinX, bMaxX, pw, bMinY, bMaxY, ph, relCx, relCy, relW, relH))
    return (relCx, relCy, relW, relH)
}

print("--- Screenshot Precise Bone Piece Bounds ---")
// 1. Skull: y from 33 down to 82, x from 75 to 140
measureBox(minX: 75, maxX: 140, minY: 33, maxY: 82, name: "skull")

// 2. Spine - cervical + thoracic + lumbar (runs from under skull y=83 down to pelvis y=212, x=88..115)
// Notice in the body, the spine runs through the ribcage
measureBox(minX: 88, maxX: 115, minY: 83, maxY: 215, name: "spine")

// 3. Ribcage - x: 68..142, y: 106..178
measureBox(minX: 68, maxX: 142, minY: 106, maxY: 178, name: "ribcage")

// 4. Pelvis - x: 74..146, y: 202..252
measureBox(minX: 74, maxX: 146, minY: 202, maxY: 252, name: "pelvis")

// 5. Left Arm:
// Humerus (left) - front arm upper: x: 46..73, y: 112..174
measureBox(minX: 46, maxX: 75, minY: 110, maxY: 175, name: "humerus_l")
// Radius & Ulna (left) - front forearm: x: 46..79, y: 173..228
measureBox(minX: 46, maxX: 80, minY: 173, maxY: 228, name: "radius_ulna_l")
// Hand (left) - front hand: x: 75..95, y: 224..262
measureBox(minX: 74, maxX: 96, minY: 224, maxY: 262, name: "hands_l")

// 6. Right Arm (back arm):
// Humerus (right) - back arm upper: x: 138..150, y: 140..177
measureBox(minX: 137, maxX: 152, minY: 140, maxY: 180, name: "humerus_r")
// Radius & Ulna (right) - back forearm: x: 140..163, y: 175..226
measureBox(minX: 138, maxX: 165, minY: 175, maxY: 226, name: "radius_ulna_r")
// Hand (right) - back hand: x: 153..168, y: 225..258
measureBox(minX: 152, maxX: 170, minY: 224, maxY: 260, name: "hands_r")

// 7. Left Leg (front):
measureBox(minX: 73, maxX: 105, minY: 245, maxY: 345, name: "femur_l")
measureBox(minX: 72, maxX: 102, minY: 343, maxY: 422, name: "fibula_tibia_l")
measureBox(minX: 72, maxX: 117, minY: 419, maxY: 448, name: "feet_l")

// 8. Right Leg (back):
measureBox(minX: 118, maxX: 148, minY: 245, maxY: 345, name: "femur_r")
measureBox(minX: 125, maxX: 149, minY: 343, maxY: 422, name: "fibula_tibia_r")
measureBox(minX: 124, maxX: 168, minY: 415, maxY: 442, name: "feet_r")

