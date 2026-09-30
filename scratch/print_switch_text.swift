import Foundation
import CoreGraphics
import ImageIO

guard let imageSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: "assets/MRIRoomLightsOn.png") as CFURL, nil),
      let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
    exit(1)
}
let width = cgImage.width
let height = cgImage.height

guard let colorSpace = cgImage.colorSpace,
      let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    exit(1)
}
context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
guard let pixelData = context.data else { exit(1) }
let buffer = pixelData.bindMemory(to: UInt8.self, capacity: width * height * 4)

// Let's sample a grid in x: 1070..1125, y: 120..220
print("--- SWITCH GRID (every 5 rows, every 3 cols) ---")
for imgY in stride(from: 120, through: 220, by: 4) {
    let cgY = height - 1 - imgY
    var row = String(format: "y=%3d (%.3f): ", imgY, Double(imgY)/Double(height))
    for x in stride(from: 1070, through: 1125, by: 3) {
        let offset = (cgY * width + x) * 4
        let r = Int(buffer[offset])
        let g = Int(buffer[offset + 1])
        let b = Int(buffer[offset + 2])
        // Let's classify:
        // Background green of switch is roughly (0..100, 180..230, 80..130)
        // Letters "OFF" or "ON"
        if r > 200 && g > 200 && b > 200 {
            row += "W" // white text
        } else if g < 150 && g > 80 {
            row += "D" // darker green / text
        } else if g >= 150 {
            row += "." // bright green
        } else {
            row += "?"
        }
    }
    print(row)
}
