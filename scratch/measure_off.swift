import Foundation
import CoreGraphics
import ImageIO

guard let imageSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: "scratch/switch_inspect.png") as CFURL, nil),
      let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
    exit(1)
}

let w = cgImage.width
let h = cgImage.height

guard let colorSpace = cgImage.colorSpace,
      let context = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    exit(1)
}
context.draw(cgImage, in: CGRect(x: 0, y: 0, width: w, height: h))
guard let pixelData = context.data else { exit(1) }
let buffer = pixelData.bindMemory(to: UInt8.self, capacity: w * h * 4)

// In cropped image, let's find the "OFF" text pixels.
// In "OFF", the text is dark green (r: ~0..40, g: ~100..160, b: ~40..100) inside the green rectangle.
// Let's print out the bounding box of the grey plate, the green inner area, and the "OFF" text.
var greyMinX = w, greyMaxX = 0, greyMinY = h, greyMaxY = 0
var greenMinX = w, greenMaxX = 0, greenMinY = h, greenMaxY = 0
var offMinX = w, offMaxX = 0, offMinY = h, offMaxY = 0
var onMinX = w, onMaxX = 0, onMinY = h, onMaxY = 0

for y in 0..<h {
    let cgY = h - 1 - y
    for x in 0..<w {
        let offset = (cgY * w + x) * 4
        let r = Int(buffer[offset])
        let g = Int(buffer[offset + 1])
        let b = Int(buffer[offset + 2])
        
        // Grey plate (r~160..200, g~160..200, b~160..200, difference between r,g,b is small)
        if abs(r - g) < 25 && abs(g - b) < 25 && r > 150 && r < 210 {
            if x < greyMinX { greyMinX = x }
            if x > greyMaxX { greyMaxX = x }
            if y < greyMinY { greyMinY = y }
            if y > greyMaxY { greyMaxY = y }
        }
        
        // Green switch area (g > 150 && g > r + 30)
        if g > 140 && g > r + 30 && g > b + 30 {
            if x < greenMinX { greenMinX = x }
            if x > greenMaxX { greenMaxX = x }
            if y < greenMinY { greenMinY = y }
            if y > greenMaxY { greenMaxY = y }
        }
        
        // "OFF" text is dark green in upper half (y < 120 in cropped coordinates)
        // Background green is around (0, 204, 85)
        // "OFF" text is around (0..30, 110..150, 40..80)
        if y < 110 && g < 155 && g > 90 && r < 50 && b < 100 {
            if x < offMinX { offMinX = x }
            if x > offMaxX { offMaxX = x }
            if y < offMinY { offMinY = y }
            if y > offMaxY { offMaxY = y }
        }
        
        // "ON" text is white (r>230, g>230, b>230) in lower half (y > 110)
        if y > 110 && r > 220 && g > 220 && b > 220 {
            if x < onMinX { onMinX = x }
            if x > onMaxX { onMaxX = x }
            if y < onMinY { onMinY = y }
            if y > onMaxY { onMaxY = y }
        }
    }
}

print("In cropped image (origin is at full image x: 1000, y: 70):")
print("Grey plate: x in [\(greyMinX), \(greyMaxX)], y in [\(greyMinY), \(greyMaxY)]")
print("Green area: x in [\(greenMinX), \(greenMaxX)], y in [\(greenMinY), \(greenMaxY)]")
print("OFF text:   x in [\(offMinX), \(offMaxX)], y in [\(offMinY), \(offMaxY)]")
print("ON text:    x in [\(onMinX), \(onMaxX)], y in [\(onMinY), \(onMaxY)]")

let fullOffCenterX = 1000 + Double(offMinX + offMaxX) / 2.0
let fullOffCenterY = 70 + Double(offMinY + offMaxY) / 2.0

let fullOnCenterX = 1000 + Double(onMinX + onMaxX) / 2.0
let fullOnCenterY = 70 + Double(onMinY + onMaxY) / 2.0

print("\nFull 1366x1024 Image Coordinates:")
print("OFF Center: x = \(fullOffCenterX) (ratio: \(fullOffCenterX / 1366.0)), y = \(fullOffCenterY) (ratio: \(fullOffCenterY / 1024.0))")
print("ON Center:  x = \(fullOnCenterX) (ratio: \(fullOnCenterX / 1366.0)), y = \(fullOnCenterY) (ratio: \(fullOnCenterY / 1024.0))")
