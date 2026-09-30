import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let repShot = NSBitmapImageRep(data: NSImage(contentsOf: urlShot)!.tiffRepresentation!)!

var shotMinX = 999, shotMaxX = 0, shotMinY = 999, shotMaxY = 0
for y in 40...75 {
    for x in 115...135 {
        let c = repShot.colorAt(x: x, y: y)!
        if c.redComponent < 0.25 && c.blueComponent < 0.35 && c.greenComponent < 0.25 {
            shotMinX = min(shotMinX, x)
            shotMaxX = max(shotMaxX, x)
            shotMinY = min(shotMinY, y)
            shotMaxY = max(shotMaxY, y)
        }
    }
}
print("Shot orbit bbox: x: \(shotMinX)..\(shotMaxX) (w: \(shotMaxX - shotMinX + 1)), y: \(shotMinY)..\(shotMaxY) (h: \(shotMaxY - shotMinY + 1))")

var skelMinX = 999, skelMaxX = 0, skelMinY = 999, skelMaxY = 0
for y in 440...500 {
    for x in 820...855 {
        let c = repSkel.colorAt(x: x, y: y)!
        if c.redComponent < 0.25 && c.blueComponent < 0.35 && c.greenComponent < 0.25 {
            skelMinX = min(skelMinX, x)
            skelMaxX = max(skelMaxX, x)
            skelMinY = min(skelMinY, y)
            skelMaxY = max(skelMaxY, y)
        }
    }
}
print("Skel orbit bbox: x: \(skelMinX)..\(skelMaxX) (w: \(skelMaxX - skelMinX + 1)), y: \(skelMinY)..\(skelMaxY) (h: \(skelMaxY - skelMinY + 1))")

print("Orbit scale X: \(Double(shotMaxX - shotMinX + 1) / Double(skelMaxX - skelMinX + 1))")
print("Orbit scale Y: \(Double(shotMaxY - shotMinY + 1) / Double(skelMaxY - skelMinY + 1))")
