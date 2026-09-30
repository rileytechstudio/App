import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

// Sample several points on the bone:
// In the middle of the canvas around y=500..1500
var boneMinX = rep.pixelsWide, boneMaxX = 0, boneMinY = rep.pixelsHigh, boneMaxY = 0

for y in 0..<rep.pixelsHigh {
    for x in 0..<rep.pixelsWide {
        let c = rep.colorAt(x: x, y: y)!
        let r = c.redComponent
        let g = c.greenComponent
        let b = c.blueComponent
        // White bone is > 0.9 on all channels
        if r > 0.85 && g > 0.85 && b > 0.85 {
            boneMinX = min(boneMinX, x)
            boneMaxX = max(boneMaxX, x)
            boneMinY = min(boneMinY, y)
            boneMaxY = max(boneMaxY, y)
        }
    }
}

print("White bone bounds in Older Boy Skeleton.png: x: \(boneMinX)..\(boneMaxX) (w: \(boneMaxX - boneMinX + 1)), y: \(boneMinY)..\(boneMaxY) (h: \(boneMaxY - boneMinY + 1))")

