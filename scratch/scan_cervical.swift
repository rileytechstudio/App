import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

print("Scanning cervical spine pixels y=90..150:")
for y in 90...150 {
    var xs: [Int] = []
    for x in 55...110 {
        // Exclude skull
        if y < 112 && (x > 88 || (x > 80 && y < 98)) { continue }
        let c = rep.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            xs.append(x)
        }
    }
    print("y=\(y): count=\(xs.count) range=\(xs.first ?? 0)..\(xs.last ?? 0)")
}
