import Foundation
import CoreGraphics
import ImageIO

guard let imageSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: "scratch/switch_inspect.png") as CFURL, nil),
      let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
    exit(1)
}

let w = cgImage.width
let h = cgImage.height

// We want to test different Y centers for the pulse ring over the "OFF" button.
// In scratch/switch_inspect.png (which is 200x220, cropped with x: 1000, y: 70):
// X center of switch is at x = 1100 - 1000 = 100.
// Green area is y in [63, 171].
// Divider is at y = 117.
// "OFF" button is y in [63, 117], center is y = 90.
// In full 1024 coords: 70 + 90 = 160 (160 / 1024 = 15.625%).

// Let's create an annotated test image showing:
// 1) The exact "OFF" center (y = 90, which is 15.6%)
// 2) A cyan pulse circle of radius 19 (diameter 38px, identical to .mri-pulse-ring)
// 3) The label pill "Turn Off Lights"

let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let context = CGContext(data: nil, width: w * 2, height: h, bitsPerComponent: 8, bytesPerRow: w * 2 * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    exit(1)
}

// Draw original on left
context.draw(cgImage, in: CGRect(x: 0, y: 0, width: w, height: h))

// Draw original on right
context.draw(cgImage, in: CGRect(x: w, y: 0, width: w, height: h))

// In CGContext, (0,0) is bottom-left.
// For the right image, origin x is w.
// In cropped coords from top: top is y=0, bottom is y=h-1.
// cgY = h - 1 - topDownY.
// For "OFF" center: topDownY = 90.
let cgCenterY = CGFloat(h - 1 - 90)
let cgCenterX = CGFloat(w + 100)

// Draw Cyan Pulse Circle over "OFF"
context.setStrokeColor(red: 0, green: 229/255.0, blue: 1.0, alpha: 1.0)
context.setLineWidth(3.0)
context.strokeEllipse(in: CGRect(x: cgCenterX - 19, y: cgCenterY - 19, width: 38, height: 38))

// Draw label pill underneath or above? Let's check where the label pill sits!
// If label pill is below "OFF", say topDownY = 90 + 32 = 122 (cgY = h - 1 - 122)
let pillW: CGFloat = 90
let pillH: CGFloat = 20
let pillX = cgCenterX - pillW / 2
let pillY = CGFloat(h - 1 - 128)

context.setFillColor(red: 15/255.0, green: 23/255.0, blue: 42/255.0, alpha: 0.88)
context.fill(CGRect(x: pillX, y: pillY, width: pillW, height: pillH))
context.stroke(CGRect(x: pillX, y: pillY, width: pillW, height: pillH))

guard let resultImage = context.makeImage() else { exit(1) }
let destURL = URL(fileURLWithPath: "scratch/test_switch_overlay.png") as CFURL
guard let destination = CGImageDestinationCreateWithURL(destURL, "public.png" as CFString, 1, nil) else { exit(1) }
CGImageDestinationAddImage(destination, resultImage, nil)
CGImageDestinationFinalize(destination)
print("Saved comparison to scratch/test_switch_overlay.png")
