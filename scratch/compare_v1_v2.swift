import Foundation
import CoreGraphics
import ImageIO

guard let s1 = CGImageSourceCreateWithURL(URL(fileURLWithPath: "scratch/v1_5s.png") as CFURL, nil),
      let i1 = CGImageSourceCreateImageAtIndex(s1, 0, nil),
      let s2 = CGImageSourceCreateWithURL(URL(fileURLWithPath: "scratch/video2_frames/frame_5s.png") as CFURL, nil),
      let i2 = CGImageSourceCreateImageAtIndex(s2, 0, nil) else {
    exit(1)
}

// In v1_5s, the box was at x: 588..780, y: 66..150 (width 193, height 85)
let cropV1 = i1.cropping(to: CGRect(x: 588, y: 66, width: 193, height: 85))!

// Save cropV1
let dest1 = CGImageDestinationCreateWithURL(URL(fileURLWithPath: "scratch/crop_v1_box.png") as CFURL, "public.png" as CFString, 1, nil)!
CGImageDestinationAddImage(dest1, cropV1, nil)
CGImageDestinationFinalize(dest1)
print("Saved scratch/crop_v1_box.png")
