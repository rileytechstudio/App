import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

// Silhouette bounds
let silX: Double = 42.0
let silY: Double = 25.0
let silW: Double = 138.0
let silH: Double = 426.0

// Let's sample key anatomical vertical zones in the screenshot:
// 1. Skull
// 2. Neck
// 3. Ribcage / Shoulders
// 4. Lumbar Spine
// 5. Pelvis
// 6. Femurs
// 7. Tibia/Fibula
// 8. Feet

// Function to find white/bone bounds in a given y-range [y0, y1]
func findBoneInYRange(y0: Int, y1: Int, name: String) {
    var minX = rep.pixelsWide, maxX = 0, minY = rep.pixelsHigh, maxY = 0
    var count = 0
    for y in y0...y1 {
        for x in 0..<rep.pixelsWide {
            let c = rep.colorAt(x: x, y: y)!
            let r = c.redComponent
            let g = c.greenComponent
            let b = c.blueComponent
            // Bone is white or blue shading or dark eye socket inside skull
            let isBone = (r > 0.75 && g > 0.75 && b > 0.75) || (b > 0.45 && b > r + 0.1) || (r < 0.25 && g < 0.25 && b < 0.35 && y < 100)
            if isBone {
                minX = min(minX, x)
                maxX = max(maxX, x)
                minY = min(minY, y)
                maxY = max(maxY, y)
                count += 1
            }
        }
    }
    if count > 0 {
        let relX = (Double(minX) + Double(maxX - minX + 1)/2.0 - silX) / silW * 100.0
        let relY = (Double(minY) + Double(maxY - minY + 1)/2.0 - silY) / silH * 100.0
        let relW = Double(maxX - minX + 1) / silW * 100.0
        let relH = Double(maxY - minY + 1) / silH * 100.0
        print(String(format: "%@: y:%d..%d, x:%d..%d (count: %d) -> relCenter: (%.1f%%, %.1f%%), relSize: (%.1f%% x %.1f%%)",
                     name, minY, maxY, minX, maxX, count, relX, relY, relW, relH))
    }
}

print("--- Screenshot Piece Bounds ---")
// Head region (y: 25..100)
findBoneInYRange(y0: 25, y1: 85, name: "Skull (all)")
// Neck region (y: 75..110)
findBoneInYRange(y0: 75, y1: 108, name: "Cervical Spine")
// Ribcage / Chest region (y: 100..185)
findBoneInYRange(y0: 106, y1: 175, name: "Ribcage & Chest")
// Mid spine / lumbar (y: 170..210)
findBoneInYRange(y0: 175, y1: 210, name: "Lumbar Spine")
// Pelvis region (y: 200..250)
findBoneInYRange(y0: 200, y1: 245, name: "Pelvis")
// Legs (y: 240..350)
findBoneInYRange(y0: 245, y1: 345, name: "Femurs")
// Lower legs (y: 345..420)
findBoneInYRange(y0: 345, y1: 420, name: "Tibia & Fibula")
// Feet (y: 420..455)
findBoneInYRange(y0: 420, y1: 450, name: "Feet")

