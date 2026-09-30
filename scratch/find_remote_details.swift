import Cocoa

guard let image = NSImage(contentsOfFile: "assets/MRIRemoteController.png"),
      let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    exit(1)
}

let width = cgImage.width
let height = cgImage.height

guard let dataProvider = cgImage.dataProvider,
      let data = dataProvider.data,
      let ptr = CFDataGetBytePtr(data) else {
    exit(1)
}

let bytesPerPixel = cgImage.bitsPerPixel / 8
let bytesPerRow = cgImage.bytesPerRow

// Find bounding box of entire remote controller (non-transparent pixels)
var minX = width, maxX = 0, minY = height, maxY = 0
for y in 0..<height {
    for x in 0..<width {
        let offset = y * bytesPerRow + x * bytesPerPixel
        let a = ptr[offset + 3]
        if a > 20 {
            if x < minX { minX = x }
            if x > maxX { maxX = x }
            if y < minY { minY = y }
            if y > maxY { maxY = y }
        }
    }
}
print("Remote BBox: x: [\(minX), \(maxX)] (%.1f%% - %.1f%%)", Double(minX)/Double(width)*100, Double(maxX)/Double(width)*100)
print("             y: [\(minY), \(maxY)] (%.1f%% - %.1f%%)", Double(minY)/Double(height)*100, Double(maxY)/Double(height)*100)

// Find the red button:
// Check pixels with High R vs G and B (e.g. R > G + 50 and R > B + 50)
var bMinX = width, bMaxX = 0, bMinY = height, bMaxY = 0
for y in minY...maxY {
    for x in minX...maxX {
        let offset = y * bytesPerRow + x * bytesPerPixel
        let a = Int(ptr[offset + 3])
        let r = Int(ptr[offset])
        let g = Int(ptr[offset + 1])
        let b = Int(ptr[offset + 2])
        if a > 100 && r > 160 && r > (g + 60) && r > (b + 60) {
            if x < bMinX { bMinX = x }
            if x > bMaxX { bMaxX = x }
            if y < bMinY { bMinY = y }
            if y > bMaxY { bMaxY = y }
        }
    }
}
print(String(format: "Strong Red Button: x: [%d, %d] (width: %d, center: %.4f / %.2f%%)", bMinX, bMaxX, bMaxX - bMinX, Double(bMinX + bMaxX)/2.0/Double(width), Double(bMinX + bMaxX)/2.0/Double(width)*100.0))
print(String(format: "                   y: [%d, %d] (height: %d, center: %.4f / %.2f%%)", bMinY, bMaxY, bMaxY - bMinY, Double(bMinY + bMaxY)/2.0/Double(height), Double(bMinY + bMaxY)/2.0/Double(height)*100.0))
