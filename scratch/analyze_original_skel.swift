import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
guard let img = NSImage(contentsOf: url),
      let rep = NSBitmapImageRep(data: img.tiffRepresentation!) else {
    exit(1)
}

let W = rep.pixelsWide
let H = rep.pixelsHigh
print("Older Boy Skeleton.png dimensions: \(W) x \(H)")

// Find the faint silhouette
var silMinX = W, silMaxX = 0, silMinY = H, silMaxY = 0
// Find bone bounds
var boneMinX = W, boneMaxX = 0, boneMinY = H, boneMaxY = 0

// Sample background color at (10, 10)
let bg = rep.colorAt(x: 10, y: 10)!
print(String(format: "Sample bg color: r:%.3f, g:%.3f, b:%.3f", bg.redComponent, bg.greenComponent, bg.blueComponent))

for y in 0..<H {
    for x in 0..<W {
        let c = rep.colorAt(x: x, y: y)!
        let r = c.redComponent
        let g = c.greenComponent
        let b = c.blueComponent
        
        let diff = abs(r - bg.redComponent) + abs(g - bg.greenComponent) + abs(b - bg.blueComponent)
        
        // Bone: either bright white (r>0.8, g>0.8, b>0.8) or blue shading (b > r + 0.15) or dark socket inside skull (r<0.2, g<0.2, b<0.3 in upper half)
        let isBone = (r > 0.75 && g > 0.75 && b > 0.75) || (b > 0.4 && b > r + 0.15) || (r < 0.25 && g < 0.25 && b < 0.35 && y > 150 && y < 700 && x > 400 && x < 800)
        
        if isBone {
            boneMinX = min(boneMinX, x)
            boneMaxX = max(boneMaxX, x)
            boneMinY = min(boneMinY, y)
            boneMaxY = max(boneMaxY, y)
        }
        
        // Silhouette: slight color difference from background
        if diff > 0.03 {
            silMinX = min(silMinX, x)
            silMaxX = max(silMaxX, x)
            silMinY = min(silMinY, y)
            silMaxY = max(silMaxY, y)
        }
    }
}

print("Bone bounds in Older Boy Skeleton.png: x: \(boneMinX)..\(boneMaxX) (w: \(boneMaxX - boneMinX + 1)), y: \(boneMinY)..\(boneMaxY) (h: \(boneMaxY - boneMinY + 1))")
print("Silhouette bounds (if visible): x: \(silMinX)..\(silMaxX) (w: \(silMaxX - silMinX + 1)), y: \(silMinY)..\(silMaxY) (h: \(silMaxY - silMinY + 1))")

