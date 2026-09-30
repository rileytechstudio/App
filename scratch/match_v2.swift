import Foundation
import CoreGraphics
import ImageIO

guard let s1 = CGImageSourceCreateWithURL(URL(fileURLWithPath: "scratch/crop_v1_box.png") as CFURL, nil),
      let i1 = CGImageSourceCreateImageAtIndex(s1, 0, nil),
      let s2 = CGImageSourceCreateWithURL(URL(fileURLWithPath: "scratch/video2_frames/frame_5s.png") as CFURL, nil),
      let i2 = CGImageSourceCreateImageAtIndex(s2, 0, nil) else {
    exit(1)
}

print("i1 size: \(i1.width)x\(i1.height)")
print("i2 size: \(i2.width)x\(i2.height)")

// Let's inspect the starfish at bottom left:
// In i1 (193x85): starfish is near x: 25, y: 75
// In i2 (1366x1024): starfish is near x: 25, y: 700?
// Let's find starfish in i2
let ptr2 = i2.dataProvider!.data.flatMap({ CFDataGetBytePtr($0) })!
let bpr2 = i2.bytesPerRow
let bpp2 = i2.bitsPerPixel / 8

// Starfish is orange/red: R > 200, G < 100, B < 80
var starX = 0, starY = 0, starCount = 0
for y in 0..<i2.height {
    for x in 0..<i2.width {
        let off = y * bpr2 + x * bpp2
        let r = ptr2[off], g = ptr2[off+1], b = ptr2[off+2]
        if r > 200 && g < 100 && b < 80 {
            starX += x
            starY += y
            starCount += 1
        }
    }
}
if starCount > 0 {
    print("Starfish in i2 at: x=\(starX/starCount), y=\(starY/starCount), pixels=\(starCount)")
}
