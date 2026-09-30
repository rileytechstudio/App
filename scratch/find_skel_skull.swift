import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let imgSkel = NSImage(contentsOf: urlSkel)!
let repSkel = NSBitmapImageRep(data: imgSkel.tiffRepresentation!)!

for y in 365...560 {
    var minX = repSkel.pixelsWide, maxX = 0
    for x in 600...1100 {
        let c = repSkel.colorAt(x: x, y: y)!
        let r = c.redComponent
        let g = c.greenComponent
        let b = c.blueComponent
        let isWhite = r > 0.85 && g > 0.85 && b > 0.85
        let isBlue = b > 0.4 && b > r + 0.15
        let isEye = (r < 0.25 && g < 0.25 && b < 0.35 && x > 800 && x < 900)
        if isWhite || isBlue || isEye {
            minX = min(minX, x)
            maxX = max(maxX, x)
        }
    }
    if minX <= maxX {
        if y % 15 == 0 || y == 365 || y == 560 {
            print(String(format: "y=%d: bone x: %d..%d (w:%d)", y, minX, maxX, maxX - minX + 1))
        }
    }
}
