import Foundation
import CoreGraphics
import ImageIO

guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: "MRI/MRI Inside.png") as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
    exit(1)
}

let cropRect = CGRect(x: 520, y: 40, width: 330, height: 160)
guard let cropped = image.cropping(to: cropRect) else {
    print("Crop failed")
    exit(1)
}

let destURL = URL(fileURLWithPath: "scratch/mri_screen_crop.png") as CFURL
guard let destination = CGImageDestinationCreateWithURL(destURL, "public.png" as CFString, 1, nil) else {
    exit(1)
}
CGImageDestinationAddImage(destination, cropped, nil)
CGImageDestinationFinalize(destination)
print("Saved scratch/mri_screen_crop.png")
