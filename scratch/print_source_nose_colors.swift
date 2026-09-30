import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

for y in stride(from: 480, through: 520, by: 3) {
    var line = String(format: "%3d: ", y)
    for x in stride(from: 820, through: 865, by: 2) {
        let c = repSkel.colorAt(x: x, y: y)!
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        let isPurple = (b > 0.6 && r > 0.30 && r < 0.45 && g > 0.18 && g < 0.30)
        let isDark = (r < 0.35 && b < 0.40 && g < 0.35)
        let isBone = (r > 0.78 && g > 0.78 && b > 0.78)
        let isBlue = (b > 0.38 && g > 0.32 && g > r + 0.03 && !isBone)
        if isDark { line += "#" }
        else if isBone { line += "O" }
        else if isBlue { line += "+" }
        else if isPurple { line += "." }
        else { line += "?" }
    }
    print(line)
}
