import AppKit

guard let targetImg = NSImage(contentsOfFile: "scratch/user_younger_boy_target.png"),
      let targetCg = targetImg.cgImage(forProposedRect: nil, context: nil, hints: nil),
      let candImg = NSImage(contentsOfFile: "scratch/candidate_younger_boy.png"),
      let candCg = candImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    print("Failed to load")
    exit(1)
}

let W = 186
let H = 538
let totalW = W * 2 + 20
let totalH = H

let colorSpace = CGColorSpaceCreateDeviceRGB()
let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
guard let ctx = CGContext(data: nil, width: totalW, height: totalH, bitsPerComponent: 8, bytesPerRow: totalW * 4, space: colorSpace, bitmapInfo: bitmapInfo) else {
    exit(1)
}

// Draw target on left
ctx.draw(targetCg, in: CGRect(x: 0, y: 0, width: W, height: H))
// Draw candidate on right
ctx.draw(candCg, in: CGRect(x: W + 20, y: 0, width: W, height: H))

if let outImg = ctx.makeImage() {
    let rep = NSBitmapImageRep(cgImage: outImg)
    let png = rep.representation(using: .png, properties: [:])!
    try! png.write(to: URL(fileURLWithPath: "scratch/comparison_side_by_side.png"))
    print("Saved scratch/comparison_side_by_side.png")
}

