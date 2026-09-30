import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

print("Scanning ankle column x=50 across top-down y=580..680:")
for y in 580...680 {
    let c = rep.colorAt(x: 50, y: y)!
    if c.alphaComponent > 0.05 {
        print("y=\(y): alpha=\(String(format: "%.2f", c.alphaComponent)) r=\(String(format: "%.2f", c.redComponent))")
    } else {
        print("y=\(y): transparent")
    }
}
