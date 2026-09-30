import Foundation
import CoreGraphics
import ImageIO

guard let imageSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: "assets/MRIRoomLightsOn.png") as CFURL, nil),
      let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
    print("Failed to load image")
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

// Scan for switch plate bounding box (approx x: 1040..1160, y: 90..260)
// CGContext: y=0 is bottom, so imageY corresponds to cgY = height - 1 - imageY
// Let's print out the exact coordinates of "OFF" vs "ON"
// "OFF" is at the top of the switch, "ON" is at the bottom of the switch!
for imgY in stride(from: 95, through: 250, by: 5) {
    let cgY = height - 1 - imgY
    var line = String(format: "Y=%3d (%.3f): ", imgY, Double(imgY)/Double(height))
    var greenCount = 0
    var darkCount = 0
    var whiteCount = 0
    for imgX in 1050...1150 {
        let offset = (cgY * width + imgX) * 4
        let r = Int(buffer[offset])
        let g = Int(buffer[offset + 1])
        let b = Int(buffer[offset + 2])
        if g > 130 && r < 90 && b < 100 {
            greenCount += 1
        }
        if r < 80 && g < 110 && b < 110 {
            darkCount += 1
        }
        if r > 200 && g > 200 && b > 200 {
            whiteCount += 1
        }
    }
    line += "green=\(greenCount), dark=\(darkCount), white=\(whiteCount)"
    print(line)
}
