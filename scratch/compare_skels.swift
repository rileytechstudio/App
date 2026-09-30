import AppKit

let newUrl = URL(fileURLWithPath: "Anatomy Explorer/Younger Boy Skeleton.png")
let refUrl = URL(fileURLWithPath: "scratch/user_younger_boy_target.png")

guard let newImg = NSImage(contentsOf: newUrl),
      let newRep = NSBitmapImageRep(data: newImg.tiffRepresentation!),
      let refImg = NSImage(contentsOf: refUrl),
      let refRep = NSBitmapImageRep(data: refImg.tiffRepresentation!) else {
    exit(1)
}

print("New image: \(newRep.pixelsWide) x \(newRep.pixelsHigh)")
print("Ref target: \(refRep.pixelsWide) x \(refRep.pixelsHigh)")

// Crop the new skeleton from 1366x1024:
let minX = 549
let minY = 102
let W = 269
let H = 743

let cropRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<H {
    for x in 0..<W {
        let color = newRep.colorAt(x: minX + x, y: minY + y)!
        cropRep.setColor(color, atX: x, y: y)
    }
}

let cropPng = cropRep.representation(using: .png, properties: [:])!
try! cropPng.write(to: URL(fileURLWithPath: "scratch/new_skel_cropped.png"))
print("Saved scratch/new_skel_cropped.png (\(W) x \(H))")

