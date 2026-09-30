import AppKit

let url = URL(fileURLWithPath: "assets/bones/Bone_older_boy_skull.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

print("Skull asset dimensions: \(rep.pixelsWide) x \(rep.pixelsHigh)")
// Let's find any non-alpha=0 pixel in the middle right
var solidCount = 0
var transCount = 0
for y in 0..<rep.pixelsHigh {
    for x in 0..<rep.pixelsWide {
        let c = rep.colorAt(x: x, y: y)!
        if c.alphaComponent < 0.1 {
            transCount += 1
        } else {
            solidCount += 1
            if c.redComponent < 0.3 && c.greenComponent < 0.3 && c.blueComponent < 0.4 {
                print(String(format: "Dark pixel at (%d, %d): r:%.3f, g:%.3f, b:%.3f, a:%.3f", x, y, c.redComponent, c.greenComponent, c.blueComponent, c.alphaComponent))
            }
        }
    }
}
print("Solid: \(solidCount), Trans: \(transCount)")
