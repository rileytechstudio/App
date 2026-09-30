import Cocoa

guard let image = NSImage(contentsOfFile: "scratch/remote_cropped.png"),
      let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    exit(1)
}

let width = cgImage.width
let height = cgImage.height
guard let dataProvider = cgImage.dataProvider,
      let data = dataProvider.data,
      let ptr = CFDataGetBytePtr(data) else {
    exit(1)
}

let bytesPerPixel = cgImage.bitsPerPixel / 8
let bytesPerRow = cgImage.bytesPerRow

// In cropped image, rect origin in full image was (1026, 691).
// Let's print ASCII art of the cropped image
for y in stride(from: 0, to: height, by: 8) {
    var line = ""
    for x in stride(from: 0, to: width, by: 4) {
        let offset = y * bytesPerRow + x * bytesPerPixel
        let a = Int(ptr[offset + 3])
        let r = Int(ptr[offset])
        let g = Int(ptr[offset + 1])
        let b = Int(ptr[offset + 2])
        if a < 30 {
            line += " "
        } else if r > 160 && g < 100 && b < 100 {
            line += "R" // Red
        } else if g > 150 && r < 100 && b < 100 {
            line += "G" // Green
        } else if b > 150 && r < 100 && g < 100 {
            line += "B" // Blue
        } else if r > 180 && g > 180 && b < 100 {
            line += "Y" // Yellow
        } else if r < 70 && g < 70 && b < 70 {
            line += "#" // Black
        } else if r > 180 && g > 180 && b > 180 {
            line += "." // White
        } else {
            line += "-" // Remote body
        }
    }
    print(String(format: "y=%3d (abs y=%3d, %.1f%%): %@", y, 691 + y, Double(691 + y)/1024.0*100, line))
}
