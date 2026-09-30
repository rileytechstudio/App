import Foundation
import CoreGraphics
import ImageIO

guard let imageSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: "assets/MRIRoomLightsOn.png") as CFURL, nil),
      let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
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

// Sample central column of switch: say x = 1100
for imgY in stride(from: 95, through: 250, by: 4) {
    let cgY = height - 1 - imgY
    let x = 1100
    let offset = (cgY * width + x) * 4
    let r = buffer[offset]
    let g = buffer[offset + 1]
    let b = buffer[offset + 2]
    print(String(format: "Y=%3d (yRatio: %.3f): RGB=(%3d, %3d, %3d)", imgY, Double(imgY)/Double(height), r, g, b))
}
