import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

// Skull in Older Boy Skeleton is at x: 700..865, y: 370..540
// Let's sample every 4 pixels in x and y to get ~42x42 grid
for y in stride(from: 370, through: 540, by: 4) {
    var line = String(format: "%3d: ", y)
    for x in stride(from: 700, through: 865, by: 4) {
        let c = repSkel.colorAt(x: x, y: y)!
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        let isBone = (r > 0.78 && g > 0.78 && b > 0.78)
        let isBlue = (b > 0.38 && g > 0.32 && g > r + 0.03 && !isBone)
        let isDark = (r < 0.25 && b < 0.35 && g < 0.25)
        if isDark { line += "#" }
        else if isBone { line += "O" }
        else if isBlue { line += "+" }
        else { line += " " }
    }
    print(line)
}
