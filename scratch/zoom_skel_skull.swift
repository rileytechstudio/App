import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

// Skull in Older Boy Skeleton.png is x: 700..865, y: 370..560
let cropW = 165
let cropH = 190
let cropRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: cropW, pixelsHigh: cropH, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<cropH {
    for x in 0..<cropW {
        let color = rep.colorAt(x: 700 + x, y: 370 + y)!
        cropRep.setColor(color, atX: x, y: y)
    }
}

let pngData = cropRep.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "scratch/zoomed_skel_skull.png"))
print("Saved scratch/zoomed_skel_skull.png")
