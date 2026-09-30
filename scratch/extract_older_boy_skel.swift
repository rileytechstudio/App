import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
let W = rep.pixelsWide
let H = rep.pixelsHigh

let outRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

var minX = W, maxX = 0, minY = H, maxY = 0

for y in 0..<H {
    for x in 0..<W {
        let c = rep.colorAt(x: x, y: y)!
        let r = c.redComponent
        let g = c.greenComponent
        let b = c.blueComponent
        
        // Bone detection:
        // 1. White bone: bright in all channels
        let isWhite = (r > 0.65 && g > 0.65 && b > 0.65)
        // 2. Blue accent/shading: blue is high, green is higher than red
        let isBlue = (b > 0.45 && g > r + 0.05)
        
        if isWhite || isBlue {
            outRep.setColor(c, atX: x, y: y)
            minX = min(minX, x)
            maxX = max(maxX, x)
            minY = min(minY, y)
            maxY = max(maxY, y)
        } else {
            outRep.setColor(NSColor(red: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
        }
    }
}

print("Extracted bounds: x: \(minX)..\(maxX) (w: \(maxX - minX + 1)), y: \(minY)..\(maxY) (h: \(maxY - minY + 1))")

// Crop to tight bounds
let cropW = maxX - minX + 1
let cropH = maxY - minY + 1
let cropRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: cropW, pixelsHigh: cropH, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<cropH {
    for x in 0..<cropW {
        let c = outRep.colorAt(x: minX + x, y: minY + y)!
        cropRep.setColor(c, atX: x, y: y)
    }
}

let cropPng = cropRep.representation(using: .png, properties: [:])!
try! cropPng.write(to: URL(fileURLWithPath: "scratch/older_boy_skel_transparent.png"))
print("Saved scratch/older_boy_skel_transparent.png (\(cropW) x \(cropH))")

