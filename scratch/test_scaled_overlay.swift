import AppKit

let soloUrl = URL(fileURLWithPath: "assets/Character_YoungerBoy_Solo.png")
let skelUrl = URL(fileURLWithPath: "Anatomy Explorer/Younger Boy Skeleton.png")

guard let soloImg = NSImage(contentsOf: soloUrl),
      let soloRep = NSBitmapImageRep(data: soloImg.tiffRepresentation!),
      let skelImg = NSImage(contentsOf: skelUrl),
      let skelRep = NSBitmapImageRep(data: skelImg.tiffRepresentation!) else {
    exit(1)
}

let W = 1366
let H = 1024
let colorSpace = CGColorSpaceCreateDeviceRGB()

guard let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { exit(1) }

// In the user's skeleton:
// minX: 549, maxX: 817, minY: 102, maxY: 844 (in top-left coords)
// Center X: 683.0.
// Let's see: In Character_YoungerBoy_Solo.png:
// Top of hair is at y: 0, bottom of feet is at y: 538.
// But the top of the skull is below the hair!
// In our earlier measurement, top of skull is around y: 30 in the 538 character (approx 5.5% down).
// Bottom of feet is at y: 538 (100%).
// So if the character's feet are at maxY = 844:
// And character height is H_char:
// Top of character would be at: 844 - H_char.
// If the skull top is at y = 102:
// Skull top is at (844 - H_char) + (0.055 * H_char) = 844 - 0.945 * H_char = 102 => H_char = (844 - 102) / 0.945 = 785px!
// Let's test H_char = 785px!
let charH: CGFloat = 785.0
let charW: CGFloat = charH * (CGFloat(soloRep.pixelsWide) / CGFloat(soloRep.pixelsHigh)) // 785 * (186/538) = 271.4px!
// Notice that charW = 271.4px, and skeleton width is 269px! THEY MATCH TO WITHIN 2 PIXELS!

let charX: CGFloat = 683.0 - (charW / 2.0)
let charTop: CGFloat = 844.0 - charH // 59.0px
let charY_cg: CGFloat = CGFloat(H) - charTop - charH // in CoreGraphics bottom-left

print("Testing character frame: x: \(charX), y(top): \(charTop), w: \(charW), h: \(charH)")

// Draw character silhouette at 50% opacity
ctx.setAlpha(0.5)
ctx.draw(soloImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: CGRect(x: charX, y: charY_cg, width: charW, height: charH))

// Draw the new skeleton at 100% opacity
ctx.setAlpha(1.0)
ctx.draw(skelImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: CGRect(x: 0, y: 0, width: W, height: H))

guard let compCg = ctx.makeImage() else { exit(1) }
let rep = NSBitmapImageRep(cgImage: compCg)
let pngData = rep.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "scratch/test_scaled_overlay.png"))
print("Saved scratch/test_scaled_overlay.png")

