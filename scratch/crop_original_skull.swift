import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

// Crop region around skull and chest: x: 550..1000, y: 350..850
let cropW = 450
let cropH = 500
let cropRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: cropW, pixelsHigh: cropH, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<cropH {
    for x in 0..<cropW {
        let color = rep.colorAt(x: 550 + x, y: 350 + y)!
        cropRep.setColor(color, atX: x, y: y)
    }
}

let pngData = cropRep.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "scratch/original_upper_body_crop.png"))
print("Saved scratch/original_upper_body_crop.png")
