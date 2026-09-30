import AppKit

let skullUrl = URL(fileURLWithPath: "scratch/hires_skull_crop.png")
let skullImg = NSImage(contentsOf: skullUrl)!
let skullRep = NSBitmapImageRep(data: skullImg.tiffRepresentation!)!

var trueMaxY = 0
for y in 0..<skullRep.pixelsHigh {
    for x in 0..<skullRep.pixelsWide {
        let c = skullRep.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.5 {
            // ignore bottom-left spine fragment (x < 60, y > 140)
            if !(x < 60 && y > 140) {
                trueMaxY = max(trueMaxY, y)
            }
        }
    }
}

print("True skull height without spine fragment: \(trueMaxY + 1)")
print("Aspect without spine fragment: \(Double(skullRep.pixelsWide) / Double(trueMaxY + 1))")
print("Screenshot skull aspect: \(56.0 / 50.0)")

