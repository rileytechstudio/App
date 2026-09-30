import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

print("Scanning left elbow column x=25 across y=235..260:")
for y in 235...260 {
    let c = rep.colorAt(x: 25, y: y)!
    print("y=\(y): alpha=\(String(format: "%.2f", c.alphaComponent)) r=\(String(format: "%.2f", c.redComponent))")
}
