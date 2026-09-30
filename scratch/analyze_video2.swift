import Foundation
import CoreGraphics
import ImageIO

guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: "scratch/video2_frames/frame_5s.png") as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
    print("Failed to load frame_5s.png")
    exit(1)
}

let width = image.width
let height = image.height
print("Width: \(width), Height: \(height)")

guard let dataProvider = image.dataProvider,
      let data = dataProvider.data,
      let ptr = CFDataGetBytePtr(data) else {
    print("Failed to get pixel data")
    exit(1)
}

let bytesPerPixel = image.bitsPerPixel / 8
let bytesPerRow = image.bytesPerRow

var minX = width
var maxX = 0
var minY = height
var maxY = 0

// Find pixels that are NOT pure white (255, 255, 255) and NOT near white (> 245)
var nonWhiteCount = 0
for y in 0..<height {
    for x in 0..<width {
        let offset = y * bytesPerRow + x * bytesPerPixel
        let r = ptr[offset]
        let g = ptr[offset + 1]
        let b = ptr[offset + 2]
        
        // Check if not white
        if r < 240 || g < 240 || b < 240 {
            nonWhiteCount += 1
            if x < minX { minX = x }
            if x > maxX { maxX = x }
            if y < minY { minY = y }
            if y > maxY { maxY = y }
        }
    }
}

print("Non-white pixels: \(nonWhiteCount)")
print("Bounding box of non-white: x in [\(minX), \(maxX)], y in [\(minY), \(maxY)]")
print("Box width: \(maxX - minX + 1), Box height: \(maxY - minY + 1)")

// Sample corner pixels
func printPixel(x: Int, y: Int, label: String) {
    let offset = y * bytesPerRow + x * bytesPerPixel
    let r = ptr[offset]
    let g = ptr[offset + 1]
    let b = ptr[offset + 2]
    print("\(label) at (\(x), \(y)): RGB(\(r), \(g), \(b))")
}

printPixel(x: 0, y: 0, label: "Top-Left")
printPixel(x: width - 1, y: 0, label: "Top-Right")
printPixel(x: 0, y: height - 1, label: "Bottom-Left")
printPixel(x: width / 2, y: height / 2, label: "Center")
printPixel(x: 683, y: 109, label: "Blue screen center")
