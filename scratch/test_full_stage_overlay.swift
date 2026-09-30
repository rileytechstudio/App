import AppKit

let bgUrl = URL(fileURLWithPath: "assets/Selected Background.png")
let soloUrl = URL(fileURLWithPath: "assets/Character_YoungerBoy_Solo.png")
let skelUrl = URL(fileURLWithPath: "Anatomy Explorer/Younger Boy Skeleton.png")

guard let bgImg = NSImage(contentsOf: bgUrl),
      let soloImg = NSImage(contentsOf: soloUrl),
      let skelImg = NSImage(contentsOf: skelUrl) else {
    exit(1)
}

let W = 1366
let H = 1024
let colorSpace = CGColorSpaceCreateDeviceRGB()

guard let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { exit(1) }

// Draw background
ctx.draw(bgImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: CGRect(x: 0, y: 0, width: W, height: H))

// Character frame:
// charHeight = 1024 * 0.903 = 924.672
// charW = 924.672 * (186 / 538) = 319.68
// charCenterX = 683, charCenterY = 506.88
// Note: CGContext origin is bottom-left, so Y needs to be inverted:
// In AppKit/CoreGraphics bottom-left:
// charTop in screen coords is 44.544, so in bottom-left Y it is H - 44.544 - 924.672 = 54.784 (bottom is 54.8 from screen bottom = 5.3%)
let charW: CGFloat = 924.672 * (186.0 / 538.0)
let charH: CGFloat = 924.672
let charX: CGFloat = 683.0 - (charW / 2.0)
let charY_screenTop: CGFloat = 1024.0 * 0.495 - (charH / 2.0)
let charY_cg: CGFloat = CGFloat(H) - charY_screenTop - charH

// Draw character silhouette at 60% opacity
ctx.setAlpha(0.6)
ctx.draw(soloImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: CGRect(x: charX, y: charY_cg, width: charW, height: charH))

// Draw the new skeleton at 100% opacity
ctx.setAlpha(1.0)
ctx.draw(skelImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: CGRect(x: 0, y: 0, width: W, height: H))

guard let compCg = ctx.makeImage() else { exit(1) }
let rep = NSBitmapImageRep(cgImage: compCg)
let pngData = rep.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "scratch/test_full_stage_overlay.png"))
print("Saved scratch/test_full_stage_overlay.png")

