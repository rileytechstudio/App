import AppKit

let url = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790692100225.png")
guard let img = NSImage(contentsOf: url),
      let rep = NSBitmapImageRep(data: img.tiffRepresentation!) else {
    print("Could not load image")
    exit(1)
}

print("Uploaded image dimensions: \(rep.pixelsWide) x \(rep.pixelsHigh)")
print("Samples per pixel: \(rep.samplesPerPixel), hasAlpha: \(rep.hasAlpha)")

// Let's find bounding box of character and skeleton:
var cMinX = rep.pixelsWide, cMaxX = 0, cMinY = rep.pixelsHigh, cMaxY = 0
var sMinX = rep.pixelsWide, sMaxX = 0, sMinY = rep.pixelsHigh, sMaxY = 0

for y in 0..<rep.pixelsHigh {
    for x in 0..<rep.pixelsWide {
        let c = rep.colorAt(x: x, y: y)!
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        // Is it white background? (r > 0.98 && g > 0.98 && b > 0.98) or transparent?
        let isWhite = (r > 0.98 && g > 0.98 && b > 0.98)
        let isTransparent = c.alphaComponent < 0.05
        
        if !isWhite && !isTransparent {
            // Non-background pixel!
            cMinX = min(cMinX, x)
            cMaxX = max(cMaxX, x)
            cMinY = min(cMinY, y)
            cMaxY = max(cMaxY, y)
        }
    }
}

print("Character + Skeleton bbox: x: \(cMinX)..\(cMaxX) (w: \(cMaxX - cMinX + 1)), y: \(cMinY)..\(cMaxY) (h: \(cMaxY - cMinY + 1))")
