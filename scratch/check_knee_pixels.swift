import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!
let w = rep.pixelsWide
let h = rep.pixelsHigh

// Check pixels around front knee: x: 30..80, y: 490..510
print("Pixels around front knee x=35..65, y=498..505:")
for y in 498...505 {
    var row = ""
    for x in 40...60 {
        let c = rep.colorAt(x: x, y: y)!
        row += c.alphaComponent > 0.1 ? "#" : "."
    }
    print("y=\(y): \(row)")
}
