import AppKit

let shotUrl = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let shotRep = NSBitmapImageRep(data: NSImage(contentsOf: shotUrl)!.tiffRepresentation!)!

// Find the bounding box of character (pink) and skeleton (white/bone)
var pMinX = 9999, pMaxX = 0, pMinY = 9999, pMaxY = 0
var bMinX = 9999, bMaxX = 0, bMinY = 9999, bMaxY = 0
var sMinX = 9999, sMaxX = 0, sMinY = 9999, sMaxY = 0 // skull

for y in 0..<shotRep.pixelsHigh {
    for x in 0..<shotRep.pixelsWide {
        let c = shotRep.colorAt(x: x, y: y)!
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        // Pink character: high r, low g, high b (e.g. r > 0.8, g < 0.6, b > 0.8)
        let isPink = (r > 0.7 && g < 0.6 && b > 0.7)
        // White bone: high r, high g, high b (r > 0.8, g > 0.8, b > 0.8)
        let isBone = (r > 0.8 && g > 0.8 && b > 0.8) || (r > 0.6 && g > 0.7 && b > 0.8) // blue shaded bone
        
        if isPink || isBone {
            pMinX = min(pMinX, x)
            pMaxX = max(pMaxX, x)
            pMinY = min(pMinY, y)
            pMaxY = max(pMaxY, y)
        }
        if isBone {
            bMinX = min(bMinX, x)
            bMaxX = max(bMaxX, x)
            bMinY = min(bMinY, y)
            bMaxY = max(bMaxY, y)
            if y < 100 {
                sMinX = min(sMinX, x)
                sMaxX = max(sMaxX, x)
                sMinY = min(sMinY, y)
                sMaxY = max(sMaxY, y)
            }
        }
    }
}

print("Screenshot Character bbox: x: \(pMinX)..\(pMaxX) (w: \(pMaxX - pMinX + 1)), y: \(pMinY)..\(pMaxY) (h: \(pMaxY - pMinY + 1))")
print("Screenshot Skeleton bbox: x: \(bMinX)..\(bMaxX) (w: \(bMaxX - bMinX + 1)), y: \(bMinY)..\(bMaxY) (h: \(bMaxY - bMinY + 1))")
print("Screenshot Skull bbox: x: \(sMinX)..\(sMaxX) (w: \(sMaxX - sMinX + 1)), y: \(sMinY)..\(sMaxY) (h: \(sMaxY - sMinY + 1))")
