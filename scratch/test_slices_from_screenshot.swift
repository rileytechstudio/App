import AppKit

// Load the high-res Older Boy Skeleton.png
let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

// Skeleton in Older Boy Skeleton.png:
// x: 596..967 (w:372), y: 372..1633 (h:1262)

// In Older Boy Skeleton.png:
// Skull: x: 700..863, y: 372..536 (height 165, width 164)
// Let's verify skull bounds in original:
print("Cropping skull from Older Boy Skeleton.png...")
let skullX = 700
let skullY = 372
let skullW = 164
let skullH = 165

let skullRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: skullW, pixelsHigh: skullH, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<skullH {
    for x in 0..<skullW {
        let sx = skullX + x
        let sy = skullY + y
        let c = repSkel.colorAt(x: sx, y: sy)!
        let r = c.redComponent
        let g = c.greenComponent
        let b = c.blueComponent
        
        // Bone white:
        let isWhite = r > 0.8 && g > 0.8 && b > 0.8
        // Bone cyan:
        let isCyan = b > 0.4 && g > 0.35 && g > r + 0.04
        // Eye socket and nasal cavity:
        let isDarkEye = (sx >= 810 && sx <= 865 && sy >= 440 && sy <= 510 && r < 0.25 && g < 0.25 && b < 0.35)
        
        // Clean out any stray spine below jaw: jaw ends at y=164 in this box
        if isWhite || isCyan || isDarkEye {
            skullRep.setColor(c, atX: x, y: y)
        } else {
            skullRep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
        }
    }
}

let skullPng = skullRep.representation(using: .png, properties: [:])!
try! skullPng.write(to: URL(fileURLWithPath: "scratch/test_new_skull.png"))
print("Saved scratch/test_new_skull.png")

