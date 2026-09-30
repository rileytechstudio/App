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

print("Analyzing switch inside imgX 1066..1132, imgY 110..235:")
for imgY in 115...230 {
    let cgY = height - 1 - imgY
    var darkTextPixels = 0
    var whiteTextPixels = 0
    for x in 1066...1132 {
        let offset = (cgY * width + x) * 4
        let r = Int(buffer[offset])
        let g = Int(buffer[offset + 1])
        let b = Int(buffer[offset + 2])
        if r < 80 && g < 130 && b < 80 {
            darkTextPixels += 1
        }
        if r > 200 && g > 200 && b > 200 {
            whiteTextPixels += 1
        }
    }
    if darkTextPixels > 3 || whiteTextPixels > 3 {
        print(String(format: "imgY=%3d (ratio: %.3f): darkText=%2d, whiteText=%2d", imgY, Double(imgY)/Double(height), darkTextPixels, whiteTextPixels))
    }
}
