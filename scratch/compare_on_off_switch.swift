import Foundation
import CoreGraphics
import ImageIO

guard let onSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: "assets/MRIRoomLightsOn.png") as CFURL, nil),
      let onImage = CGImageSourceCreateImageAtIndex(onSource, 0, nil),
      let offSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: "assets/MRIRoomLightsOff.png") as CFURL, nil),
      let offImage = CGImageSourceCreateImageAtIndex(offSource, 0, nil) else {
    exit(1)
}

let cropRect = CGRect(x: 1000, y: 70, width: 200, height: 220)
guard let onCrop = onImage.cropping(to: cropRect),
      let offCrop = offImage.cropping(to: cropRect) else { exit(1) }

let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let context = CGContext(data: nil, width: 400, height: 220, bitsPerComponent: 8, bytesPerRow: 400 * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { exit(1) }

context.draw(onCrop, in: CGRect(x: 0, y: 0, width: 200, height: 220))
context.draw(offCrop, in: CGRect(x: 200, y: 0, width: 200, height: 220))

// Draw cyan circle over "OFF" on both
let cgY = CGFloat(220 - 1 - 90)
context.setStrokeColor(red: 0, green: 229/255.0, blue: 1.0, alpha: 1.0)
context.setLineWidth(3.0)
context.strokeEllipse(in: CGRect(x: 100 - 19, y: cgY - 19, width: 38, height: 38))
context.strokeEllipse(in: CGRect(x: 300 - 19, y: cgY - 19, width: 38, height: 38))

guard let result = context.makeImage() else { exit(1) }
let destURL = URL(fileURLWithPath: "scratch/on_off_switch_comparison.png") as CFURL
guard let destination = CGImageDestinationCreateWithURL(destURL, "public.png" as CFString, 1, nil) else { exit(1) }
CGImageDestinationAddImage(destination, result, nil)
CGImageDestinationFinalize(destination)
print("Saved comparison to scratch/on_off_switch_comparison.png")
