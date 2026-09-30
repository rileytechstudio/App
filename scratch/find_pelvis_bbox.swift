import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

var minX = 9999, maxX = 0
for y in 935...1080 {
    for x in 600...950 {
        let c = repSkel.colorAt(x: x, y: y)!
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        if (r > 0.78 && g > 0.78 && b > 0.78) || (b > 0.38 && g > 0.32 && g > r + 0.03) {
            minX = min(minX, x)
            maxX = max(maxX, x)
        }
    }
}
print("Pelvis true bbox in source: x: \(minX)..\(maxX) (w: \(maxX - minX + 1))")
