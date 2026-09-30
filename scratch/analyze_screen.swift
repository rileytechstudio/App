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
print("MRI Inside dimensions: \(width) x \(height)")

guard let dataProvider = image.dataProvider,
      let data = dataProvider.data,
      let ptr = CFDataGetBytePtr(data) else {
    print("Failed to get pixel data")
    exit(1)
}

let bpp = image.bitsPerPixel / 8
let bpr = image.bytesPerRow

// Look in the upper center area: x: 500..850, y: 30..200
// Print pixels across a horizontal line through the screen (e.g. y = 100)
print("Scanning horizontal line y = 100:")
var screenMinX = width
var screenMaxX = 0
for x in 500..<850 {
    let offset = 100 * bpr + x * bpp
    let r = ptr[offset]
    let g = ptr[offset + 1]
    let b = ptr[offset + 2]
    // The screen is cyan/blue/white: let's inspect the RGB values
    // Blue/cyan screen typically has high G and B, lower R or distinct color
}

// Let's sample a grid in x: 550..800, y: 50..180
for y in stride(from: 50, through: 170, by: 10) {
    var line = "y=\(y): "
    for x in stride(from: 570, through: 800, by: 20) {
        let offset = y * bpr + x * bpp
        let r = ptr[offset]
        let g = ptr[offset + 1]
        let b = ptr[offset + 2]
        line += "(\(r),\(g),\(b)) "
    }
    print(line)
}

