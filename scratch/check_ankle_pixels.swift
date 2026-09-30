import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

print("Pixels around front ankle x=30..60, y=610..625:")
for y in 610...625 {
    var row = ""
    for x in 30...60 {
        let c = rep.colorAt(x: x, y: y)!
        row += c.alphaComponent > 0.1 ? "#" : "."
    }
    print("y=\(y): \(row)")
}
