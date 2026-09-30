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

// Scan vertically down the center line x = 683 from y = 50 to 180
print("--- Vertical Scan at x = 683 ---")
for y in 55...170 {
    let offset = y * bpr + 683 * bpp
    let r = ptr[offset]
    let g = ptr[offset+1]
    let b = ptr[offset+2]
    if (y >= 60 && y <= 72) || (y >= 145 && y <= 160) {
        print("y = \(y): RGB(\(r), \(g), \(b))")
    }
}

// Scan horizontally across the middle line y = 110 from x = 570 to 800
print("--- Horizontal Scan at y = 110 ---")
for x in 570...800 {
    let offset = 110 * bpr + x * bpp
    let r = ptr[offset]
    let g = ptr[offset+1]
    let b = ptr[offset+2]
    if (x >= 575 && x <= 595) || (x >= 770 && x <= 790) {
        print("x = \(x): RGB(\(r), \(g), \(b))")
    }
}
