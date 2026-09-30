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

// Let's draw character silhouette into a 1366x1024 context at this exact position:
guard let charCtx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { exit(1) }

let charH: CGFloat = 785.0
let charW: CGFloat = charH * (CGFloat(soloRep.pixelsWide) / CGFloat(soloRep.pixelsHigh)) // 271.4px
let charX: CGFloat = 683.0 - (charW / 2.0)
let charTop: CGFloat = 59.0
let charY_cg: CGFloat = CGFloat(H) - charTop - charH

charCtx.draw(soloImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: CGRect(x: charX, y: charY_cg, width: charW, height: charH))
guard let charCg = charCtx.makeImage() else { exit(1) }
let charScreenRep = NSBitmapImageRep(cgImage: charCg)

var skelPixels = 0
var outsidePixels = 0

for y in 0..<H {
    for x in 0..<W {
        let sColor = skelRep.colorAt(x: x, y: y)!
        if sColor.alphaComponent > 0.05 {
            skelPixels += 1
            let cColor = charScreenRep.colorAt(x: x, y: y)!
            if cColor.alphaComponent <= 0.05 {
                outsidePixels += 1
            }
        }
    }
}

print("Total skeleton pixels: \(skelPixels)")
print("Outside character silhouette: \(outsidePixels) (\(Double(outsidePixels) / Double(skelPixels) * 100.0)%)")
print("Inside character silhouette: \(skelPixels - outsidePixels) (\(Double(skelPixels - outsidePixels) / Double(skelPixels) * 100.0)%)")

