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

var minX = width, maxX = 0, minY = height, maxY = 0
for y in 715...760 {
    for x in 1150...1220 {
        let offset = y * bytesPerRow + x * bytesPerPixel
        let a = Int(ptr[offset + 3])
        let r = Int(ptr[offset])
        let g = Int(ptr[offset + 1])
        let b = Int(ptr[offset + 2])
        if a > 80 && r > 160 && r > (g + 50) && r > (b + 50) {
            if x < minX { minX = x }
            if x > maxX { maxX = x }
            if y < minY { minY = y }
            if y > maxY { maxY = y }
        }
    }
}

let centerX = Double(minX + maxX) / 2.0
let centerY = Double(minY + maxY) / 2.0

print(String(format: "RED POWER BUTTON on remote:"))
print(String(format: "  x: [%d, %d] (width: %d)", minX, maxX, maxX - minX))
print(String(format: "  y: [%d, %d] (height: %d)", minY, maxY, maxY - minY))
print(String(format: "  center X: %.1f px (%.4f / %.2f%%)", centerX, centerX / Double(width), centerX / Double(width) * 100.0))
print(String(format: "  center Y: %.1f px (%.4f / %.2f%%)", centerY, centerY / Double(height), centerY / Double(height) * 100.0))
