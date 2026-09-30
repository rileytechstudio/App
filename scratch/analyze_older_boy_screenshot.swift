import AppKit

// Find the screenshot file in Anatomy Explorer
let fm = FileManager.default
let files = try! fm.contentsOfDirectory(atPath: "Anatomy Explorer")
let screenshotFile = files.first { $0.contains("Screenshot") && $0.contains("9.22.14") }!
print("Screenshot file: \(screenshotFile)")

let url = URL(fileURLWithPath: "Anatomy Explorer/\(screenshotFile)")
guard let img = NSImage(contentsOf: url),
      let rep = NSBitmapImageRep(data: img.tiffRepresentation!) else {
    exit(1)
}

let W = rep.pixelsWide
let H = rep.pixelsHigh
print("Screenshot dimensions: \(W) x \(H)")

// In screenshot, the silhouette is pink/magenta (#f080c0 / #e060c0 / high red, high blue, lower green)
// The background is purple (#5030a0)
// The bones are white/light blue

var silMinX = W, silMaxX = 0, silMinY = H, silMaxY = 0
var boneMinX = W, boneMaxX = 0, boneMinY = H, boneMaxY = 0

for y in 0..<H {
    for x in 0..<W {
        let c = rep.colorAt(x: x, y: y)!
        let isWhite = c.redComponent > 0.8 && c.greenComponent > 0.8 && c.blueComponent > 0.8
        let isBlue = c.blueComponent > 0.55 && c.redComponent < 0.45
        if isWhite || isBlue {
            boneMinX = min(boneMinX, x)
            boneMaxX = max(boneMaxX, x)
            boneMinY = min(boneMinY, y)
            boneMaxY = max(boneMaxY, y)
        }
        
        // Pink silhouette (high red, moderate green, high blue: r > 0.7, g < 0.6, b > 0.7)
        let isPink = c.redComponent > 0.65 && c.greenComponent < 0.65 && c.blueComponent > 0.65
        if isPink || isWhite || isBlue {
            silMinX = min(silMinX, x)
            silMaxX = max(silMaxX, x)
            silMinY = min(silMinY, y)
            silMaxY = max(silMaxY, y)
        }
    }
}

print(String(format: "Silhouette bounds: x: %d..%d (w:%d), y: %d..%d (h:%d), aspect: %.4f",
    silMinX, silMaxX, silMaxX - silMinX + 1, silMinY, silMaxY, silMaxY - silMinY + 1,
    Double(silMaxX - silMinX + 1) / Double(silMaxY - silMinY + 1)))

print(String(format: "Bone bounds: x: %d..%d (w:%d), y: %d..%d (h:%d), aspect: %.4f",
    boneMinX, boneMaxX, boneMaxX - boneMinX + 1, boneMinY, boneMaxY, boneMaxY - boneMinY + 1,
    Double(boneMaxX - boneMinX + 1) / Double(boneMaxY - boneMinY + 1)))

