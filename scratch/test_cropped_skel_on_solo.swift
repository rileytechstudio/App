import AppKit

let soloUrl = URL(fileURLWithPath: "assets/Character_YoungerBoy_Solo.png")
let skelCropUrl = URL(fileURLWithPath: "scratch/new_skel_cropped.png")

guard let soloImg = NSImage(contentsOf: soloUrl),
      let soloRep = NSBitmapImageRep(data: soloImg.tiffRepresentation!),
      let skelImg = NSImage(contentsOf: skelCropUrl),
      let skelRep = NSBitmapImageRep(data: skelImg.tiffRepresentation!) else {
    exit(1)
}

let W = soloRep.pixelsWide // 186
let H = soloRep.pixelsHigh // 538

let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { exit(1) }

// Draw solo character at 50% opacity
ctx.setAlpha(0.5)
ctx.draw(soloImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: CGRect(x: 0, y: 0, width: W, height: H))

// Skeleton:
// In top-left percentage:
// top: 5.5% of H = 29.6px
// height: 94.5% of H = 508.4px
// center X: 50% of W = 93px
// width: 99% of W = 184.1px
// In CGContext (bottom-left):
// y = H - (top + height) = H - (0.055 * H + 0.945 * H) = 0! Bottom touches 0!
let skelW = CGFloat(W) * 0.99
let skelH = CGFloat(H) * 0.945
let skelX = (CGFloat(W) - skelW) / 2.0
let skelY: CGFloat = 0.0 // bottom of feet touches bottom of shoes!

ctx.setAlpha(1.0)
ctx.draw(skelImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: CGRect(x: skelX, y: skelY, width: skelW, height: skelH))

guard let compCg = ctx.makeImage() else { exit(1) }
let rep = NSBitmapImageRep(cgImage: compCg)
let pngData = rep.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "scratch/test_cropped_skel_on_solo.png"))
print("Saved scratch/test_cropped_skel_on_solo.png")

