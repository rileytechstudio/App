import Foundation
import CoreGraphics
import ImageIO

guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: "MRI/MRI Inside.png") as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
    print("Failed to load MRI Inside.png")
    exit(1)
}

let width = image.width
let height = image.height
guard let dataProvider = image.dataProvider,
      let data = dataProvider.data,
      let ptr = CFDataGetBytePtr(data) else {
    exit(1)
}

let bpp = image.bitsPerPixel / 8
let bpr = image.bytesPerRow

// Outside wall color is around R: 175-185, G: 193-200, B: 202-208.
// Screen is darker: R < 150
var minX = width
var maxX = 0
var minY = height
var maxY = 0

for y in 40..<200 {
    for x in 550..<820 {
        let offset = y * bpr + x * bpp
        let r = Int(ptr[offset])
        let g = Int(ptr[offset + 1])
        let b = Int(ptr[offset + 2])
        
        // Check if inside screen (R < 155 and G < 192)
        if r < 155 && g < 192 {
            if x < minX { minX = x }
            if x > maxX { maxX = x }
            if y < minY { minY = y }
            if y > maxY { maxY = y }
        }
    }
}

print("Exact Screen Bounds in MRI Inside.png:")
print("x: [\(minX), \(maxX)], width: \(maxX - minX + 1)")
print("y: [\(minY), \(maxY)], height: \(maxY - minY + 1)")
print("Center: x = \(Double(minX + maxX) / 2.0), y = \(Double(minY + maxY) / 2.0)")

// Also check the border of the screen: is there a black border or bezel?
for y in (minY - 3)...(minY + 3) {
    let offset = y * bpr + 683 * bpp
    print("y=\(y) at center x=683: RGB(\(ptr[offset]), \(ptr[offset+1]), \(ptr[offset+2]))")
}

for x in (minX - 3)...(minX + 3) {
    let offset = 110 * bpr + x * bpp
    print("x=\(x) at center y=110: RGB(\(ptr[offset]), \(ptr[offset+1]), \(ptr[offset+2]))")
}

