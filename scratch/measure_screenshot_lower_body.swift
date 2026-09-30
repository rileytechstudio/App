import AppKit

let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let repShot = NSBitmapImageRep(data: NSImage(contentsOf: urlShot)!.tiffRepresentation!)!

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

// Front leg (Left):
// Femur: y: 245..340, x: 65..95
let femurL = toPercentRect(minX: 65, maxX: 95, minY: 245, maxY: 340)
print("Femur (Front/Left): cx=\(String(format: "%.1f", femurL.cx))%, cy=\(String(format: "%.1f", femurL.cy))%, w=\(String(format: "%.1f", femurL.w))%, h=\(String(format: "%.1f", femurL.h))%")

// Tibia/Fibula: y: 340..425, x: 65..88
let tibiaL = toPercentRect(minX: 65, maxX: 88, minY: 340, maxY: 425)
print("Tibia/Fibula (Front/Left): cx=\(String(format: "%.1f", tibiaL.cx))%, cy=\(String(format: "%.1f", tibiaL.cy))%, w=\(String(format: "%.1f", tibiaL.w))%, h=\(String(format: "%.1f", tibiaL.h))%")

// Foot: y: 420..448, x: 65..106
let feetL = toPercentRect(minX: 65, maxX: 106, minY: 420, maxY: 448)
print("Feet (Front/Left): cx=\(String(format: "%.1f", feetL.cx))%, cy=\(String(format: "%.1f", feetL.cy))%, w=\(String(format: "%.1f", feetL.w))%, h=\(String(format: "%.1f", feetL.h))%")

// Back leg (Right):
// Femur: y: 245..340, x: 110..142
let femurR = toPercentRect(minX: 110, maxX: 142, minY: 245, maxY: 340)
print("Femur (Back/Right): cx=\(String(format: "%.1f", femurR.cx))%, cy=\(String(format: "%.1f", femurR.cy))%, w=\(String(format: "%.1f", femurR.w))%, h=\(String(format: "%.1f", femurR.h))%")

// Tibia/Fibula: y: 340..425, x: 118..138
let tibiaR = toPercentRect(minX: 118, maxX: 138, minY: 340, maxY: 425)
print("Tibia/Fibula (Back/Right): cx=\(String(format: "%.1f", tibiaR.cx))%, cy=\(String(format: "%.1f", tibiaR.cy))%, w=\(String(format: "%.1f", tibiaR.w))%, h=\(String(format: "%.1f", tibiaR.h))%")

// Foot: y: 420..445, x: 118..165
let feetR = toPercentRect(minX: 118, maxX: 165, minY: 420, maxY: 445)
print("Feet (Back/Right): cx=\(String(format: "%.1f", feetR.cx))%, cy=\(String(format: "%.1f", feetR.cy))%, w=\(String(format: "%.1f", feetR.w))%, h=\(String(format: "%.1f", feetR.h))%")
