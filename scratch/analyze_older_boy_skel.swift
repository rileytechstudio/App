import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
guard let img = NSImage(contentsOf: url),
      let rep = NSBitmapImageRep(data: img.tiffRepresentation!) else {
    print("Failed to load")
    exit(1)
}

let W = rep.pixelsWide
let H = rep.pixelsHigh
print("Image dimensions: \(W) x \(H)")

// Check corners
for pt in [(0, 0), (W-1, 0), (0, H-1), (W-1, H-1)] {
    let c = rep.colorAt(x: pt.0, y: pt.1)!
    print("Corner (\(pt.0), \(pt.1)): alpha: \(c.alphaComponent), r:\(c.redComponent), g:\(c.greenComponent), b:\(c.blueComponent)")
}

// Find non-purple pixels (bone colors are white/blue)
// Background purple is around r: 0.35..0.45, g: 0.20..0.30, b: 0.65..0.75
var minX = W, maxX = 0, minY = H, maxY = 0
var bonePixels = 0

for y in 0..<H {
    for x in 0..<W {
        let c = rep.colorAt(x: x, y: y)!
        // Let's see if pixel is bone:
        // White bone: r, g, b all high (> 0.75)
        // Blue joint shading: b > 0.6, r < 0.3, g < 0.6
        // Blue outline: b > 0.5, r < 0.4
        // Whereas background purple: r is ~0.4, b is ~0.7, g is ~0.25 (r > g)
        let isWhite = c.redComponent > 0.65 && c.greenComponent > 0.65 && c.blueComponent > 0.65
        let isBlueShading = c.blueComponent > 0.5 && c.greenComponent > 0.3 && c.redComponent < 0.3
        let isOutline = c.blueComponent > 0.5 && c.greenComponent > 0.25 && c.redComponent < 0.25
        if isWhite || isBlueShading || isOutline {
            bonePixels += 1
            minX = min(minX, x)
            maxX = max(maxX, x)
            minY = min(minY, y)
            maxY = max(maxY, y)
        }
    }
}

print("Bone pixels found: \(bonePixels)")
print("Bounding box: x: \(minX)..\(maxX) (w: \(maxX - minX + 1)), y: \(minY)..\(maxY) (h: \(maxY - minY + 1))")
