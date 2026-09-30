import AppKit

let targetUrl = URL(fileURLWithPath: "scratch/user_younger_boy_target.png")
let targetImg = NSImage(contentsOf: targetUrl)!
let rep = NSBitmapImageRep(data: targetImg.tiffRepresentation!)!
let W = rep.pixelsWide
let H = rep.pixelsHigh

print("Target width: \(W), height: \(H)")

// Let's sample colors down the vertical center line (x = W/2 = 80)
for y in stride(from: 0, to: H, by: 10) {
    let c = rep.colorAt(x: W/2, y: y)!
    // Bone colors are white/light blue (r > 0.8, g > 0.8, b > 0.8) or blue accents (b > 0.6, r < 0.4)
    let isBone = (c.redComponent > 0.8 && c.greenComponent > 0.8 && c.blueComponent > 0.8) || (c.blueComponent > 0.6 && c.redComponent < 0.4)
    if isBone {
        print(String(format: "y: %3d (%.1f%%) - BONE - r:%.2f g:%.2f b:%.2f", y, Double(y)/Double(H)*100.0, c.redComponent, c.greenComponent, c.blueComponent))
    }
}
