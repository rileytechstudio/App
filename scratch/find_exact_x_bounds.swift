import AppKit

let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let repShot = NSBitmapImageRep(data: NSImage(contentsOf: urlShot)!.tiffRepresentation!)!

var minX = 999, maxX = 0
for y in 33...447 {
    for x in 40...180 {
        let c = repShot.colorAt(x: x, y: y)!
        if c.redComponent > 0.8 && c.greenComponent > 0.8 && c.blueComponent > 0.8 {
            minX = min(minX, x)
            maxX = max(maxX, x)
        }
    }
}
let normMinX = Double(minX - 43) * (220.0 / 136.0)
let normMaxX = Double(maxX - 43) * (220.0 / 136.0)
print("X bounds in shot: x=\(minX)..\(maxX) (w=\(maxX - minX + 1)) -> norm: x=\(normMinX)..\(normMaxX) (w=\(normMaxX - normMinX + 1))")
