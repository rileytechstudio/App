import AppKit

let urlTruth = URL(fileURLWithPath: "scratch/truth_skeleton.png")
let repTruth = NSBitmapImageRep(data: NSImage(contentsOf: urlTruth)!.tiffRepresentation!)!

// In truth skeleton, let's find the bounding box of each piece:
// 1. Skull: y: 8..90
// 2. Ribcage: y: 110..220
// 3. Pelvis: y: 220..310
// 4. Legs: y: 310..508

print("Truth skeleton width at: ")
for y in stride(from: 10, through: 500, by: 20) {
    var minX = 999, maxX = -1
    for x in 0..<repTruth.pixelsWide {
        let c = repTruth.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            minX = min(minX, x)
            maxX = max(maxX, x)
        }
    }
    if minX <= maxX {
        print(String(format: "y=%3d: x=%3d..%3d (w=%3d)", y, minX, maxX, maxX - minX + 1))
    }
}
