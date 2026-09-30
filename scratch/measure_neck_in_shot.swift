import AppKit

let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let repShot = NSBitmapImageRep(data: NSImage(contentsOf: urlShot)!.tiffRepresentation!)!

// Let's print rows from y = 60 to 130 around x = 80..130 (normalized to 220x681)
// Scale: 681 / 426 = 1.5986
// Character x: 43, y: 25 in shot
print("Cervical spine and clavicles in shot:")
for y in 70...125 {
    var line = String(format: "y=%3d (normY=%5.1f): ", y, Double(y - 25) * 1.5986)
    var boneMinX = 999, boneMaxX = 0
    for x in 60...140 {
        let c = repShot.colorAt(x: x, y: y)!
        let isBone = (c.redComponent > 0.8 && c.greenComponent > 0.8 && c.blueComponent > 0.8) || (c.blueComponent > 0.6 && c.greenComponent > 0.6 && c.redComponent < 0.8)
        if isBone {
            boneMinX = min(boneMinX, x)
            boneMaxX = max(boneMaxX, x)
        }
    }
    if boneMinX <= boneMaxX {
        let normMinX = Double(boneMinX - 43) * (220.0 / 136.0)
        let normMaxX = Double(boneMaxX - 43) * (220.0 / 136.0)
        line += String(format: "x=%5.1f..%5.1f (w=%4.1f)", normMinX, normMaxX, normMaxX - normMinX)
    }
    print(line)
}
