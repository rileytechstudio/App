import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

print("Scanning y=610..630 for narrow bridge in front foot:")
for y in 610...630 {
    var pixels: [Int] = []
    for x in 30...90 {
        let c = rep.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            pixels.append(x)
        }
    }
    print("y=\(y): count=\(pixels.count) range=\(pixels.first ?? 0)..\(pixels.last ?? 0)")
}
