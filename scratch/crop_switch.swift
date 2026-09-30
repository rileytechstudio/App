import Foundation
import CoreGraphics
import ImageIO

guard let imageSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: "assets/MRIRoomLightsOn.png") as CFURL, nil),
      let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
    exit(1)
}

// Crop rect: x: 1000, y: 70, w: 200, h: 220
let cropRect = CGRect(x: 1000, y: 70, width: 200, height: 220)
// CGImage.cropping takes y=0 at top in modern CGImage or bottom? Let's check:
guard let cropped = cgImage.cropping(to: cropRect) else {
    exit(1)
}

let destURL = URL(fileURLWithPath: "scratch/switch_inspect.png") as CFURL
guard let destination = CGImageDestinationCreateWithURL(destURL, "public.png" as CFString, 1, nil) else {
    exit(1)
}
CGImageDestinationAddImage(destination, cropped, nil)
CGImageDestinationFinalize(destination)
print("Cropped switch saved to scratch/switch_inspect.png")
