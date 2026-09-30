import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let imgSkel = NSImage(contentsOf: urlSkel)!
let repSkel = NSBitmapImageRep(data: imgSkel.tiffRepresentation!)!

print("Scanning for dark pixels (r < 0.25, g < 0.25, b < 0.35) in head (x: 650..950, y: 360..580):")
var count = 0
for y in 360...580 {
    for x in 650...950 {
        let c = repSkel.colorAt(x: x, y: y)!
        if c.redComponent < 0.25 && c.greenComponent < 0.25 && c.blueComponent < 0.35 {
            if count < 10 {
                print(String(format: "Dark at (%d, %d): r:%.3f, g:%.3f, b:%.3f", x, y, c.redComponent, c.greenComponent, c.blueComponent))
            }
            count += 1
        }
    }
}
print("Total dark pixels found in head: \(count)")

