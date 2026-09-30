import AppKit

let url = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790613333821.png")
guard let image = NSImage(contentsOf: url),
      let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff) else {
    print("Failed to load image")
    exit(1)
}

let w = rep.pixelsWide
let h = rep.pixelsHigh
print("Image width: \(w), height: \(h)")

// Find the character silhouette bounding box in this image.
// Silhouette color is greenish/yellowish, purple background.
// Background purple is roughly R=75, G=45, B=140 or similar.
// Let's sample corners:
let cornerColor = rep.colorAt(x: 10, y: 10)!
print("Corner color: R:\(cornerColor.redComponent) G:\(cornerColor.greenComponent) B:\(cornerColor.blueComponent)")

var minX = w, maxX = 0, minY = h, maxY = 0

for y in 0..<h {
    for x in 0..<w {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        // If not purple background (check difference from corner color)
        let diff = abs(c.redComponent - cornerColor.redComponent) +
                   abs(c.greenComponent - cornerColor.greenComponent) +
                   abs(c.blueComponent - cornerColor.blueComponent)
        // If significantly different, it's character silhouette or bone
        if diff > 0.2 {
            if x < minX { minX = x }
            if x > maxX { maxX = x }
            if y < minY { minY = y }
            if y > maxY { maxY = y }
        }
    }
}

print("Character bounds in image: minX: \(minX), maxX: \(maxX), minY: \(minY), maxY: \(maxY)")
print("Character width: \(maxX - minX + 1), height: \(maxY - minY + 1)")
print("Character aspect: \(Double(maxX - minX + 1) / Double(maxY - minY + 1))")
