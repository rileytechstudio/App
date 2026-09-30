import Foundation
import CoreGraphics
import ImageIO

guard let imageSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: "assets/MRIRoomLightsOn.png") as CFURL, nil),
      let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
    exit(1)
}

let cropRect = CGRect(x: 980, y: 50, width: 240, height: 280)
guard let cropped = cgImage.cropping(to: cropRect) else { exit(1) }

let colorSpace = CGColorSpaceCreateDeviceRGB()
let testW = Int(cropRect.width)
let testH = Int(cropRect.height)

guard let context = CGContext(data: nil, width: testW * 2, height: testH, bitsPerComponent: 8, bytesPerRow: testW * 2 * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    exit(1)
}

func drawOption(in ctx: CGContext, offsetX: CGFloat, centerY: Double, pillOffset: CGFloat) {
    let bgRect = CGRect(x: offsetX, y: 0, width: CGFloat(testW), height: CGFloat(testH))
    ctx.draw(cropped, in: bgRect)
    
    let markerX = offsetX + 120.0
    let localY = centerY - 50.0
    let cgY = CGFloat(testH) - localY
    
    // Resting ring
    ctx.setStrokeColor(red: 0, green: 229/255.0, blue: 1.0, alpha: 1.0)
    ctx.setLineWidth(3.0)
    ctx.strokeEllipse(in: CGRect(x: markerX - 19, y: cgY - 19, width: 38, height: 38))
    
    // Pulse ring
    ctx.setStrokeColor(red: 0, green: 229/255.0, blue: 1.0, alpha: 0.45)
    ctx.setLineWidth(2.0)
    ctx.strokeEllipse(in: CGRect(x: markerX - 30.4, y: cgY - 30.4, width: 60.8, height: 60.8))
    
    // Pill
    let pillW: CGFloat = 84
    let pillH: CGFloat = 22
    let pillX = markerX - pillW / 2
    let pillY = cgY - pillOffset - pillH / 2
    
    ctx.setFillColor(red: 15/255.0, green: 23/255.0, blue: 42/255.0, alpha: 0.88)
    ctx.fill(CGRect(x: pillX, y: pillY, width: pillW, height: pillH))
    ctx.setStrokeColor(red: 0, green: 229/255.0, blue: 1.0, alpha: 0.6)
    ctx.setLineWidth(1.0)
    ctx.stroke(CGRect(x: pillX, y: pillY, width: pillW, height: pillH))
}

// Option 1: centerY = 141px (13.8%), pillOffset = 52px (standard)
drawOption(in: context, offsetX: 0, centerY: 141.0, pillOffset: 52)

// Option 2: centerY = 141px (13.8%), pillOffset = 76px (below plate)
drawOption(in: context, offsetX: CGFloat(testW), centerY: 141.0, pillOffset: 76)

guard let result = context.makeImage() else { exit(1) }
let destURL = URL(fileURLWithPath: "scratch/label_compare.png") as CFURL
guard let destination = CGImageDestinationCreateWithURL(destURL, "public.png" as CFString, 1, nil) else { exit(1) }
CGImageDestinationAddImage(destination, result, nil)
CGImageDestinationFinalize(destination)
print("Saved comparison to scratch/label_compare.png")
