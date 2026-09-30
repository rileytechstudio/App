import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: url)!.tiffRepresentation!)!

var minX = rep.pixelsWide, maxX = 0, minY = rep.pixelsHigh, maxY = 0
for y in 0..<rep.pixelsHigh {
    for x in 0..<rep.pixelsWide {
        let c = rep.colorAt(x: x, y: y)!
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        // Bone or dark cavity or blue background in ribs?
        if (r > 0.75 && g > 0.75 && b > 0.75) || (b > 0.35 && g > 0.3) || (r < 0.25 && g < 0.25 && b < 0.35 && x > 750 && x < 870 && y > 400 && y < 550) {
            minX = min(minX, x)
            maxX = max(maxX, x)
            minY = min(minY, y)
            maxY = max(maxY, y)
        }
    }
}
print("Skeleton bbox in Older Boy Skeleton.png:")
print("x: \(minX)..\(maxX) (w: \(maxX - minX + 1))")
print("y: \(minY)..\(maxY) (h: \(maxY - minY + 1))")
