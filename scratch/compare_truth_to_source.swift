import AppKit

let urlTruth = URL(fileURLWithPath: "scratch/truth_skeleton.png")
let repTruth = NSBitmapImageRep(data: NSImage(contentsOf: urlTruth)!.tiffRepresentation!)!

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

// Find truth skeleton bounding box:
var tMinX = repTruth.pixelsWide, tMaxX = 0, tMinY = repTruth.pixelsHigh, tMaxY = 0
for y in 0..<repTruth.pixelsHigh {
    for x in 0..<repTruth.pixelsWide {
        let c = repTruth.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            tMinX = min(tMinX, x)
            tMaxX = max(tMaxX, x)
            tMinY = min(tMinY, y)
            tMaxY = max(tMaxY, y)
        }
    }
}
print("Truth skeleton bounds in 166x511 frame:")
print("x: \(tMinX)..\(tMaxX) (w: \(tMaxX - tMinX + 1))")
print("y: \(tMinY)..\(tMaxY) (h: \(tMaxY - tMinY + 1))")

// In repSkel, skeleton was:
// x: 596..1010 (w: 415), y: 371..1633 (h: 1263)

// In truth skeleton, let's find landmarks:
// 1. Skull top:
let tSkullTop = tMinY // 13
// 2. Skull bottom (mandible):
var tJawBottom = 0
for y in 13...150 {
    var hasBone = false
    for x in 60...120 {
        let c = repTruth.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 { hasBone = true }
    }
    if hasBone && y < 100 { tJawBottom = y }
}
// 3. Clavicles top:
var tClavicleTop = 0
for y in 100...200 {
    for x in 20...50 {
        let c = repTruth.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            if tClavicleTop == 0 { tClavicleTop = y }
        }
    }
}
// 4. Ribs bottom:
var tRibsBottom = 0
for y in 150...250 {
    var hasRib = false
    for x in 30...80 {
        let c = repTruth.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 { hasRib = true }
    }
    if hasRib { tRibsBottom = y }
}
// 5. Pelvis bottom:
var tPelvisBottom = 0
for y in 250...350 {
    var hasPelvis = false
    for x in 50...100 {
        let c = repTruth.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 { hasPelvis = true }
    }
    if hasPelvis { tPelvisBottom = y }
}
// 6. Feet bottom:
let tFeetBottom = tMaxY

let tH = Double(tMaxY - tMinY + 1)
print(String(format: "Landmarks in Truth Skeleton (total h=%.1f):", tH))
print(String(format: "  Skull top: %d (%.2f%%)", tSkullTop, Double(tSkullTop - tMinY) / tH * 100.0))
print(String(format: "  Jaw bottom: %d (%.2f%%)", tJawBottom, Double(tJawBottom - tMinY) / tH * 100.0))
print(String(format: "  Clavicles top: %d (%.2f%%)", tClavicleTop, Double(tClavicleTop - tMinY) / tH * 100.0))
print(String(format: "  Ribs bottom: %d (%.2f%%)", tRibsBottom, Double(tRibsBottom - tMinY) / tH * 100.0))
print(String(format: "  Pelvis bottom: %d (%.2f%%)", tPelvisBottom, Double(tPelvisBottom - tMinY) / tH * 100.0))
print(String(format: "  Feet bottom: %d (100%%)", tFeetBottom))

print("\nLandmarks in Older Boy Skeleton.png (total h=1263):")
print(String(format: "  Skull top: 371 (0%%)"))
print(String(format: "  Jaw bottom: 536 (%.2f%%)", Double(536 - 371) / 1263.0 * 100.0))
print(String(format: "  Clavicles top: 625 (%.2f%%)", Double(625 - 371) / 1263.0 * 100.0))
print(String(format: "  Ribs bottom: 865 (%.2f%%)", Double(865 - 371) / 1263.0 * 100.0))
print(String(format: "  Pelvis bottom: 1080 (%.2f%%)", Double(1080 - 371) / 1263.0 * 100.0))
print(String(format: "  Feet bottom: 1633 (100%%)"))
