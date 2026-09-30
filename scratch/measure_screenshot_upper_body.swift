import AppKit

let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let repShot = NSBitmapImageRep(data: NSImage(contentsOf: urlShot)!.tiffRepresentation!)!

// Shot dimensions: 274 x 469
// Character in shot: x: 43..178 (w: 136), y: 25..450 (h: 426)
// Scale to 220 x 681:
// normX = (shotX - 43) / 136 * 100 (%)
// normY = (shotY - 25) / 426 * 100 (%)

func toPercent(shotX: Double, shotY: Double) -> (x: Double, y: Double) {
    let px = (shotX - 43.0) / 136.0 * 100.0
    let py = (shotY - 25.0) / 426.0 * 100.0
    return (px, py)
}

func toPercentRect(minX: Double, maxX: Double, minY: Double, maxY: Double) -> (cx: Double, cy: Double, w: Double, h: Double) {
    let pMin = toPercent(shotX: minX, shotY: minY)
    let pMax = toPercent(shotX: maxX, shotY: maxY)
    let w = pMax.x - pMin.x
    let h = pMax.y - pMin.y
    let cx = pMin.x + w / 2.0
    let cy = pMin.y + h / 2.0
    return (cx, cy, w, h)
}

// 1. Skull in shot:
// x: 81..133, y: 33..78
let skull = toPercentRect(minX: 81, maxX: 133, minY: 33, maxY: 78)
print("Skull: cx=\(String(format: "%.1f", skull.cx))%, cy=\(String(format: "%.1f", skull.cy))%, w=\(String(format: "%.1f", skull.w))%, h=\(String(format: "%.1f", skull.h))%")

// 2. Clavicle / Ribcage in shot:
// Clavicles start at y=118, ribs end at y=177
// Ribs width: x: 67..133 (character's right clavicle reaches x=62 at y=120)
let ribs = toPercentRect(minX: 62, maxX: 134, minY: 118, maxY: 177)
print("Ribcage: cx=\(String(format: "%.1f", ribs.cx))%, cy=\(String(format: "%.1f", ribs.cy))%, w=\(String(format: "%.1f", ribs.w))%, h=\(String(format: "%.1f", ribs.h))%")

// 3. Spine in shot:
// Runs from under skull (y=78) through neck, thorax, lumbar down to pelvis (y=230)
// Width in neck x: 96..104, in lumbar x: 97..108
let spine = toPercentRect(minX: 95, maxX: 108, minY: 78, maxY: 230)
print("Spine: cx=\(String(format: "%.1f", spine.cx))%, cy=\(String(format: "%.1f", spine.cy))%, w=\(String(format: "%.1f", spine.w))%, h=\(String(format: "%.1f", spine.h))%")

// 4. Front Arm (character's right arm, on our left):
// Humerus: from shoulder joint (x: 55, y: 125) to elbow (x: 48, y: 180)
let humerusL = toPercentRect(minX: 47, maxX: 66, minY: 125, maxY: 180)
print("Humerus (Front/Left): cx=\(String(format: "%.1f", humerusL.cx))%, cy=\(String(format: "%.1f", humerusL.cy))%, w=\(String(format: "%.1f", humerusL.w))%, h=\(String(format: "%.1f", humerusL.h))%")

// Forearm (radius/ulna): from elbow (x: 48, y: 180) to wrist (x: 62, y: 228)
let radiusUlnaL = toPercentRect(minX: 48, maxX: 73, minY: 180, maxY: 228)
print("Radius/Ulna (Front/Left): cx=\(String(format: "%.1f", radiusUlnaL.cx))%, cy=\(String(format: "%.1f", radiusUlnaL.cy))%, w=\(String(format: "%.1f", radiusUlnaL.w))%, h=\(String(format: "%.1f", radiusUlnaL.h))%")

// Hand: from wrist (x: 62, y: 228) to fingertips (x: 75, y: 255)
let handsL = toPercentRect(minX: 61, maxX: 75, minY: 228, maxY: 256)
print("Hands (Front/Left): cx=\(String(format: "%.1f", handsL.cx))%, cy=\(String(format: "%.1f", handsL.cy))%, w=\(String(format: "%.1f", handsL.w))%, h=\(String(format: "%.1f", handsL.h))%")

// 5. Back Arm (character's left arm, on our right):
// Humerus: from shoulder (x: 130, y: 135) to elbow (x: 140, y: 180)
let humerusR = toPercentRect(minX: 128, maxX: 140, minY: 135, maxY: 180)
print("Humerus (Back/Right): cx=\(String(format: "%.1f", humerusR.cx))%, cy=\(String(format: "%.1f", humerusR.cy))%, w=\(String(format: "%.1f", humerusR.w))%, h=\(String(format: "%.1f", humerusR.h))%")

// Forearm: from elbow (x: 140, y: 180) to wrist (x: 152, y: 225)
let radiusUlnaR = toPercentRect(minX: 139, maxX: 152, minY: 180, maxY: 225)
print("Radius/Ulna (Back/Right): cx=\(String(format: "%.1f", radiusUlnaR.cx))%, cy=\(String(format: "%.1f", radiusUlnaR.cy))%, w=\(String(format: "%.1f", radiusUlnaR.w))%, h=\(String(format: "%.1f", radiusUlnaR.h))%")

// Hand: wrist to fingertips (x: 151, y: 225) to (x: 157, y: 250)
let handsR = toPercentRect(minX: 150, maxX: 158, minY: 225, maxY: 252)
print("Hands (Back/Right): cx=\(String(format: "%.1f", handsR.cx))%, cy=\(String(format: "%.1f", handsR.cy))%, w=\(String(format: "%.1f", handsR.w))%, h=\(String(format: "%.1f", handsR.h))%")

// 6. Pelvis:
// x: 74..140, y: 200..248
let pelvis = toPercentRect(minX: 74, maxX: 140, minY: 200, maxY: 248)
print("Pelvis: cx=\(String(format: "%.1f", pelvis.cx))%, cy=\(String(format: "%.1f", pelvis.cy))%, w=\(String(format: "%.1f", pelvis.w))%, h=\(String(format: "%.1f", pelvis.h))%")
