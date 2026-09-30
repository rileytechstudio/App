import AppKit

let shotUrl = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let shotRep = NSBitmapImageRep(data: NSImage(contentsOf: shotUrl)!.tiffRepresentation!)!

for y in 35...85 {
    var line = String(format: "%2d: ", y)
    for x in 75...140 {
        let c = shotRep.colorAt(x: x, y: y)!
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        let isBone = (r > 0.8 && g > 0.8 && b > 0.8)
        let isBlue = (r > 0.5 && g > 0.6 && b > 0.7 && !isBone)
        let isPink = (r > 0.7 && g < 0.6 && b > 0.7)
        let isDark = (r < 0.3 && b < 0.4)
        if isDark { line += "#" }
        else if isBone { line += "O" }
        else if isBlue { line += "+" }
        else if isPink { line += "." }
        else { line += " " }
    }
    print(line)
}
