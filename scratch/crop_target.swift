import AppKit

let userUrl = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790613333821.png")
let userImg = NSImage(contentsOf: userUrl)!
let rep = NSBitmapImageRep(data: userImg.tiffRepresentation!)!

let sMinX = 111
let sMinY = 31
let charW = 161
let charH = 466

let cropRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: charW, pixelsHigh: charH, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for cy in 0..<charH {
    for cx in 0..<charW {
        let color = rep.colorAt(x: sMinX + cx, y: sMinY + cy)!
        cropRep.setColor(color, atX: cx, y: cy)
    }
}

let pngData = cropRep.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "scratch/user_younger_boy_target.png"))
print("Saved scratch/user_younger_boy_target.png")
