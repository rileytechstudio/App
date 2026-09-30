import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

// Skull is around x: 700..850, y: 370..550
// Let's find dark pixels that are part of the skull (eye socket, nasal cavity)
// In eye socket (around x: 800..840, y: 440..480):
for y in 440...480 {
    for x in 800...840 {
        let c = rep.colorAt(x: x, y: y)!
        if c.blueComponent < 0.4 {
            print("Dark feature at (\(x), \(y)): r:\(c.redComponent), g:\(c.greenComponent), b:\(c.blueComponent)")
            break
        }
    }
}
