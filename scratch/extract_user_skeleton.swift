import AppKit

let url = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790613333821.png")
let img = NSImage(contentsOfFile: url.path)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

let W = rep.pixelsWide // 383
let H = rep.pixelsHigh // 539

// Silhouette bounds we found earlier:
// sMinX: 111, sMaxX: 271, sMinY: 31, sMaxY: 496 (161 x 466)
// Let's create an output rep of size 161 x 466 (the exact character frame!)
let sMinX = 111
let sMinY = 31
let charW = 161
let charH = 466

let outRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: charW, pixelsHigh: charH, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<charH {
    for x in 0..<charW {
        let sx = sMinX + x
        let sy = sMinY + y
        guard let c = rep.colorAt(x: sx, y: sy) else { continue }
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        
        // Bone white: r > 0.8, g > 0.8, b > 0.8
        let isWhite = (r > 0.78 && g > 0.78 && b > 0.78)
        // Bone blue: blue dominant
        let isBlue = (b > 0.50 && b > r + 0.12 && g > 0.32)
        // Bone dark line: dark navy/blue
        let isDark = (r < 0.32 && g < 0.35 && b < 0.48 && b > 0.15 && (r + g + b) > 0.12)
        
        // Silhouette is olive: r in 0.65..0.85, g in 0.65..0.85, b in 0.40..0.60
        // Background purple: r in 0.25..0.45, g in 0.15..0.30, b in 0.55..0.75
        let isOlive = (r > 0.60 && g > 0.65 && b < 0.65 && abs(r - g) < 0.15)
        let isPurple = (r < 0.45 && g < 0.35 && b > 0.55)
        
        if (isWhite || isBlue || isDark) && !isOlive && !isPurple {
            outRep.setColor(c, atX: x, y: y)
        } else {
            outRep.setColor(NSColor.clear, atX: x, y: y)
        }
    }
}

let pngData = outRep.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "scratch/extracted_younger_boy_skeleton.png"))
print("Saved scratch/extracted_younger_boy_skeleton.png")

