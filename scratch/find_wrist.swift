import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

print("Scanning for gap in left wrist x: 0..80, y: 340..375:")
for y in 340...375 {
    var xs: [Int] = []
    for x in 0...80 {
        // Exclude pelvis (pelvis is x > 65)
        if x > 60 { continue }
        let c = rep.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            xs.append(x)
        }
    }
    print("y=\(y): count=\(xs.count) range=\(xs.first ?? 0)..\(xs.last ?? 0)")
}
