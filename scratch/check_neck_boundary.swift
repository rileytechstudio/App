import AppKit

let url = URL(fileURLWithPath: "scratch/truth_assembled_scaled.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: url)!.tiffRepresentation!)!

print("Rows 95..120 in neck region:")
for y in 95...120 {
    var line = String(format: "y=%3d: ", y)
    for x in stride(from: 70, through: 110, by: 2) {
        let c = rep.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.1 {
            let isBlue = (c.blueComponent > 0.4 && c.greenComponent > 0.35 && c.redComponent < 0.8)
            let isBone = (c.redComponent > 0.8 && c.greenComponent > 0.8 && c.blueComponent > 0.8)
            let isDark = (c.redComponent < 0.35 && c.blueComponent < 0.45)
            if isDark { line += "#" }
            else if isBone { line += "O" }
            else if isBlue { line += "+" }
            else { line += "?" }
        } else {
            line += " "
        }
    }
    print(line)
}
