import Cocoa

guard let image = NSImage(contentsOfFile: "assets/MRIRemoteController.png"),
      let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    exit(1)
}

// Crop the remote area: x from 1026 to 1304 (width 278), y from 691 to 1023 (height 332)
let rect = CGRect(x: 1026, y: 691, width: 278, height: 332)
if let cropped = cgImage.cropping(to: rect) {
    let rep = NSBitmapImageRep(cgImage: cropped)
    let png = rep.representation(using: .png, properties: [:])
    try? png?.write(to: URL(fileURLWithPath: "scratch/remote_cropped.png"))
}
print("Cropped remote to scratch/remote_cropped.png")
