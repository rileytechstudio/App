import AppKit

let soloUrl = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let skelUrl = URL(fileURLWithPath: "scratch/older_boy_skel_transparent.png")

guard let soloImg = NSImage(contentsOf: soloUrl),
      let soloRep = NSBitmapImageRep(data: soloImg.tiffRepresentation!),
      let skelImg = NSImage(contentsOf: skelUrl),
      let skelRep = NSBitmapImageRep(data: skelImg.tiffRepresentation!) else {
    exit(1)
}

let W = soloRep.pixelsWide // 220
let H = soloRep.pixelsHigh // 681

print("Solo character: \(W) x \(H) (aspect: \(Double(W)/Double(H)))")
print("Skeleton: \(skelRep.pixelsWide) x \(skelRep.pixelsHigh) (aspect: \(Double(skelRep.pixelsWide)/Double(skelRep.pixelsHigh)))")

// In the screenshot:
// The skull top sits inside the hair:
// In Character_OlderBoy_Solo.png (681 tall):
// Hair top is at y = 0.
// Skull top is at y ~ 45..55 (approx 7..8% down from top)
// Front foot touches the floor at the bottom of the shoes!
// In Character_OlderBoy_Solo.png:
// Bottom of shoe is at y ~ 675..680 (approx 99..100% of height)
// Back foot is slightly raised or flat on floor.
// Let's test overlaying the skeleton on Character_OlderBoy_Solo:
// What if skeleton height is ~ 92% of character height?
// Let's test heights from 88% to 96% and top offsets from 5% to 10%:

let colorSpace = CGColorSpaceCreateDeviceRGB()

for testH_pct in [90.0, 92.0, 93.0, 94.0, 95.0] {
    for testTop_pct in [5.0, 6.0, 7.0, 8.0] {
        let skelH = CGFloat(H) * CGFloat(testH_pct / 100.0)
        let skelW = skelH * (CGFloat(skelRep.pixelsWide) / CGFloat(skelRep.pixelsHigh))
        // Center or align:
        // In the screenshot, let's see where the skeleton aligns horizontally:
        // Spine is in the back half of the torso, chest is forward.
        // Let's test centerX from 45% to 55%:
        for testCX_pct in [48.0, 50.0, 52.0] {
            guard let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { continue }
            
            // Draw skeleton
            let skelX = CGFloat(W) * CGFloat(testCX_pct / 100.0) - (skelW / 2.0)
            let skelY_cg = CGFloat(H) - (CGFloat(H) * CGFloat(testTop_pct / 100.0) + skelH)
            ctx.draw(skelImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: CGRect(x: skelX, y: skelY_cg, width: skelW, height: skelH))
            
            guard let skelCg = ctx.makeImage() else { continue }
            let skelScreenRep = NSBitmapImageRep(cgImage: skelCg)
            
            var total = 0
            var outside = 0
            for y in 0..<H {
                for x in 0..<W {
                    if skelScreenRep.colorAt(x: x, y: y)!.alphaComponent > 0.05 {
                        total += 1
                        if soloRep.colorAt(x: x, y: y)!.alphaComponent <= 0.05 {
                            outside += 1
                        }
                    }
                }
            }
            if total > 0 && Double(outside) / Double(total) < 0.02 {
                print(String(format: "H: %.1f%%, Top: %.1f%%, CX: %.1f%% => Outside: %d / %d (%.2f%% outside, %.2f%% inside)",
                    testH_pct, testTop_pct, testCX_pct, outside, total, Double(outside)/Double(total)*100.0, (1.0 - Double(outside)/Double(total))*100.0))
            }
        }
    }
}
