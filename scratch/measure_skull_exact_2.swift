import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

let silX: Double = 42.0
let silY: Double = 25.0
let silW: Double = 138.0
let silH: Double = 426.0

// In row y from 25 to 88, let's print for each row: minX and maxX of white bone!
for y in 25...88 {
    var minX = rep.pixelsWide, maxX = 0
    for x in 40...170 {
        let c = rep.colorAt(x: x, y: y)!
        let r = c.redComponent
        let g = c.greenComponent
        let b = c.blueComponent
        // Bone white: r>0.8, g>0.8, b>0.8
        // Bone blue/shadow: b>0.4, b>r+0.1
        // Eye socket: r<0.25, g<0.25, b<0.35, surrounded by bone
        let isWhite = r > 0.82 && g > 0.82 && b > 0.82
        let isCyan = b > 0.5 && b > r + 0.15 && g > 0.35
        let isEye = (r < 0.25 && g < 0.25 && b < 0.35 && x > 110 && x < 135)
        if isWhite || isCyan || isEye {
            minX = min(minX, x)
            maxX = max(maxX, x)
        }
    }
    if minX <= maxX {
        print(String(format: "y=%d: bone x: %d..%d (w:%d)", y, minX, maxX, maxX - minX + 1))
    }
}
