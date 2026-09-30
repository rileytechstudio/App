import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

var boneMinX = rep.pixelsWide, boneMaxX = 0, boneMinY = rep.pixelsHigh, boneMaxY = 0
for y in 0..<rep.pixelsHigh {
    for x in 0..<rep.pixelsWide {
        let c = rep.colorAt(x: x, y: y)!
        let r = c.redComponent
        let g = c.greenComponent
        let b = c.blueComponent
        if r > 0.85 && g > 0.85 && b > 0.85 {
            boneMinX = min(boneMinX, x)
            boneMaxX = max(boneMaxX, x)
            boneMinY = min(boneMinY, y)
            boneMaxY = max(boneMaxY, y)
        }
    }
}

print("White bone bounds in Screenshot: x: \(boneMinX)..\(boneMaxX) (w: \(boneMaxX - boneMinX + 1)), y: \(boneMinY)..\(boneMaxY) (h: \(boneMaxY - boneMinY + 1))")

