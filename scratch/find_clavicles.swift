import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

print("Scanning for clavicles (collarbones) in Older Boy Skeleton.png:")
for y in 580...650 {
    var minX = repSkel.pixelsWide, maxX = 0
    for x in 600...900 {
        let c = repSkel.colorAt(x: x, y: y)!
        if c.redComponent > 0.8 && c.greenComponent > 0.8 && c.blueComponent > 0.8 {
            minX = min(minX, x)
            maxX = max(maxX, x)
        }
    }
    if minX <= maxX {
        print(String(format: "y=%d: bone x: %d..%d (w:%d)", y, minX, maxX, maxX - minX + 1))
    }
}
