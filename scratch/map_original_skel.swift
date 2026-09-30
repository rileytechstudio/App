import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

print("Image size: \(rep.pixelsWide) x \(rep.pixelsHigh)")

// In Older Boy Skeleton.png, let's find the exact bounding box of the whole skeleton:
var minX = rep.pixelsWide, maxX = 0, minY = rep.pixelsHigh, maxY = 0
for y in 0..<rep.pixelsHigh {
    for x in 0..<rep.pixelsWide {
        let c = rep.colorAt(x: x, y: y)!
        let r = c.redComponent
        let g = c.greenComponent
        let b = c.blueComponent
        
        let isWhite = r > 0.8 && g > 0.8 && b > 0.8
        let isCyan = b > 0.4 && g > 0.35 && g > r + 0.05
        let isEye = (r < 0.25 && g < 0.25 && b < 0.35 && y > 400 && y < 550 && x > 750 && x < 900)
        
        if isWhite || isCyan || isEye {
            minX = min(minX, x)
            maxX = max(maxX, x)
            minY = min(minY, y)
            maxY = max(maxY, y)
        }
    }
}

print(String(format: "Whole skeleton in Older Boy Skeleton.png: x: %d..%d (w:%d), y: %d..%d (h:%d)",
    minX, maxX, maxX - minX + 1, minY, maxY, maxY - minY + 1))
print(String(format: "Skeleton aspect (w/h): %.4f", Double(maxX - minX + 1) / Double(maxY - minY + 1)))

