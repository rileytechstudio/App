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

// Find bright green pixels: g > 160 && g > r + 40 && g > b + 40
var minX = width, maxX = 0, minY = height, maxY = 0
var count = 0
for y in 0..<height {
    let cgY = height - 1 - y
    for x in 0..<width {
        let offset = (cgY * width + x) * 4
        let r = Int(buffer[offset])
        let g = Int(buffer[offset + 1])
        let b = Int(buffer[offset + 2])
        if g > 150 && g > r + 30 && g > b + 30 {
            count += 1
            if x < minX { minX = x }
            if x > maxX { maxX = x }
            if y < minY { minY = y }
            if y > maxY { maxY = y }
        }
    }
}
print("Bright green pixels count: \(count)")
print("X range: \(minX) .. \(maxX) (ratio: \(Double(minX)/Double(width)) .. \(Double(maxX)/Double(width)))")
print("Y range: \(minY) .. \(maxY) (ratio: \(Double(minY)/Double(height)) .. \(Double(maxY)/Double(height)))")
