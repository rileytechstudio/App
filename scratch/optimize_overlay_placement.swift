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

var bestOutside = 999999
var bestH: CGFloat = 0
var bestTop: CGFloat = 0

for h in stride(from: CGFloat(780), through: CGFloat(800), by: 2) {
    for top in stride(from: CGFloat(50), through: CGFloat(66), by: 1) {
        guard let charCtx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { continue }
        
        let charW = h * (CGFloat(soloRep.pixelsWide) / CGFloat(soloRep.pixelsHigh))
        let charX = 683.0 - (charW / 2.0)
        let charY_cg = CGFloat(H) - top - h
        
        charCtx.draw(soloImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: CGRect(x: charX, y: charY_cg, width: charW, height: h))
        guard let charCg = charCtx.makeImage() else { continue }
        let charScreenRep = NSBitmapImageRep(cgImage: charCg)
        
        var outside = 0
        for y in 0..<H {
            for x in 0..<W {
                if skelRep.colorAt(x: x, y: y)!.alphaComponent > 0.05 {
                    if charScreenRep.colorAt(x: x, y: y)!.alphaComponent <= 0.05 {
                        outside += 1
                    }
                }
            }
        }
        if outside < bestOutside {
            bestOutside = outside
            bestH = h
            bestTop = top
        }
    }
}

print("Best placement: height: \(bestH), top: \(bestTop), outside pixels: \(bestOutside) (99.\(String(format: "%.2f", (1.0 - Double(bestOutside)/72443.0)*100.0))%)")

