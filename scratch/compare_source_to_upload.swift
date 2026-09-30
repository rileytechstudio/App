import AppKit

let urlUpload = URL(fileURLWithPath: "scratch/truth_skeleton.png")
let imgUpload = NSImage(contentsOf: urlUpload)!
let repUpload = NSBitmapImageRep(data: imgUpload.tiffRepresentation!)!

// Upload skeleton bounding box was: x: 5..152 (w: 148), y: 8..508 (h: 501)
// Let's load Older Boy Skeleton.png (unmatted)
let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

// Skeleton in Older Boy Skeleton is at x: 596..1010 (w: 414), y: 371..1633 (h: 1262)
// Scale: 148.0 / 414.0 = 0.35748, 501.0 / 1262.0 = 0.39698

// Let's create an overlay image:
// Red = Source skeleton scaled
// Green = Uploaded truth skeleton
let canvas = NSImage(size: NSSize(width: 166, height: 511))
canvas.lockFocus()

// Draw truth skeleton
imgUpload.draw(in: NSRect(x: 0, y: 0, width: 166, height: 511))

canvas.unlockFocus()

// Let's compare feature positions:
// In repUpload:
// Orbit centroid:
var upOrbitX = 0.0, upOrbitY = 0.0, upCount = 0.0
for y in 20...70 {
    for x in 70...120 {
        let c = repUpload.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.5 && c.redComponent < 0.3 && c.blueComponent < 0.4 {
            upOrbitX += Double(x)
            upOrbitY += Double(y)
            upCount += 1.0
        }
    }
}
print(String(format: "Upload orbit: (%.1f, %.1f)", upOrbitX / upCount, upOrbitY / upCount))

// In repSkel:
var skOrbitX = 0.0, skOrbitY = 0.0, skCount = 0.0
for y in 440...500 {
    for x in 820...855 {
        let c = repSkel.colorAt(x: x, y: y)!
        if c.redComponent < 0.25 && c.blueComponent < 0.35 && c.greenComponent < 0.25 {
            skOrbitX += Double(x)
            skOrbitY += Double(y)
            skCount += 1.0
        }
    }
}
let origOrbitX = skOrbitX / skCount
let origOrbitY = skOrbitY / skCount
print(String(format: "Source orbit: (%.1f, %.1f)", origOrbitX, origOrbitY))

// If mapped by (x: 5, y: 8, w: 148, h: 501):
let mappedOrbitX = 5.0 + (origOrbitX - 596.0) / 414.0 * 148.0
let mappedOrbitY = 8.0 + (origOrbitY - 371.0) / 1262.0 * 501.0
print(String(format: "Source orbit mapped to upload: (%.1f, %.1f)", mappedOrbitX, mappedOrbitY))
print(String(format: "Difference: dx=%.1f, dy=%.1f", (upOrbitX / upCount) - mappedOrbitX, (upOrbitY / upCount) - mappedOrbitY))
