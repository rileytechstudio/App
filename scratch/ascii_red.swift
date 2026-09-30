import Cocoa

guard let image = NSImage(contentsOfFile: "assets/MRIRemoteController.png"),
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

for y in stride(from: 715, to: 855, by: 4) {
    var line = ""
    for x in stride(from: 1110, to: 1215, by: 3) {
        let offset = y * bytesPerRow + x * bytesPerPixel
        let r = Int(ptr[offset])
        let g = Int(ptr[offset + 1])
        let b = Int(ptr[offset + 2])
        let a = Int(ptr[offset + 3])
        if a > 50 && r > 150 && g < 100 && b < 100 {
            line += "##"
        } else {
            line += "  "
        }
    }
    if line.contains("##") {
        print(String(format: "y=%3d (%.1f%%): %@", y, Double(y)/Double(height)*100, line))
    }
}
