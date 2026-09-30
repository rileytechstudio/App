import Foundation
import CoreGraphics
import ImageIO

guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: "scratch/v1_5s.png") as CFURL, nil),
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

// Scan for non-white/non-glow pixels.
// Notice the rectangle is blue underwater scene (R < 150)
var minX = image.width, maxX = 0, minY = image.height, maxY = 0
for y in 0..<image.height {
    for x in 0..<image.width {
        let off = y * bpr + x * bpp
        let r = ptr[off]
        let g = ptr[off+1]
        let b = ptr[off+2]
        
        // The underwater scene has R < 160 or (B > 100 and G > 100 and R < 120)
        if r < 140 && (g > 70 || b > 70) {
            if x < minX { minX = x }
            if x > maxX { maxX = x }
            if y < minY { minY = y }
            if y > maxY { maxY = y }
        }
    }
}

print("Underwater box in v1_5s: x: [\(minX), \(maxX)], y: [\(minY), \(maxY)]")
print("Width: \(maxX - minX + 1), Height: \(maxY - minY + 1)")
print("Center: x = \(Double(minX + maxX)/2.0), y = \(Double(minY + maxY)/2.0)")

// Inspect the pixels around the edges of this box
for x in (minX - 3)...(minX + 3) {
    let off = 100 * bpr + x * bpp
    print("x = \(x): RGB(\(ptr[off]), \(ptr[off+1]), \(ptr[off+2]))")
}
for y in (minY - 3)...(minY + 3) {
    let off = y * bpr + 683 * bpp
    print("y = \(y): RGB(\(ptr[off]), \(ptr[off+1]), \(ptr[off+2]))")
}
for y in (maxY - 3)...(maxY + 3) {
    let off = y * bpr + 683 * bpp
    print("y = \(y): RGB(\(ptr[off]), \(ptr[off+1]), \(ptr[off+2]))")
}

