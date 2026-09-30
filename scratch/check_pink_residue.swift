import AppKit

let url = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: url)!.tiffRepresentation!)!

var pinkCount = 0
for y in 0..<rep.pixelsHigh {
    for x in 0..<rep.pixelsWide {
        let c = rep.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
            if r > 0.85 && g < 0.65 && b > 0.85 {
                pinkCount += 1
            }
        }
    }
}
print("Residual pink pixels: \(pinkCount)")
