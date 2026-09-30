import AppKit

let skelUrl = URL(fileURLWithPath: "Anatomy Explorer/Younger Boy Skeleton.png")
let soloUrl = URL(fileURLWithPath: "assets/Character_YoungerBoy_Solo.png")
let bgUrl = URL(fileURLWithPath: "assets/Selected Background.png")

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
let centerX = Double(minX + maxX) / 2.0
let bottomY = maxY

print("Skeleton bounds: x: \(minX)..\(maxX) (w: \(skelW)), y: \(minY)..\(maxY) (h: \(skelH))")
print("Skeleton center X: \(centerX) (\(centerX / 1366.0 * 100.0)%)")
print("Skeleton bottom Y: \(bottomY) (\(Double(bottomY) / 1024.0 * 100.0)%)")
print("Skeleton top Y: \(minY) (\(Double(minY) / 1024.0 * 100.0)%)")

// Now let's check: in the exploration screen, where is Character_YoungerBoy_Solo rendered?
// In preview/index.html:
// .anatomy-exploration-frame: 1366 x 1024
// .anatomy-exploration-char-container:
// bottom: 5% = 51.2px from bottom => y = 1024 - 51.2 = 972.8
// height: 90.3% = 924.672px
// top: 1024 * (1 - 0.05 - 0.903) = 1024 * 0.047 = 48.128px
// left: 50% = 683px center!
// width = 924.672 * (186 / 538) = 319.68px
// left = 683 - 159.84 = 523.16px
// right = 683 + 159.84 = 842.84px

print("\nExploration character container in 1366x1024 frame:")
print("Top: 48.1px, Bottom: 972.8px, Height: 924.7px")
print("Left: 523.2px, Right: 842.8px, Width: 319.7px, Center: 683.0px")

// Look at the skeleton:
// Center: 683.0px! Exactly matches!
// Skel width: 269px! Skel height: 743px!
// Ratio: 269 / 319.7 = 84.1% of container width!
// 743 / 924.7 = 80.4% of container height!

