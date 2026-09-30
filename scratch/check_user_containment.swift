import AppKit

let targetUrl = URL(fileURLWithPath: "scratch/user_younger_boy_target.png")
let targetImg = NSImage(contentsOfFile: targetUrl.path)!
let targetCg = targetImg.cgImage(forProposedRect: nil, context: nil, hints: nil)!
let targetRep = NSBitmapImageRep(cgImage: targetCg)

// In user target:
// Silhouette is olive/khaki (r: 0.6..0.85, g: 0.6..0.85, b: 0.25..0.55)
// Bone is white / blue / dark
// Background is purple (r < 0.4, b > 0.6)
var boneTotal = 0
var boneOutsideSilhouette = 0

for y in 0..<targetRep.pixelsHigh {
    for x in 0..<targetRep.pixelsWide {
        let c = targetRep.colorAt(x: x, y: y)!
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        let isBone = (r > 0.82 && g > 0.82 && b > 0.82) || (b > 0.55 && b > r + 0.15 && g > 0.35) || (r < 0.28 && g < 0.28 && b < 0.42 && (r + g + b) > 0.15)
        
        if isBone {
            boneTotal += 1
            // Check if immediate neighbors or pixel are in purple background
            let isBg = (r < 0.45 && g < 0.35 && b > 0.55)
            if isBg {
                boneOutsideSilhouette += 1
            }
        }
    }
}
print("User Target Bone Pixels: \(boneTotal), Outside silhouette: \(boneOutsideSilhouette)")
