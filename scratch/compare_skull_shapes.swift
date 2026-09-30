import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let imgSkel = NSImage(contentsOf: urlSkel)!
let repSkel = NSBitmapImageRep(data: imgSkel.tiffRepresentation!)!

let urlShot = URL(fileURLWithPath: "scratch/screenshot_bone_mask.png")
let imgShot = NSImage(contentsOf: urlShot)!
let repShot = NSBitmapImageRep(data: imgShot.tiffRepresentation!)!

// In screenshot, skull is y: 33..82 (h=50), x: 80..135 (w=56)
// In Older Boy Skeleton.png, let's find the skull bounds:
var skelMinX = repSkel.pixelsWide, skelMaxX = 0, skelMinY = repSkel.pixelsHigh, skelMaxY = 0

for y in 365...560 {
    for x in 700...950 {
        let c = repSkel.colorAt(x: x, y: y)!
        let r = c.redComponent
        let g = c.greenComponent
        let b = c.blueComponent
        // Bone white or cyan or eye socket:
        let isWhite = r > 0.8 && g > 0.8 && b > 0.8
        let isCyan = b > 0.4 && g > 0.35 && g > r + 0.05
        let isEye = (r < 0.25 && g < 0.25 && b < 0.35 && y < 510)
        if isWhite || isCyan || isEye {
            skelMinX = min(skelMinX, x)
            skelMaxX = max(skelMaxX, x)
            skelMinY = min(skelMinY, y)
            skelMaxY = max(skelMaxY, y)
        }
    }
}

print(String(format: "Skull in Older Boy Skeleton.png: x: %d..%d (w:%d), y: %d..%d (h:%d)",
    skelMinX, skelMaxX, skelMaxX - skelMinX + 1, skelMinY, skelMaxY, skelMaxY - skelMinY + 1))

let skelW = skelMaxX - skelMinX + 1
let skelH = skelMaxY - skelMinY + 1

// Crop high-res skull from Older Boy Skeleton.png
let cropRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: skelW, pixelsHigh: skelH, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<skelH {
    for x in 0..<skelW {
        let sx = skelMinX + x
        let sy = skelMinY + y
        let c = repSkel.colorAt(x: sx, y: sy)!
        let r = c.redComponent
        let g = c.greenComponent
        let b = c.blueComponent
        
        let isWhite = r > 0.8 && g > 0.8 && b > 0.8
        let isCyan = b > 0.4 && g > 0.35 && g > r + 0.05
        let isEye = (r < 0.25 && g < 0.25 && b < 0.35 && sy < 510)
        
        if isWhite || isCyan || isEye {
            cropRep.setColor(c, atX: x, y: y)
        } else {
            cropRep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
        }
    }
}

let pngData = cropRep.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "scratch/hires_skull_crop.png"))
print("Saved scratch/hires_skull_crop.png (\(skelW) x \(skelH))")

