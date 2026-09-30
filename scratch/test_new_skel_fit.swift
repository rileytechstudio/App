import AppKit

let skelUrl = URL(fileURLWithPath: "Anatomy Explorer/Younger Boy Skeleton.png")
let soloUrl = URL(fileURLWithPath: "assets/Character_YoungerBoy_Solo.png")

guard let skelImg = NSImage(contentsOf: skelUrl),
      let skelRep = NSBitmapImageRep(data: skelImg.tiffRepresentation!),
      let soloImg = NSImage(contentsOf: soloUrl),
      let soloRep = NSBitmapImageRep(data: soloImg.tiffRepresentation!) else {
    exit(1)
}

// Bounding box of the skeleton in the 1366x1024 canvas
var minX = skelRep.pixelsWide, maxX = 0, minY = skelRep.pixelsHigh, maxY = 0
for y in 0..<skelRep.pixelsHigh {
    for x in 0..<skelRep.pixelsWide {
        if skelRep.colorAt(x: x, y: y)!.alphaComponent > 0.05 {
            minX = min(minX, x)
            maxX = max(maxX, x)
            minY = min(minY, y)
            maxY = max(maxY, y)
        }
    }
}
let skelW = maxX - minX + 1
let skelH = maxY - minY + 1
print("Skel bounds: x: \(minX)..\(maxX) (w: \(skelW)), y: \(minY)..\(maxY) (h: \(skelH))")

// Let's crop the skeleton into a tight CGImage:
let skelCg = skelImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!
let skelCropCg = skelCg.cropping(to: CGRect(x: minX, y: skelRep.pixelsHigh - maxY, width: skelW, height: skelH))!

// Now let's see: If we fit this cropped skeleton into Character_YoungerBoy_Solo (186 x 538):
// Where should the skeleton sit?
// Let's test different scalings and positions to see how it overlays onto the silhouette:
let soloW = soloRep.pixelsWide // 186
let soloH = soloRep.pixelsHigh // 538
let soloCg = soloImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!

let colorSpace = CGColorSpaceCreateDeviceRGB()

// Let's test fitting the skeleton:
// What if the skeleton matches the character bounds directly, or what if the skeleton was exported from the same artboard where Younger Boy was located?
// Wait! Let's check where the character was on the user's 1366x1024 artboard!
// In the user's file:
// Skeleton center is at x: 683.0 (50.0% of 1366)!
// Top of skull: y: 102 (10.0% of 1024). Bottom of feet: y: 844 (82.4% of 1024). Height: 742 (72.5% of 1024).
// Width: 268 (19.6% of 1366).
print(String(format: "Skeleton relative to 1366x1024: Center: (%.2f%%, %.2f%%), Size: (%.2f%%, %.2f%%)",
    Double(minX + maxX)/2.0 / 1366.0 * 100.0,
    Double(minY + maxY)/2.0 / 1024.0 * 100.0,
    Double(skelW) / 1366.0 * 100.0,
    Double(skelH) / 1024.0 * 100.0))

