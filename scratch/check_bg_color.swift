import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

print("Background samples:")
for (x, y) in [(100, 100), (500, 500), (1000, 200), (1400, 1400), (200, 1500)] {
    let c = repSkel.colorAt(x: x, y: y)!
    print(String(format: "At (%d, %d): r=%.4f, g=%.4f, b=%.4f (hex #%02X%02X%02X)", x, y, c.redComponent, c.greenComponent, c.blueComponent, Int(c.redComponent * 255), Int(c.greenComponent * 255), Int(c.blueComponent * 255)))
}
