import Foundation
import CoreGraphics
import ImageIO

guard let imageSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: "assets/MRIRoomLightsOn.png") as CFURL, nil),
      let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
    exit(1)
}

let width = cgImage.width // 1366
let height = cgImage.height // 1024

// Let's test a crop of the switch area: x: 1000..1200 (w: 200), y: 50..320 (h: 270)
let cropRect = CGRect(x: 980, y: 60, width: 240, height: 260)
guard let cropped = cgImage.cropping(to: cropRect) else { exit(1) }

let colorSpace = CGColorSpaceCreateDeviceRGB()

// Let's create an image with 3 variations:
// 1. Current position (center y = 17.0%, label below)
// 2. Center y = 15.6%, label below switch (margin ~ 44px)
// 3. Center y = 15.6%, label above or tighter

let testW = Int(cropRect.width)
let testH = Int(cropRect.height)

guard let context = CGContext(data: nil, width: testW * 3, height: testH, bitsPerComponent: 8, bytesPerRow: testW * 3 * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    exit(1)
}

func drawMarker(in ctx: CGContext, offsetX: CGFloat, centerY_ratio: CGFloat, labelOffset: CGFloat) {
    let bgRect = CGRect(x: offsetX, y: 0, width: CGFloat(testW), height: CGFloat(testH))
    ctx.draw(cropped, in: bgRect)
    
    // In full image, x center is 1100. In crop (starts at 980), local x is 1100 - 980 = 120.
    let markerX = offsetX + 120
    
    // In full image, y center is centerY_ratio * 1024.
    // In crop (starts at 60), local topDownY is (centerY_ratio * 1024) - 60.
    // In CGContext, cgY = testH - 1 - local topDownY.
    let localY = (centerY_ratio * 1024.0) - 60.0
    let cgY = CGFloat(testH) - localY
    
    // Draw pulsing cyan ring (38x38)
    ctx.setStrokeColor(red: 0, green: 229/255.0, blue: 1.0, alpha: 1.0)
    ctx.setLineWidth(3.0)
    ctx.strokeEllipse(in: CGRect(x: markerX - 19, y: cgY - 19, width: 38, height: 38))
    
    // Draw label pill
    let pillW: CGFloat = 80
    let pillH: CGFloat = 22
    let pillX = markerX - pillW / 2
    let pillY = cgY - labelOffset - pillH / 2
    
    ctx.setFillColor(red: 15/255.0, green: 23/255.0, blue: 42/255.0, alpha: 0.88)
    ctx.fill(CGRect(x: pillX, y: pillY, width: pillW, height: pillH))
    ctx.setStrokeColor(red: 0, green: 229/255.0, blue: 1.0, alpha: 0.6)
    ctx.setLineWidth(1.0)
    ctx.stroke(CGRect(x: pillX, y: pillY, width: pillW, height: pillH))
}

// 1. Current: y = 0.170, labelOffset = 46
drawMarker(in: context, offsetX: 0, centerY_ratio: 0.170, labelOffset: 46)

// 2. New: y = 0.156, labelOffset = 42 (below ring)
drawMarker(in: context, offsetX: CGFloat(testW), centerY_ratio: 0.156, labelOffset: 42)

// 3. New: y = 0.156, labelOffset = 52 (just below the grey switch plate)
drawMarker(in: context, offsetX: CGFloat(testW * 2), centerY_ratio: 0.156, labelOffset: 52)

guard let result = context.makeImage() else { exit(1) }
let destURL = URL(fileURLWithPath: "scratch/render_full_switch_test.png") as CFURL
guard let destination = CGImageDestinationCreateWithURL(destURL, "public.png" as CFString, 1, nil) else { exit(1) }
CGImageDestinationAddImage(destination, result, nil)
CGImageDestinationFinalize(destination)
print("Saved 3-panel test to scratch/render_full_switch_test.png")
