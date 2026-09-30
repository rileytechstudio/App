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

// Test 1: Blue screen rectangle (x: 587, y: 66, w: 194, h: 86)
do {
    let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.draw(insideImg, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    // In CGContext, (0,0) is bottom-left.
    // An element at top y=66..152 has CG y = 1024 - 152 = 872
    let screenRect = CGRect(x: 587, y: 1024 - 152, width: 194, height: 86)
    ctx.saveGState()
    let path = CGPath(roundedRect: screenRect, cornerWidth: 3, cornerHeight: 3, transform: nil)
    ctx.addPath(path)
    ctx.clip()
    ctx.draw(v2Img, in: screenRect)
    ctx.restoreGState()
    
    if let outImg = ctx.makeImage() {
        // CGImage cropping origin is top-left (0,0)
        let zoomRect = CGRect(x: 500, y: 30, width: 370, height: 180)
        let zoomed = outImg.cropping(to: zoomRect)!
        let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: "scratch/overlay_blue_rect_fixed.png") as CFURL, "public.png" as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, zoomed, nil)
        CGImageDestinationFinalize(dest)
    }
}

// Test 2: Trapezoid screen
do {
    let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.draw(insideImg, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    // Trapezoid bounds: x: 535, y: 24, w: 296, h: 152
    // CG y = 1024 - (24 + 152) = 848
    let trapRect = CGRect(x: 535, y: 848, width: 296, height: 152)
    ctx.saveGState()
    let path = CGPath(roundedRect: trapRect, cornerWidth: 8, cornerHeight: 8, transform: nil)
    ctx.addPath(path)
    ctx.clip()
    ctx.draw(v2Img, in: trapRect)
    ctx.restoreGState()
    
    if let outImg = ctx.makeImage() {
        let zoomRect = CGRect(x: 500, y: 15, width: 370, height: 185)
        let zoomed = outImg.cropping(to: zoomRect)!
        let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: "scratch/overlay_trapezoid_fixed.png") as CFURL, "public.png" as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, zoomed, nil)
        CGImageDestinationFinalize(dest)
    }
}

print("Overlay fixed images created!")
