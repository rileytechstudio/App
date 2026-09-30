import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
guard let img = NSImage(contentsOf: url),
      let rep = NSBitmapImageRep(data: img.tiffRepresentation!) else {
    print("Could not load image")
    exit(1)
}

let W = rep.pixelsWide
let H = rep.pixelsHigh
print("Screenshot size: \(W) x \(H)")

// Find the bounds of the pink silhouette
var minX = W, maxX = 0, minY = H, maxY = 0
for y in 0..<H {
    for x in 0..<W {
        let c = rep.colorAt(x: x, y: y)!
        let r = c.redComponent
        let g = c.greenComponent
        let b = c.blueComponent
        
        // Background purple is roughly r: 0.33, g: 0.19, b: 0.65 (#543fa6)
        // Pink silhouette is roughly r: 0.95, g: 0.55, b: 0.95 (#f28df2 / #ff88ff / #e060c0)
        // White bone is r: >0.85, g: >0.85, b: >0.85
        // Cyan shading is r: 0.2..0.45, g: 0.45..0.65, b: 0.65..0.85
        // Dark bone shadows/eye is r: <0.2, g: <0.2, b: <0.3
        
        // Let's identify background purple:
        // Background has r in [0.25, 0.40], g in [0.15, 0.28], b in [0.55, 0.75]
        let isBg = (r >= 0.25 && r <= 0.42 && g >= 0.12 && g <= 0.28 && b >= 0.55 && b <= 0.78)
        
        if !isBg {
            minX = min(minX, x)
            maxX = max(maxX, x)
            minY = min(minY, y)
            maxY = max(maxY, y)
        }
    }
}

print("Total character bounds (silhouette + bones): x: \(minX)..\(maxX) (w: \(maxX - minX + 1)), y: \(minY)..\(maxY) (h: \(maxY - minY + 1))")

// Let's check the solo silhouette asset Character_OlderBoy_Solo.png
let soloUrl = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
if let soloImg = NSImage(contentsOf: soloUrl),
   let soloRep = NSBitmapImageRep(data: soloImg.tiffRepresentation!) {
    print("Solo asset size: \(soloRep.pixelsWide) x \(soloRep.pixelsHigh), aspect: \(Double(soloRep.pixelsWide) / Double(soloRep.pixelsHigh))")
}
print("Screenshot char aspect: \(Double(maxX - minX + 1) / Double(maxY - minY + 1))")
