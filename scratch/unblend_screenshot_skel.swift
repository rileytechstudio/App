import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
let W = rep.pixelsWide
let H = rep.pixelsHigh

let outRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<H {
    for x in 0..<W {
        let c = rep.colorAt(x: x, y: y)!
        let r = c.redComponent
        let g = c.greenComponent
        let b = c.blueComponent
        
        // 1. Dark eye socket / nasal cavity inside skull (x: 105..135, y: 40..75)
        if x >= 105 && x <= 135 && y >= 40 && y <= 75 && r < 0.25 && g < 0.25 && b < 0.35 {
            outRep.setColor(NSColor(calibratedRed: r, green: g, blue: b, alpha: 1.0), atX: x, y: y)
            continue
        }
        
        // 2. Cyan shading (interior of ribs, shading on joints):
        // In screenshot, cyan has high blue, moderate green, low red (r < 0.45, g in 0.4..0.65, b in 0.6..0.8)
        if b > 0.55 && g > 0.38 && g > r + 0.08 && r < 0.48 {
            outRep.setColor(NSColor(calibratedRed: r, green: g, blue: b, alpha: 1.0), atX: x, y: y)
            continue
        }
        
        // 3. Dark outlines / creases on bones (blue contours):
        if b > 0.35 && g > 0.25 && b > r + 0.1 && r < 0.35 {
            // Check if near bone
            outRep.setColor(NSColor(calibratedRed: r, green: g, blue: b, alpha: 1.0), atX: x, y: y)
            continue
        }
        
        // 4. White bone (and anti-aliased edge against pink silhouette):
        // Pink silhouette has r: 0.98, g: 0.53, b: 0.97
        // Pure bone has r: 1.0, g: 1.0, b: 1.0
        // If r > 0.85 and b > 0.85:
        if r > 0.80 && b > 0.80 {
            if g > 0.58 {
                // This is bone (or bone-pink blend)
                // Unblend green: pink has g=0.53, bone has g=1.0
                let alpha = min(1.0, max(0.0, (g - 0.52) / (0.98 - 0.52)))
                if alpha > 0.08 {
                    // True bone color is white with slight cream/blue tint
                    let boneR = 1.0
                    let boneG = 1.0
                    let boneB = 1.0
                    outRep.setColor(NSColor(calibratedRed: boneR, green: boneG, blue: boneB, alpha: alpha), atX: x, y: y)
                    continue
                }
            }
        }
        
        // 5. White bone against background purple (r: 0.30, g: 0.20, b: 0.68):
        if r > 0.35 && g > 0.30 && b > 0.65 && g > 0.25 {
            // Check if it's a bone edge against purple
            if g > 0.65 && r > 0.65 {
                let alpha = min(1.0, max(0.0, (g - 0.20) / 0.80))
                outRep.setColor(NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: alpha), atX: x, y: y)
                continue
            }
        }
        
        // Otherwise transparent
        outRep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
    }
}

// Find bounds
var bMinX = W, bMaxX = 0, bMinY = H, bMaxY = 0
for y in 0..<H {
    for x in 0..<W {
        if outRep.colorAt(x: x, y: y)!.alphaComponent > 0.1 {
            bMinX = min(bMinX, x)
            bMaxX = max(bMaxX, x)
            bMinY = min(bMinY, y)
            bMaxY = max(bMaxY, y)
        }
    }
}

let cropW = bMaxX - bMinX + 1
let cropH = bMaxY - bMinY + 1
let cropped = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: cropW, pixelsHigh: cropH, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<cropH {
    for x in 0..<cropW {
        cropped.setColor(outRep.colorAt(x: bMinX + x, y: bMinY + y)!, atX: x, y: y)
    }
}

let pngData = cropped.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "scratch/unblended_skel_from_shot.png"))
print("Saved unblended skeleton: \(cropW) x \(cropH), bounds in shot: x:\(bMinX)..\(bMaxX), y:\(bMinY)..\(bMaxY)")

