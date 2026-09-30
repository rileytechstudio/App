import Foundation
import CoreGraphics
import ImageIO

guard let imageSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: "assets/MRIRoomLightsOn.png") as CFURL, nil),
      let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
    exit(1)
}

let cropRect = CGRect(x: 980, y: 30, width: 240, height: 320)
guard let cropped = cgImage.cropping(to: cropRect) else { exit(1) }

let colorSpace = CGColorSpaceCreateDeviceRGB()
let testW = Int(cropRect.width)
let testH = Int(cropRect.height)

guard let context = CGContext(data: nil, width: testW * 3, height: testH, bitsPerComponent: 8, bytesPerRow: testW * 3 * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    exit(1)
}

func drawOption(in ctx: CGContext, offsetX: CGFloat, labelAbove: Bool, labelOffset: CGFloat, labelText: String) {
    let bgRect = CGRect(x: offsetX, y: 0, width: CGFloat(testW), height: CGFloat(testH))
    ctx.draw(cropped, in: bgRect)
    
    // marker X at 1100 - 980 = 120
    let markerX = offsetX + 120
    
    // "OFF" center Y in full image is 160. Crop starts at y: 30.
    // local topDownY is 160 - 30 = 130.
    // In CGContext, cgY is testH - 1 - local topDownY.
    let localY = 160.0 - 30.0
    let cgY = CGFloat(testH) - localY
    
    // Draw cyan pulse ring (38x38) centered over "OFF"
    ctx.setStrokeColor(red: 0, green: 229/255.0, blue: 1.0, alpha: 1.0)
    ctx.setLineWidth(3.0)
    ctx.strokeEllipse(in: CGRect(x: markerX - 19, y: cgY - 19, width: 38, height: 38))
    
    // Draw label pill
    let pillW: CGFloat = 84
    let pillH: CGFloat = 22
    let pillX = markerX - pillW / 2
    let pillY = labelAbove ? (cgY + labelOffset) : (cgY - labelOffset - pillH)
    
    ctx.setFillColor(red: 15/255.0, green: 23/255.0, blue: 42/255.0, alpha: 0.88)
    ctx.fill(CGRect(x: pillX, y: pillY, width: pillW, height: pillH))
    ctx.setStrokeColor(red: 0, green: 229/255.0, blue: 1.0, alpha: 0.6)
    ctx.setLineWidth(1.0)
    ctx.stroke(CGRect(x: pillX, y: pillY, width: pillW, height: pillH))
}

// Option A: Label below switch plate (offset = 80px)
drawOption(in: context, offsetX: 0, labelAbove: false, labelOffset: 80, labelText: "Turn Off Lights")

// Option B: Label below pulse ring (offset = 38px, over ON)
drawOption(in: context, offsetX: CGFloat(testW), labelAbove: false, labelOffset: 38, labelText: "Turn Off Lights")

// Option C: Label above switch plate (offset = 58px)
drawOption(in: context, offsetX: CGFloat(testW * 2), labelAbove: true, labelOffset: 58, labelText: "Turn Off Lights")

guard let result = context.makeImage() else { exit(1) }
let destURL = URL(fileURLWithPath: "scratch/render_pill_options.png") as CFURL
guard let destination = CGImageDestinationCreateWithURL(destURL, "public.png" as CFString, 1, nil) else { exit(1) }
CGImageDestinationAddImage(destination, result, nil)
CGImageDestinationFinalize(destination)
print("Saved pill options to scratch/render_pill_options.png")
