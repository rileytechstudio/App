import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let imgSkel = NSImage(contentsOf: urlSkel)!
let repSkel = NSBitmapImageRep(data: imgSkel.tiffRepresentation!)!

let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let imgShot = NSImage(contentsOf: urlShot)!
let repShot = NSBitmapImageRep(data: imgShot.tiffRepresentation!)!

print("Skel image: \(repSkel.pixelsWide) x \(repSkel.pixelsHigh)")
print("Screenshot image: \(repShot.pixelsWide) x \(repShot.pixelsHigh)")

// Let's find the skull in Older Boy Skeleton.png
// Skull is at the top of the skeleton: y: 370..580, x: 700..900
var skelMinX = repSkel.pixelsWide, skelMaxX = 0, skelMinY = repSkel.pixelsHigh, skelMaxY = 0
for y in 370...580 {
    for x in 700...950 {
        let c = repSkel.colorAt(x: x, y: y)!
        let isWhite = c.redComponent > 0.85 && c.greenComponent > 0.85 && c.blueComponent > 0.85
        let isBlue = c.blueComponent > 0.4 && c.blueComponent > c.redComponent + 0.15
        let isEye = c.redComponent < 0.25 && c.greenComponent < 0.25 && c.blueComponent < 0.35
        if isWhite || isBlue || isEye {
            skelMinX = min(skelMinX, x)
            skelMaxX = max(skelMaxX, x)
            skelMinY = min(skelMinY, y)
            skelMaxY = max(skelMaxY, y)
        }
    }
}

print(String(format: "Skull in Older Boy Skeleton.png: x: %d..%d (w:%d), y: %d..%d (h:%d)",
    skelMinX, skelMaxX, skelMaxX - skelMinX + 1, skelMinY, skelMaxY, skelMaxY - skelMinY + 1))

// In Screenshot:
// We saw skull is y: 33..82, x: 80..135
// Let's measure aspect ratio of skull in both:
let skelW = skelMaxX - skelMinX + 1
let skelH = skelMaxY - skelMinY + 1
print(String(format: "Skel skull aspect: %.4f (w/h)", Double(skelW) / Double(skelH)))

let shotW = 135 - 80 + 1
let shotH = 82 - 33 + 1
print(String(format: "Shot skull aspect: %.4f (w/h)", Double(shotW) / Double(shotH)))

