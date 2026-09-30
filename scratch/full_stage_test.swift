import Foundation
import CoreGraphics
import ImageIO

guard let insideSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: "MRI/MRI Inside.png") as CFURL, nil),
      let insideImg = CGImageSourceCreateImageAtIndex(insideSource, 0, nil),
      let v2Source = CGImageSourceCreateWithURL(URL(fileURLWithPath: "scratch/v2_crop_test.png") as CFURL, nil),
      let v2Img = CGImageSourceCreateImageAtIndex(v2Source, 0, nil) else {
    print("Failed to load images")
    exit(1)
}

let width = insideImg.width
let height = insideImg.height
let colorSpace = CGColorSpaceCreateDeviceRGB()

let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.draw(insideImg, in: CGRect(x: 0, y: 0, width: width, height: height))

// Blue screen in CG coordinates:
// x: 587, width: 194
// y: 66 from top, height: 86
// CG y: 1024 - (66 + 86) = 872
let screenRect = CGRect(x: 587, y: 1024 - 152, width: 194, height: 86)
ctx.saveGState()
let path = CGPath(roundedRect: screenRect, cornerWidth: 3, cornerHeight: 3, transform: nil)
ctx.addPath(path)
ctx.clip()
ctx.draw(v2Img, in: screenRect)
ctx.restoreGState()

// Draw the cyan glow around the screen just like CSS box-shadow
ctx.saveGState()
ctx.setShadow(offset: .zero, blur: 6, color: CGColor(red: 0, green: 229/255.0, blue: 255/255.0, alpha: 0.45))
ctx.setStrokeColor(CGColor(red: 0, green: 229/255.0, blue: 255/255.0, alpha: 0.45))
ctx.setLineWidth(1)
ctx.addPath(path)
ctx.strokePath()
ctx.restoreGState()

guard let outImg = ctx.makeImage() else { exit(1) }

// Save full composite
let destFull = CGImageDestinationCreateWithURL(URL(fileURLWithPath: "scratch/full_inside_with_video.png") as CFURL, "public.png" as CFString, 1, nil)!
CGImageDestinationAddImage(destFull, outImg, nil)
CGImageDestinationFinalize(destFull)

// Also save zoomed-in area of screen and surrounding bore
let zoomRect = CGRect(x: 450, y: 10, width: 466, height: 260)
let zoomed = outImg.cropping(to: zoomRect)!
let destZoom = CGImageDestinationCreateWithURL(URL(fileURLWithPath: "scratch/zoom_inside_with_video.png") as CFURL, "public.png" as CFString, 1, nil)!
CGImageDestinationAddImage(destZoom, zoomed, nil)
CGImageDestinationFinalize(destZoom)

print("Composite images created successfully!")
