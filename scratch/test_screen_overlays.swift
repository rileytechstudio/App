import Foundation
import CoreGraphics
import ImageIO

guard let insideSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: "MRI/MRI Inside.png") as CFURL, nil),
      let insideImg = CGImageSourceCreateImageAtIndex(insideSource, 0, nil),
      let v2Source = CGImageSourceCreateWithURL(URL(fileURLWithPath: "scratch/video2_frames/frame_5s.png") as CFURL, nil),
      let v2Img = CGImageSourceCreateImageAtIndex(v2Source, 0, nil) else {
    print("Failed to load images")
    exit(1)
}

let width = insideImg.width
let height = insideImg.height
let colorSpace = CGColorSpaceCreateDeviceRGB()

// Test 1: Overlay video into the blue screen rectangle (587, 66, 194, 86)
do {
    let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    
    // Draw MRI Inside
    ctx.draw(insideImg, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    // CoreGraphics origin is bottom-left, so y in CG is height - (y + h)
    // Blue screen: x: 587, y: 66, w: 194, h: 86
    // CG y = 1024 - (66 + 86) = 1024 - 152 = 872
    let screenRect = CGRect(x: 587, y: 1024 - 152, width: 194, height: 86)
    
    ctx.saveGState()
    // Clip to rounded rect
    let path = CGPath(roundedRect: screenRect, cornerWidth: 3, cornerHeight: 3, transform: nil)
    ctx.addPath(path)
    ctx.clip()
    ctx.draw(v2Img, in: screenRect)
    ctx.restoreGState()
    
    if let outImg = ctx.makeImage() {
        // Crop zoomed view around screen: x: 500..870, y: 30..220
        // in CG coordinates: y: 1024 - 220 = 804, height: 190
        let zoomRect = CGRect(x: 500, y: 804, width: 370, height: 190)
        let zoomed = outImg.cropping(to: zoomRect)!
        let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: "scratch/overlay_blue_rect.png") as CFURL, "public.png" as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, zoomed, nil)
        CGImageDestinationFinalize(dest)
    }
}

// Test 2: Overlay video into the entire trapezoid screen
// Let's find trapezoid bounds in MRI Inside
// Earlier we found trapezoid is around x: 535..831, y: 24..176
do {
    let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.draw(insideImg, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    // Trapezoid bounds approx: x: 535, y: 24, w: 296, h: 152
    // CG y = 1024 - 176 = 848
    let trapRect = CGRect(x: 535, y: 848, width: 296, height: 152)
    ctx.saveGState()
    let path = CGPath(roundedRect: trapRect, cornerWidth: 8, cornerHeight: 8, transform: nil)
    ctx.addPath(path)
    ctx.clip()
    ctx.draw(v2Img, in: trapRect)
    ctx.restoreGState()
    
    if let outImg = ctx.makeImage() {
        let zoomRect = CGRect(x: 500, y: 804, width: 370, height: 190)
        let zoomed = outImg.cropping(to: zoomRect)!
        let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: "scratch/overlay_trapezoid.png") as CFURL, "public.png" as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, zoomed, nil)
        CGImageDestinationFinalize(dest)
    }
}

print("Generated overlay comparisons!")
