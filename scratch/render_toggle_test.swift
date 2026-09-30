import Foundation
import CoreGraphics
import ImageIO

guard let imageSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: "assets/MRIRoomLightsOn.png") as CFURL, nil),
      let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
    exit(1)
}

let cropRect = CGRect(x: 980, y: 50, width: 240, height: 260)
guard let cropped = cgImage.cropping(to: cropRect) else { exit(1) }

let colorSpace = CGColorSpaceCreateDeviceRGB()
let testW = Int(cropRect.width)
let testH = Int(cropRect.height)

// 4 variations: y = 160 (old 15.6%), y = 148 (14.5%), y = 142 (13.9%), y = 136 (13.3%)
let testYs: [(name: String, y: Double)] = [
    ("Old: 160px (15.6%)", 160.0),
    ("148px (14.5%)", 148.0),
    ("142px (13.9%)", 142.0),
    ("136px (13.3%)", 136.0)
]

guard let context = CGContext(data: nil, width: testW * testYs.count, height: testH, bitsPerComponent: 8, bytesPerRow: testW * testYs.count * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    exit(1)
}

for (i, item) in testYs.enumerated() {
    let offsetX = CGFloat(i * testW)
    let bgRect = CGRect(x: offsetX, y: 0, width: CGFloat(testW), height: CGFloat(testH))
    context.draw(cropped, in: bgRect)
    
    let markerX = offsetX + 120.0
    let localY = item.y - 50.0 // crop starts at 50
    let cgY = CGFloat(testH) - localY
    
    // Draw resting ring (radius 19) in solid cyan
    context.setStrokeColor(red: 0, green: 229/255.0, blue: 1.0, alpha: 1.0)
    context.setLineWidth(3.0)
    context.strokeEllipse(in: CGRect(x: markerX - 19, y: cgY - 19, width: 38, height: 38))
    
    // Draw max pulse ring (scale 1.6 -> radius 30.4) in dashed / translucent cyan
    context.setStrokeColor(red: 0, green: 229/255.0, blue: 1.0, alpha: 0.45)
    context.setLineWidth(2.0)
    context.strokeEllipse(in: CGRect(x: markerX - 30.4, y: cgY - 30.4, width: 60.8, height: 60.8))
    
    // Draw divider line reference across switch (at y = 187 - 50 = 137 in crop, so cgY = testH - 137)
    context.setStrokeColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.6)
    context.setLineWidth(1.0)
    let divY = CGFloat(testH) - (187.0 - 50.0)
    context.strokeLineSegments(between: [CGPoint(x: offsetX + 85, y: divY), CGPoint(x: offsetX + 155, y: divY)])
}

guard let result = context.makeImage() else { exit(1) }
let destURL = URL(fileURLWithPath: "scratch/render_toggle_test.png") as CFURL
guard let destination = CGImageDestinationCreateWithURL(destURL, "public.png" as CFString, 1, nil) else { exit(1) }
CGImageDestinationAddImage(destination, result, nil)
CGImageDestinationFinalize(destination)
print("Saved 4-panel test to scratch/render_toggle_test.png")
