import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

print("Scanning ankle column x=50 across top-down y=610..635:")
for y in 610...635 {
    let c = rep.colorAt(x: 50, y: y)!
    print("y=\(y): alpha=\(String(format: "%.2f", c.alphaComponent))")
}
