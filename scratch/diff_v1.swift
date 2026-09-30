import Foundation
import CoreGraphics
import ImageIO

guard let s1 = CGImageSourceCreateWithURL(URL(fileURLWithPath: "scratch/v1_2s.png") as CFURL, nil),
      let i1 = CGImageSourceCreateImageAtIndex(s1, 0, nil),
      let s2 = CGImageSourceCreateWithURL(URL(fileURLWithPath: "scratch/v1_6s.png") as CFURL, nil),
      let i2 = CGImageSourceCreateImageAtIndex(s2, 0, nil) else {
    exit(1)
}

guard let p1 = i1.dataProvider?.data.flatMap({ CFDataGetBytePtr($0) }),
      let p2 = i2.dataProvider?.data.flatMap({ CFDataGetBytePtr($0) }) else {
    exit(1)
}

let bpp = i1.bitsPerPixel / 8
let bpr = i1.bytesPerRow

var minX = i1.width, maxX = 0, minY = i1.height, maxY = 0
var changeCount = 0

for y in 0..<i1.height {
    for x in 0..<i1.width {
        let off = y * bpr + x * bpp
        let diff = abs(Int(p1[off]) - Int(p2[off])) +
                   abs(Int(p1[off+1]) - Int(p2[off+1])) +
                   abs(Int(p1[off+2]) - Int(p2[off+2]))
        if diff > 15 {
            changeCount += 1
            if x < minX { minX = x }
            if x > maxX { maxX = x }
            if y < minY { minY = y }
            if y > maxY { maxY = y }
        }
    }
}

print("Pixels changing between 2s and 6s in MRI Video.mp4: \(changeCount)")
print("Bounding box of movement: x: [\(minX), \(maxX)], y: [\(minY), \(maxY)]")
print("Width: \(maxX - minX + 1), Height: \(maxY - minY + 1)")
