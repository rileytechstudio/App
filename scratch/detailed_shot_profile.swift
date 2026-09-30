import AppKit

let shotUrl = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let shotRep = NSBitmapImageRep(data: NSImage(contentsOf: shotUrl)!.tiffRepresentation!)!

// Scan every row from y=25 to y=450 in screenshot, find minX and maxX of bone
print("y | minX..maxX | width | notes")
for y in stride(from: 30, through: 450, by: 10) {
    var minX = 999, maxX = -1
    for x in 40...180 {
        let c = shotRep.colorAt(x: x, y: y)!
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        // White bone or blue shaded bone
        let isBone = (r > 0.75 && g > 0.75 && b > 0.75) || (r > 0.55 && g > 0.65 && b > 0.75)
        if isBone {
            minX = min(minX, x)
            maxX = max(maxX, x)
        }
    }
    if minX <= maxX {
        print(String(format: "%3d | %3d..%3d | w=%2d", y, minX, maxX, maxX - minX + 1))
    } else {
        print(String(format: "%3d | none", y))
    }
}
