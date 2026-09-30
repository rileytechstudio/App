import AppKit

let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let repShot = NSBitmapImageRep(data: NSImage(contentsOf: urlShot)!.tiffRepresentation!)!

// In screenshot, skull + neck is y: 30..115, x: 70..145
// Silhouette in screenshot is x: 42..179 (w:138), y: 25..450 (h:426)
// Solo character is 220 x 681

for dy in [20, 24, 28, 32] {
    for dx in [-24, -20, -16] {
        let path = "scratch/test_shift_dx\(dx)_dy\(dy).png"
        guard let img = NSImage(contentsOf: URL(fileURLWithPath: path)),
              let rep = NSBitmapImageRep(data: img.tiffRepresentation!) else { continue }
        
        // Find bone bounding box in this test image
        var minX = rep.pixelsWide, maxX = 0, minY = rep.pixelsHigh, maxY = 0
        for y in 0..<rep.pixelsHigh {
            for x in 0..<rep.pixelsWide {
                if rep.colorAt(x: x, y: y)!.alphaComponent > 0.5 {
                    minX = min(minX, x)
                    maxX = max(maxX, x)
                    minY = min(minY, y)
                    maxY = max(maxY, y)
                }
            }
        }
        let w = maxX - minX + 1
        let h = maxY - minY + 1
        print(String(format: "dx=%+d, dy=%+d: bounds x:%d..%d (w:%d), y:%d..%d (h:%d), aspect: %.4f",
            dx, dy, minX, maxX, w, minY, maxY, h, Double(w)/Double(h)))
    }
}

