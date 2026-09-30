import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

// Silhouette bounds
let silX: Double = 42.0
let silY: Double = 25.0
let silW: Double = 138.0
let silH: Double = 426.0

// Scan skull between y=25 and y=90, x=65..145
var skullMinX = rep.pixelsWide, skullMaxX = 0, skullMinY = rep.pixelsHigh, skullMaxY = 0

for y in 25...88 {
    for x in 70...140 {
        let c = rep.colorAt(x: x, y: y)!
        let r = c.redComponent
        let g = c.greenComponent
        let b = c.blueComponent
        
        let isWhite = r > 0.8 && g > 0.8 && b > 0.8
        let isBlue = b > 0.45 && b > r + 0.1
        let isDarkEye = r < 0.25 && g < 0.25 && b < 0.35
        
        if isWhite || isBlue || isDarkEye {
            skullMinX = min(skullMinX, x)
            skullMaxX = max(skullMaxX, x)
            skullMinY = min(skullMinY, y)
            skullMaxY = max(skullMaxY, y)
        }
    }
}

let skullW = skullMaxX - skullMinX + 1
let skullH = skullMaxY - skullMinY + 1
let skullCenterX = Double(skullMinX) + Double(skullW) / 2.0
let skullCenterY = Double(skullMinY) + Double(skullH) / 2.0

let relCenterX = (skullCenterX - silX) / silW * 100.0
let relCenterY = (skullCenterY - silY) / silH * 100.0
let relW = Double(skullW) / silW * 100.0
let relH = Double(skullH) / silH * 100.0

print(String(format: "Skull in screenshot: x: %d..%d (w:%d), y: %d..%d (h:%d)", skullMinX, skullMaxX, skullW, skullMinY, skullMaxY, skullH))
print(String(format: "Relative to silhouette (x:42..179, y:25..450):"))
print(String(format: "Center X: %.2f%%, Center Y: %.2f%%, Width: %.2f%%, Height: %.2f%%", relCenterX, relCenterY, relW, relH))
print(String(format: "Left: %.2f%%, Top: %.2f%%", (Double(skullMinX) - silX)/silW*100.0, (Double(skullMinY) - silY)/silH*100.0))

