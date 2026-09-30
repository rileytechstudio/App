import Foundation
import CoreGraphics
import ImageIO

guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: "MRI/MRI Inside.png") as CFURL, nil),
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

// Scan the outer trapezoid/screen in y: 0..250, x: 450..900
// Wall color around MRI bore is RGB(~230..245) or RGB(~175..185)
// Let us scan horizontal slices across y = 40, y = 70, y = 110, y = 150, y = 170, y = 200
for y in stride(from: 30, through: 210, by: 15) {
    var minX = image.width, maxX = 0
    for x in 450..<900 {
        let off = y * bpr + x * bpp
        let r = ptr[off], g = ptr[off+1], b = ptr[off+2]
        // The screen panel is darker than the bright ceiling/bore
        // Let us print RGB at center and at edges
    }
}

// Print pixel colors along y from 0 to 250 at center x = 683
print("--- Vertical profile at x = 683 ---")
for y in stride(from: 0, through: 220, by: 10) {
    let off = y * bpr + 683 * bpp
    print("y = \(y): RGB(\(ptr[off]), \(ptr[off+1]), \(ptr[off+2]))")
}
