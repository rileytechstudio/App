import AppKit

let soloUrl = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let skelUrl = URL(fileURLWithPath: "scratch/older_boy_skel_perfect.png")

guard let soloImg = NSImage(contentsOf: soloUrl),
      let soloRep = NSBitmapImageRep(data: soloImg.tiffRepresentation!),
      let skelImg = NSImage(contentsOf: skelUrl),
      let skelRep = NSBitmapImageRep(data: skelImg.tiffRepresentation!) else {
    exit(1)
}

let W = soloRep.pixelsWide // 220
let H = soloRep.pixelsHigh // 681

let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { exit(1) }

// Draw solo character at 50% opacity
ctx.setAlpha(0.5)
ctx.draw(soloImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: CGRect(x: 0, y: 0, width: W, height: H))

// Parameters:
// H: 94.0%, Top: 5.0%, CX: 48.0%
let skelH = CGFloat(H) * 0.940
let skelW = skelH * (CGFloat(skelRep.pixelsWide) / CGFloat(skelRep.pixelsHigh))
let skelX = CGFloat(W) * 0.480 - (skelW / 2.0)
let skelY_cg = CGFloat(H) - (CGFloat(H) * 0.050 + skelH)

ctx.setAlpha(1.0)
ctx.draw(skelImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: CGRect(x: skelX, y: skelY_cg, width: skelW, height: skelH))

guard let compCg = ctx.makeImage() else { exit(1) }
let rep = NSBitmapImageRep(cgImage: compCg)
let pngData = rep.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "scratch/test_older_boy_fit.png"))
print("Saved scratch/test_older_boy_fit.png (skelW: \(skelW), skelH: \(skelH), skelX: \(skelX))")

