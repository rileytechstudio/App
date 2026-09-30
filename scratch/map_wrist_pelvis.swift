import AppKit

let urlSkel = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

print("Scanning left wrist vs pelvis region x: 35..75, y: 330..370:")
for y in 330...370 {
    var s = ""
    for x in 35...75 {
        let c = rep.colorAt(x: x, y: y)!
        if c.alphaComponent < 0.1 {
            s += " "
        } else if c.redComponent > 0.8 && c.blueComponent > 0.8 && c.greenComponent > 0.8 {
            s += "." // white bone fill
        } else {
            s += "#" // border / shadow
        }
    }
    print(String(format: "%3d: %@", y, s))
}
