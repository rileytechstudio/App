import Foundation
import CoreGraphics
import ImageIO

guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: "scratch/old_video_frame5s.png") as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
    exit(1)
}

guard let dataProvider = image.dataProvider,
      let data = dataProvider.data,
      let ptr = CFDataGetBytePtr(data) else {
    exit(1)
}

let bpp = image.bitsPerPixel / 8
let bpr = image.bytesPerRow

// Scan non-white pixels in old video frame
var minX = image.width, maxX = 0, minY = image.height, maxY = 0
var count = 0
for y in 0..<image.height {
    for x in 0..<image.width {
        let offset = y * bpr + x * bpp
        let r = ptr[offset]
        let g = ptr[offset+1]
        let b = ptr[offset+2]
        if r < 250 || g < 250 || b < 250 {
            count += 1
            if x < minX { minX = x }
            if x > maxX { maxX = x }
            if y < minY { minY = y }
            if y > maxY { maxY = y }
        }
    }
}

print("Old video non-white count: \(count)")
print("Bounding box: x: [\(minX), \(maxX)], y: [\(minY), \(maxY)]")
print("Width: \(maxX - minX + 1), Height: \(maxY - minY + 1)")

// Print edges of this box
print("Top edge (y=\(minY)): RGB(\(ptr[minY * bpr + 683 * bpp]), \(ptr[minY * bpr + 683 * bpp + 1]), \(ptr[minY * bpr + 683 * bpp + 2]))")
print("Bottom edge (y=\(maxY)): RGB(\(ptr[maxY * bpr + 683 * bpp]), \(ptr[maxY * bpr + 683 * bpp + 1]), \(ptr[maxY * bpr + 683 * bpp + 2]))")
print("Left edge (x=\(minX)): RGB(\(ptr[100 * bpr + minX * bpp]), \(ptr[100 * bpr + minX * bpp + 1]), \(ptr[100 * bpr + minX * bpp + 2]))")
print("Right edge (x=\(maxX)): RGB(\(ptr[100 * bpr + maxX * bpp]), \(ptr[100 * bpr + maxX * bpp + 1]), \(ptr[100 * bpr + maxX * bpp + 2]))")

