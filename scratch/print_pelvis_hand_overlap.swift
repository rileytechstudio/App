import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

for y in stride(from: 930, through: 1080, by: 5) {
    var line = String(format: "%4d: ", y)
    for x in stride(from: 800, through: 950, by: 4) {
        let c = repSkel.colorAt(x: x, y: y)!
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        let isBone = (r > 0.78 && g > 0.78 && b > 0.78)
        let isBlue = (b > 0.38 && g > 0.32 && g > r + 0.03 && !isBone)
        if isBone { line += "O" }
        else if isBlue { line += "+" }
        else { line += " " }
    }
    print(line)
}
