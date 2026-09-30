import Foundation
import CoreGraphics
import ImageIO

// Extract a frame from the original MRI Video.mp4
guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: "MRI/MRI Video.mp4") as CFURL, nil) else {
    exit(1)
}
