import Cocoa

guard let image = NSImage(contentsOfFile: "assets/MRIRemoteController.png"),
      let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    print("Failed to load")
    exit(1)
}

let width = cgImage.width
let height = cgImage.height
print("Width: \(width), Height: \(height)")

guard let dataProvider = cgImage.dataProvider,
      let data = dataProvider.data,
      let ptr = CFDataGetBytePtr(data) else {
    print("Failed data")
    exit(1)
}

let bytesPerPixel = cgImage.bitsPerPixel / 8
let bytesPerRow = cgImage.bytesPerRow

// Scan for red pixels: high R (R > 160), low G (G < 80), low B (B < 80)
var minX = width, maxX = 0, minY = height, maxY = 0
var redCount = 0

for y in 0..<height {
    for x in 0..<width {
        let offset = y * bytesPerRow + x * bytesPerPixel
        let r = Int(ptr[offset])
        let g = Int(ptr[offset + 1])
        let b = Int(ptr[offset + 2])
        let a = Int(ptr[offset + 3])
        if a > 50 && r > 150 && g < 90 && b < 90 {
            redCount += 1
            if x < minX { minX = x }
            if x > maxX { maxX = x }
            if y < minY { minY = y }
            if y > maxY { maxY = y }
        }
    }
}

print("Red pixel count: \(redCount)")
print(String(format: "Red button x: [%d, %d] (width: %d, center: %.4f / %.2f%%)", minX, maxX, maxX - minX, Double(minX + maxX)/2.0/Double(width), Double(minX + maxX)/2.0/Double(width)*100.0))
print(String(format: "Red button y: [%d, %d] (height: %d, center: %.4f / %.2f%%)", minY, maxY, maxY - minY, Double(minY + maxY)/2.0/Double(height), Double(minY + maxY)/2.0/Double(height)*100.0))
