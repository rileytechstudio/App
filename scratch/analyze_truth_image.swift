import AppKit

let url = URL(fileURLWithPath: "scratch/cropped_new_upload.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: url)!.tiffRepresentation!)!

print("Image size: \(rep.pixelsWide) x \(rep.pixelsHigh)")

// In this image, let's find the character silhouette bounds (pink or bone):
var cMinX = rep.pixelsWide, cMaxX = 0, cMinY = rep.pixelsHigh, cMaxY = 0

for y in 0..<rep.pixelsHigh {
    for x in 0..<rep.pixelsWide {
        let c = rep.colorAt(x: x, y: y)!
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        // White background is r > 0.98, g > 0.98, b > 0.98
        if !(r > 0.98 && g > 0.98 && b > 0.98) && c.alphaComponent > 0.05 {
            cMinX = min(cMinX, x)
            cMaxX = max(cMaxX, x)
            cMinY = min(cMinY, y)
            cMaxY = max(cMaxY, y)
        }
    }
}

let charW = cMaxX - cMinX + 1
let charH = cMaxY - cMinY + 1
print("Character silhouette bbox: x: \(cMinX)..\(cMaxX) (w: \(charW)), y: \(cMinY)..\(cMaxY) (h: \(charH))")
print("Aspect ratio: \(Double(charW) / Double(charH))")

// Let's measure skull bounds in this truth image:
// Skull top is cranium dome, skull bottom is mandible/chin.
// Skull is in y < cMinY + Int(Double(charH) * 0.25)
var sMinX = rep.pixelsWide, sMaxX = 0, sMinY = rep.pixelsHigh, sMaxY = 0
for y in cMinY..<(cMinY + Int(Double(charH) * 0.22)) {
    for x in 0..<rep.pixelsWide {
        let c = rep.colorAt(x: x, y: y)!
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        // Bone or cavity:
        // White bone with blue outline, or navy cavity (r < 0.35, g < 0.35, b < 0.45)
        // Pink is r > 0.8 && g < 0.75 && b > 0.8
        let isPink = (r > 0.75 && g < 0.75 && b > 0.75)
        let isWhiteBg = (r > 0.98 && g > 0.98 && b > 0.98)
        let isBoneOrCavity = !isPink && !isWhiteBg && c.alphaComponent > 0.05
        if isBoneOrCavity {
            sMinX = min(sMinX, x)
            sMaxX = max(sMaxX, x)
            sMinY = min(sMinY, y)
            sMaxY = max(sMaxY, y)
        }
    }
}
print("Skull bbox in truth image: x: \(sMinX)..\(sMaxX) (w: \(sMaxX - sMinX + 1)), y: \(sMinY)..\(sMaxY) (h: \(sMaxY - sMinY + 1))")

// Relative to character:
let sRelX = Double(sMinX - cMinX) / Double(charW) * 100.0
let sRelY = Double(sMinY - cMinY) / Double(charH) * 100.0
let sRelW = Double(sMaxX - sMinX + 1) / Double(charW) * 100.0
let sRelH = Double(sMaxY - sMinY + 1) / Double(charH) * 100.0
let sCx = sRelX + sRelW / 2.0
let sCy = sRelY + sRelH / 2.0

print(String(format: "Skull relative to char: cx: %.2f%%, cy: %.2f%%, w: %.2f%%, h: %.2f%%", sCx, sCy, sRelW, sRelH))
