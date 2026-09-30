import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

print("Scanning for gap in left arm x: 0..60, y: 220..270:")
for y in 220...270 {
    var xs: [Int] = []
    for x in 0...60 {
        let c = rep.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            xs.append(x)
        }
    }
    print("y=\(y): count=\(xs.count) range=\(xs.first ?? 0)..\(xs.last ?? 0)")
}
